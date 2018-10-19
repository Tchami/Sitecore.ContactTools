using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using Sitecore.DependencyInjection;
using Sitecore.EmailCampaign.Model.XConnect.Facets;
using Sitecore.EmailCampaign.XConnect.Web;
using Sitecore.XConnect;
using Sitecore.XConnect.Client;
using Sitecore.XConnect.Client.Serialization;
using Sitecore.XConnect.Collection.Model;
using Contact = Sitecore.XConnect.Contact;

namespace Sitecore.ContactTools
{
    /// <summary>
    /// 
    /// </summary>
    public partial class ContactViewer : System.Web.UI.Page
    {
        private readonly IXConnectClientFactory _xConnectClientFactory;
        protected string Json = "{}";

        public ContactViewer()
            : this(ServiceLocator.ServiceProvider.GetService<IXConnectClientFactory>())
        {
        }

        public ContactViewer(IXConnectClientFactory xConnectClientFactory)
        {
            _xConnectClientFactory = xConnectClientFactory;
        }

        /// <summary>
        /// Handles the Load event of the Page control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack)
            {
                return;
            }

            lbFacets.Items.Add(new ListItem(ExmKeyBehaviorCache.DefaultFacetKey, ExmKeyBehaviorCache.DefaultFacetKey)
            {
                Selected = true
            });
            lbFacets.Items.Add(new ListItem(CollectionModel.FacetKeys.EmailAddressList));
            lbFacets.Items.Add(new ListItem(CollectionModel.FacetKeys.PersonalInformation));
            lbFacets.Items.Add(CollectionModel.FacetKeys.ConsentInformation);
            lbFacets.Items.Add(CollectionModel.FacetKeys.ContactBehaviorProfile);
            lbFacets.Items.Add(CollectionModel.FacetKeys.ListSubscriptions);
            lbFacets.Items.Add(CollectionModel.FacetKeys.AutomationPlanEnrollmentCache);
            lbFacets.Items.Add(CollectionModel.FacetKeys.AutomationPlanExit);
            lbFacets.Items.Add(CollectionModel.FacetKeys.PhoneNumberList);
        }

        /// <summary>
        /// Handles the PreRender event of the Page control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        protected void Page_PreRender(object sender, EventArgs e)
        {
            DataBind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnClick_LoadContact(object sender, EventArgs e)
        {
            using (var client = _xConnectClientFactory.GetXConnectClient())
            {
                try
                {
                    ContactReference contactReference = null;
                    IdentifiedContactReference identifiedContactReference = null;
                    
                    identifiedContactReference = new IdentifiedContactReference("ListManager", tbContactIdentifierValue.Text);

                    var selectedFacetKeys = new List<string>();
                    foreach (ListItem lbFacetsItem in lbFacets.Items)
                    {
                        if (lbFacetsItem.Selected)
                        {
                            selectedFacetKeys.Add(lbFacetsItem.Value);
                        }
                    }

                    Contact contact = client.Get((IEntityReference<Contact>)contactReference ?? identifiedContactReference, new ContactExpandOptions(selectedFacetKeys.ToArray())
                    {
                        Interactions = new RelatedInteractionsExpandOptions()
                        {
                            StartDateTime = DateTime.MinValue,
                            Limit = int.MaxValue
                        }
                    });

                    var serializerSettings = new JsonSerializerSettings
                    {
                        ContractResolver = new XdbJsonContractResolver(client.Model,
                            serializeFacets: chkIncludeFacets.Checked,
                            serializeContactInteractions: chkIncludeInteractions.Checked),
                        DateTimeZoneHandling = DateTimeZoneHandling.Utc,
                        DefaultValueHandling = DefaultValueHandling.Ignore,
                        Formatting = Formatting.Indented
                    };

                    Json = JsonConvert.SerializeObject(contact, serializerSettings);
                    lblError.Text = string.Empty;
                }
                catch (Exception ex)
                {
                    lblError.Text = ex.ToString();
                }
            }
        }
    }
}
