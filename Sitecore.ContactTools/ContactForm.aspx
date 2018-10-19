<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactForm.aspx.cs" Inherits="Sitecore.ContactTools.ContactForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contact Form</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <p>
            <table>
                <tr>
                    <td>Number of contacts:</td>
                    <td><asp:TextBox runat="server" id="tbNumberOfContacts" Width="400px" Text="100" /></td>
                </tr>
                <tr>
                    <td>Preferred language:</td>
                    <td><asp:TextBox runat="server" id="tbPreferredLanguage" Width="100px" Text="en" /></td>
                </tr>
              <tr>
                <td>Phone number:</td>
                <td><asp:TextBox runat="server" id="tbPhoneNumber" Width="100px" /></td>
              </tr>
                <tr>
                    <td>Campaign Id:</td>
                    <td><asp:TextBox runat="server" id="tbCampaignId" Width="400px" Text="" /></td>
                </tr>
                <tr>
                    <td>Goal Ids (separate by ;):</td>
                    <td><asp:TextBox runat="server" id="tbGoalIds" Width="400px" Text="8FFB183B-DA1A-4C74-8F3A-9729E9FCFF6A" /></td>
                </tr>
                <tr>
                    <td>Event Ids (separate by ;):</td>
                    <td><asp:TextBox runat="server" id="tbEventIds" Width="400px" Text="" /></td>
                </tr>
                <tr>
                    <td>Outcome Ids (separate by ;):</td>
                    <td><asp:TextBox runat="server" id="tbOutcomeIds" Width="400px" Text="" /></td>
                </tr>
                <tr>
                    <td>Subscribe to list id (leave empty if no subscriptions):</td>
                    <td><asp:TextBox runat="server" ID="tbListId" Width="400px" Text="76D8DA1C-FFD4-4BCF-A976-6D56323582D6" /></td>
                </tr>
                <tr>
                    <td>Do not market:</td>
                    <td><asp:CheckBox runat="server" ID="checkBoxDoNotMarket" /></td>
                </tr>
                <tr>
                    <td>Consent revoked:</td>
                    <td><asp:CheckBox runat="server" ID="checkBoxConsentRevoked" /></td>
                </tr>
                <tr>
                    <td>Engagement value:</td>
                    <td><asp:TextBox runat="server" ID="tbEngagementValue" Text="1" Width="400px" /></td>
                </tr>
                <tr>
                    <td>Profile id:</td>
                    <td><asp:TextBox runat="server" ID="tbProfileId" Text="B5BDEE45-C945-476F-9EE6-3B8A9255C17E" Width="400px" /></td>
                </tr>
                <tr>
                    <td>Profile key id:</td>
                    <td><asp:TextBox runat="server" ID="tbProfileKeyId" Text="B8810A60-3837-4AD1-B0DE-CF14AC5F4792" Width="400px" /></td>
                </tr>
                <tr>
                    <td>Profile score:</td>
                    <td><asp:TextBox runat="server" ID="tbProfileScore" Text="200" Width="400px" /></td>
                </tr>
                <tr>
                    <td colspan="2"><asp:Button Text="Create multiple contacts with an interaction" runat="server" OnClick="OnClick_Create"/></td>
                </tr>
            </table>
        </p>
    </div>
    </form>
</body>
</html>
