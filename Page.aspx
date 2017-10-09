<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Page.aspx.cs" Inherits="ExperianIntegration.Page" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <link rel="stylesheet" href="jquery-ui.css" />
    <script src="https://code.jquery.com/jquery-1.9.1.js"></script>
    <script src="https://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>

    <style>
        .ui-autocomplete {
            font-size: 14px;
            text-align: left;
        }
    </style>
    <title>Experian Validator</title>
    <h1>Experian Validator</h1>
</head>
<body>
    <form id="form1" runat="server">
        <table>
            <tr>
                <td>Email</td>
                <td>
                    <asp:TextBox ID="tbEmail" runat="server" Width="600">Ama@gmail.com</asp:TextBox></td>
                <td>
                    <asp:Button ID="btnValidateEmail" runat="server" Text="Validate email" OnClick="btnValidateEmail_Click" /></td>
            </tr>
            <tr>
                <td>Phone</td>
                <td>
                    <asp:TextBox ID="tbPhone" runat="server" Width="600">+61427671760</asp:TextBox></td>
                <td>
                    <asp:Button ID="btnValidatePhone" runat="server" Text="Validate phone" OnClick="btnValidatePhone_Click" /></td>
            </tr>

            <tr>
                <td>Address</td>
                <td>
                    <asp:TextBox ID="tbAddress" runat="server" Width="600"></asp:TextBox></td>
            </tr>

            <tr>
                <td>Response</td>
                <td>
                    <asp:TextBox ID="tbOutput" runat="server" TextMode="MultiLine" Width="600" Height="300px"></asp:TextBox>
            </tr>

            <tr>
                <td>Response time</td>
                <td>
                    <asp:TextBox ID="tbResponseTime" runat="server" Width="600" Enabled="False"></asp:TextBox></td>
            </tr>
        </table>

        <div>Verified address</div>
        <table id="Address">
            <thead>
                <tr>
                    <th>Key</th>
                    <th>Value</th>
                </tr>
            </thead>
            <tbody id="tblBody">
            </tbody>
        </table>
    </form>
</body>
<script type="text/javascript">
    $(function () {
        $('#tbAddress').autocomplete({
            minLength: 3,
            messages: {
                noResults: '',
                results: function () { }
            },
            source: function (request, response) {
                $.ajax({
                    url: "Page.aspx/GetAddressSugestions",
                    data: JSON.stringify({ request: request.term }),
                    dataType: "json",
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        //alert(data.d.Results[0].Suggestion);
                        $('#tbResponseTime').val(data.d.Elapsed);
                        $('#tbOutput').val(data.d.Response);
                        response($.map(data.d.Results,
                            function (item) {
                                return { label: item.Suggestion, value: item.Suggestion, link: item.Link }
                            }));
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert(textStatus + " - " + errorThrown);
                    }
                });
            },
            select: function (event, ui) {
                //alert(ui.item.link);
                $.ajax({
                    url: "Page.aspx/GetAddressByLink",
                    data: JSON.stringify({ link: ui.item.link }),
                    dataType: "json",
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        //alert(data.d.Results[0].Suggestion);
                        $("#tbResponseTime").val(data.d.Elapsed);
                        $("#tbOutput").val(data.d.Response);
                        //$("tr:has(td)").remove();
                        $("#Address tbody > tr").remove();

                        $.each(data.d.Properties,
                            function (i, item) {
                                var td_keys = $("<td/>");
                                var td_values = $("<td/>");

                                td_keys.append(item.Key);
                                td_values.append(item.Value);

                                $("#Address").append($("<tr/>").append(td_keys).append(td_values));
                            });
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert(textStatus + " - " + errorThrown);
                    }
                });

            }
        });
    })
</script>
</html>
