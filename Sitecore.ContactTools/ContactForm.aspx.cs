using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Hosting;
using Faker;
using Microsoft.Extensions.DependencyInjection;
using Sitecore.Abstractions;
using Sitecore.DependencyInjection;
using Sitecore.EmailCampaign.XConnect.Web;
using Sitecore.XConnect;
using Sitecore.XConnect.Client;
using Sitecore.XConnect.Collection.Model;
using Contact = Sitecore.XConnect.Contact;
using KnownIdentifiers = Sitecore.EmailCampaign.Model.Constants;

namespace Sitecore.ContactTools
{
    /// <summary>
    /// 
    /// </summary>
    public partial class ContactForm : System.Web.UI.Page
    {
        public BaseLog Logger => ServiceLocator.ServiceProvider.GetService<BaseLog>();
        private IXConnectClientFactory _xConnectClientFactory => ServiceLocator.ServiceProvider.GetService<IXConnectClientFactory>();
        private static readonly Guid SystemChannelId = new Guid("27A7E0C2-DE17-46C8-8AA3-CFEC0434CCEB");
        private const string UserAgent = "Sitecore/9.0 (EXM)";
        private static readonly Guid ProfileScoreChangeEventDefinitionId = new Guid("D385BB97-C200-41B6-B053-7A5D8AB58DD0");

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        protected void OnClick_Create(object sender, EventArgs e)
        {
            HostingEnvironment.QueueBackgroundWorkItem(cancellationToken =>
            {
                CreateContacts();
            });
            
        }

        private void CreateContacts()
        {
            using (IXdbContext client = _xConnectClientFactory.GetXConnectClient())
            {
                try
                {
                    var numberOfContacts = int.Parse(tbNumberOfContacts.Text, CultureInfo.CurrentCulture);

                    var goalIds = tbGoalIds.Text.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries).Select(Guid.Parse);
                    var eventIds = tbEventIds.Text.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries).Select(Guid.Parse);
                    var outcomeIds = tbOutcomeIds.Text.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries).Select(Guid.Parse);

                    var listId = !string.IsNullOrWhiteSpace(tbListId.Text) ? Guid.Parse(tbListId.Text) : Guid.Empty;
                    var campaignId = !string.IsNullOrWhiteSpace(tbCampaignId.Text) ? Guid.Parse(tbCampaignId.Text) : Guid.Empty;

                    for (var i = 0; i < numberOfContacts; i++)
                    {
                        string email = GetEmailAddress(i);

                        var contact = new Contact(new ContactIdentifier("ListManager", email, ContactIdentifierType.Known));

                        client.AddContact(contact);

                        AddPreferredEmail(i, client, contact, email);

                        AddPhoneNumber(client, contact, tbPhoneNumber.Text);

                        AddPersonalInfo(client, contact, tbPreferredLanguage.Text);

                        AddListSubscription(listId, client, contact);

                        AddConsentInformation(client, contact);

                        AddProfileScore(client, contact);

                        AddEngagementValue(client, contact);

                        AddInteraction(client, contact, goalIds, outcomeIds, eventIds, campaignId);

                        if (i % 10 != 0)
                        {
                            continue;
                        }

                        var numberOfContactsBeingSubmitted = i / 1 > 0 ? i / 1 : 1;

                        Logger.Info($"Submitting {numberOfContactsBeingSubmitted} contacts", this);
                        client.Submit();
                    }

                    client.Submit();
                }
                catch (Exception ex)
                {
                    Logger.Error("Failed to submit contacts", ex, this);
                }
            }
        }

        private void AddPhoneNumber(IXdbContext client, Contact contact, string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return;
            }

            client.SetPhoneNumbers(contact, new PhoneNumberList(new PhoneNumber("0045", text), "Preferred"));
        }

        private static string GetEmailAddress(int i)
        {
            return FormattableString.Invariant($"contact-{i}-{DateTime.UtcNow:yy-MM-dd-hh-mm-ss-ff}@yourdomain.com");
        }

        private static void AddPreferredEmail(int i, IXdbContext client, Contact contact, string emailAddress)
        {
            client.SetEmails(contact, new EmailAddressList(new EmailAddress(emailAddress, false), "Preferred"));
        }

        private static void AddPersonalInfo(IXdbContext client, Contact contact, string preferredLanguage = null)
        {
            var personalInformation = new PersonalInformation
            {
                FirstName = Name.First(),
                LastName = Name.Last(),
            };

            if (!string.IsNullOrWhiteSpace(preferredLanguage))
            {
                personalInformation.PreferredLanguage = preferredLanguage;
            }

            client.SetPersonal(contact, personalInformation);
        }

        private static void AddListSubscription(Guid listId, IXdbContext client, Contact contact)
        {
            if (listId != Guid.Empty)
            {
                client.SetListSubscriptions(contact, new ListSubscriptions()
                {
                    Subscriptions = new List<ContactListSubscription>()
                    {
                        // 9.1 only
                        //new ContactListSubscription(DateTime.UtcNow, true, listId)
                        //{
                        //    SourceDefinitionId = KnownIdentifiers.EmailExperienceManagerSubscriptionId
                        //}
                    }
                });
            }
        }

        private void AddConsentInformation(IXdbContext client, Contact contact)
        {
            if (checkBoxConsentRevoked.Checked || checkBoxDoNotMarket.Checked)
            {
                client.SetConsentInformation(contact, new ConsentInformation()
                {
                    ConsentRevoked = checkBoxConsentRevoked.Checked,
                    DoNotMarket = checkBoxDoNotMarket.Checked
                });
            }
        }

        private void AddEngagementValue(IXdbContext client, Contact contact)
        {
            if (string.IsNullOrWhiteSpace(tbEngagementValue.Text))
            {
                return;
            }

            int engagementValue = int.Parse(tbEngagementValue.Text, CultureInfo.CurrentCulture);

            var interaction = new Interaction(contact, InteractionInitiator.Brand, SystemChannelId, UserAgent);
            var engagementValueEvent = new Event(Guid.NewGuid(), DateTime.UtcNow)
            {
                EngagementValue = engagementValue
            };
            interaction.Events.Add(engagementValueEvent);

            client.AddInteraction(interaction);
        }

        private void AddProfileScore(IXdbContext client, Contact contact)
        {
            if (string.IsNullOrWhiteSpace(tbProfileScore.Text) || string.IsNullOrWhiteSpace(tbProfileKeyId.Text) || string.IsNullOrWhiteSpace(tbProfileId.Text))
            {
                return;
            }

            Guid profileId = Guid.Parse(tbProfileId.Text);
            Guid profileKeyId = Guid.Parse(tbProfileKeyId.Text);
            int score = int.Parse(tbProfileScore.Text, CultureInfo.CurrentCulture);

            var interaction = new Interaction(contact, InteractionInitiator.Brand, SystemChannelId, UserAgent);
            var engagementValueEvent = new Event(ProfileScoreChangeEventDefinitionId, DateTime.UtcNow);
            interaction.Events.Add(engagementValueEvent);
            client.AddInteraction(interaction);

            var profileScores = new ProfileScores();
            var profileScore = new ProfileScore
            {
                Values =
                {
                    [profileKeyId] = score
                }
            };
            profileScores.Scores.Add(profileId, profileScore);
            client.SetProfileScores(interaction, profileScores);
        }

        private static void AddInteraction(
            IXdbContext client, Contact contact, IEnumerable<Guid> goalIds, 
            IEnumerable<Guid> outcomeIds, IEnumerable<Guid> eventIds, Guid campaignId)
        {
            var interaction = new Interaction(contact, InteractionInitiator.Brand, SystemChannelId, UserAgent);

            foreach (Guid goalId in goalIds)
            {
                var goal = new Goal(goalId, DateTime.UtcNow)
                {
                    Duration = new TimeSpan(0, 0, 30)
                };
                interaction.Events.Add(goal);
            }

            foreach (Guid outcomeId in outcomeIds)
            {
                var outcome = new Outcome(outcomeId, DateTime.UtcNow, "usd", 100.00m);
                interaction.Events.Add(outcome);
            }

            foreach (Guid eventId in eventIds)
            {
                var pageEvent = new Event(eventId, DateTime.UtcNow)
                {
                    Duration = new TimeSpan(0, 0, 30)
                };
                interaction.Events.Add(pageEvent);
            }

            interaction.CampaignId = campaignId;

            client.AddInteraction(interaction);
        }
    }
}
