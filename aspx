<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SpcToolRank.aspx.cs" Inherits="SpcToolRankProject.SpcToolRank" %>

<%@ Register Assembly="DevExpress.Web.v19.2, Version=19.2.0.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" 
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SPC Tool Rank Management</title>
    <style type="text/css">
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            margin-bottom: 20px;
        }
        .footer {
            margin-top: 20px;
            text-align: right;
        }
        .custom-popup {
            min-width: 400px;
        }
        .custom-popup .form-group {
            margin-bottom: 15px;
        }
        .custom-popup .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .frequency-container {
            display: flex;
            align-items: center;
        }
        .frequency-container > * {
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-container">
            <div class="header">
                <h1>SPC Tool Rank Management</h1>
            </div>
            
            <dx:ASPxGridView ID="SpcToolRankGridView" runat="server" KeyFieldName="Id"
                Width="100%" AutoGenerateColumns="False" OnRowInserting="SpcToolRankGridView_RowInserting"
                OnRowUpdating="SpcToolRankGridView_RowUpdating" OnRowDeleting="SpcToolRankGridView_RowDeleting"
                OnCustomButtonCallback="SpcToolRankGridView_CustomButtonCallback"
                OnCellEditorInitialize="SpcToolRankGridView_CellEditorInitialize"
                ClientInstanceName="gridSpcToolRank">
                <Settings ShowFilterRow="true" ShowFilterRowMenu="true" 
                         ShowGroupPanel="false" ShowHeaderFilterButton="true" />
                <SettingsPager PageSize="20" />
                <SettingsEditing Mode="Inline" />
                <SettingsSearchPanel Visible="false" />
                <SettingsAdaptivity AdaptivityMode="HideDataCells" />
                
                <Toolbars>
                    <dx:GridViewToolbar>
                        <Items>
                            <dx:GridViewToolbarItem Command="New" Text="新增" BeginGroup="true" />
                            <dx:GridViewToolbarItem Name="Save" Text="儲存" BeginGroup="true" 
                                Image-IconID="actions_save_16x16" />
                            <dx:GridViewToolbarItem Name="SearchItem" BeginGroup="true">
                                <Template>
                                    <div style="display: flex; align-items: center;">
                                        <label style="margin-right: 8px;">CHP GRP:</label>
                                        <dx:ASPxTextBox ID="txtSearch" runat="server" Width="150px" 
                                            ClientInstanceName="txtSearch">
                                            <ClientSideEvents KeyPress="function(s, e) {
                                                if(e.htmlEvent.keyCode == 13) {
                                                    searchGrid();
                                                    ASPxClientUtils.PreventEventAndBubble(e.htmlEvent);
                                                }
                                            }" />
                                        </dx:ASPxTextBox>
                                        <dx:ASPxButton ID="btnSearch" runat="server" Text="搜尋" AutoPostBack="false"
                                            Style="margin-left: 8px;">
                                            <ClientSideEvents Click="function(s, e) { searchGrid(); }" />
                                        </dx:ASPxButton>
                                    </div>
                                </Template>
                            </dx:GridViewToolbarItem>
                        </Items>
                    </dx:GridViewToolbar>
                </Toolbars>
                
                <Columns>
                    <dx:GridViewCommandColumn ShowEditButton="true" ShowDeleteButton="true" 
                        ShowNewButtonInHeader="false" Width="100">
                        <CustomButtons>
                            <dx:GridViewCommandColumnCustomButton ID="btnAddWithChpGrp" Text="新增相同CHP_GRP" />
                        </CustomButtons>
                    </dx:GridViewCommandColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="Id" ReadOnly="true" Visible="false" />
                    
                    <dx:GridViewDataComboBoxColumn FieldName="ChpGrp" Caption="CHP GRP" Width="150">
                        <PropertiesComboBox ValueField="ChpGrp" TextField="ChpGrp" 
                            ValueType="System.String" DropDownStyle="DropDownList"
                            EnableCallbackMode="true" CallbackPageSize="20">
                            <ValidationSettings RequiredField-IsRequired="true" 
                                RequiredField-ErrorText="請輸入或選擇CHP GRP" />
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="Layer" Caption="Layer" Width="120">
                        <PropertiesTextEdit>
                            <ValidationSettings RequiredField-IsRequired="true" 
                                RequiredField-ErrorText="請輸入Layer" />
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="OpeNo" Caption="OPE NO" Width="120">
                        <PropertiesTextEdit>
                            <ValidationSettings RequiredField-IsRequired="true" 
                                RequiredField-ErrorText="請輸入OPE NO" />
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="PR" Caption="PR" Width="120">
                        <PropertiesTextEdit>
                            <ValidationSettings RequiredField-IsRequired="true" 
                                RequiredField-ErrorText="請輸入PR" />
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="Frequency" Caption="頻率" Width="150">
                        <EditItemTemplate>
                            <div class="frequency-container">
                                <dx:ASPxSpinEdit ID="seFrequencyCount" runat="server" Width="60px" MinValue="1" 
                                    Value='<%# GetFrequencyCount(Eval("Frequency").ToString()) %>'>
                                </dx:ASPxSpinEdit>
                                <span>次:</span>
                                <dx:ASPxSpinEdit ID="seFrequencyPeriodValue" runat="server" Width="60px" MinValue="1" 
                                    Value='<%# GetFrequencyPeriodValue(Eval("Frequency").ToString()) %>'>
                                </dx:ASPxSpinEdit>
                                <dx:ASPxComboBox ID="cbFrequencyPeriod" runat="server" Width="70px" 
                                    Value='<%# GetFrequencyPeriodType(Eval("Frequency").ToString()) %>'>
                                    <Items>
                                        <dx:ListEditItem Text="天" Value="天" />
                                        <dx:ListEditItem Text="週" Value="週" />
                                    </Items>
                                </dx:ASPxComboBox>
                            </div>
                        </EditItemTemplate>
                    </dx:GridViewDataTextColumn>
                </Columns>
                
                <ClientSideEvents ToolbarItemClick="function(s, e) {
                    if (e.item.name === 'Save') {
                        saveChanges();
                    }
                }" />
            </dx:ASPxGridView>
            
            <!-- Popup for adding new record -->
            <dx:ASPxPopupControl ID="PopupAddRecord" runat="server" ClientInstanceName="popupAddRecord"
                Width="500px" CloseAction="CloseButton" CloseOnEscape="true" Modal="true"
                PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
                HeaderText="新增資料" CssClass="custom-popup">
                <ContentCollection>
                    <dx:PopupControlContentControl runat="server">
                        <dx:ASPxFormLayout ID="FormAddRecord" runat="server" Width="100%">
                            <Items>
                                <dx:LayoutGroup ColCount="1" ShowCaption="false">
                                    <Items>
                                        <dx:LayoutItem Caption="CHP GRP" FieldName="ChpGrp">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <dx:ASPxComboBox ID="cmbChpGrp" runat="server" Width="100%" 
                                                        ClientInstanceName="cmbChpGrp">
                                                        <ValidationSettings RequiredField-IsRequired="true" 
                                                            RequiredField-ErrorText="請輸入或選擇CHP GRP" />
                                                    </dx:ASPxComboBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        
                                        <dx:LayoutItem Caption="Layer" FieldName="Layer">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <dx:ASPxTextBox ID="txtLayer" runat="server" Width="100%" 
                                                        ClientInstanceName="txtLayer">
                                                        <ValidationSettings RequiredField-IsRequired="true" 
                                                            RequiredField-ErrorText="請輸入Layer" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        
                                        <dx:LayoutItem Caption="OPE NO" FieldName="OpeNo">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <dx:ASPxTextBox ID="txtOpeNo" runat="server" Width="100%" 
                                                        ClientInstanceName="txtOpeNo">
                                                        <ValidationSettings RequiredField-IsRequired="true" 
                                                            RequiredField-ErrorText="請輸入OPE NO" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        
                                        <dx:LayoutItem Caption="PR" FieldName="PR">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <dx:ASPxTextBox ID="txtPR" runat="server" Width="100%" 
                                                        ClientInstanceName="txtPR">
                                                        <ValidationSettings RequiredField-IsRequired="true" 
                                                            RequiredField-ErrorText="請輸入PR" />
                                                    </dx:ASPxTextBox>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        
                                        <dx:LayoutItem Caption="頻率" FieldName="Frequency">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <div class="frequency-container">
                                                        <dx:ASPxSpinEdit ID="seAddFrequencyCount" runat="server" Width="60px" 
                                                            MinValue="1" Value="1" ClientInstanceName="seAddFrequencyCount">
                                                        </dx:ASPxSpinEdit>
                                                        <span>次:</span>
                                                        <dx:ASPxSpinEdit ID="seAddFrequencyPeriodValue" runat="server" Width="60px" 
                                                            MinValue="1" Value="1" ClientInstanceName="seAddFrequencyPeriodValue">
                                                        </dx:ASPxSpinEdit>
                                                        <dx:ASPxComboBox ID="cbAddFrequencyPeriod" runat="server" Width="70px" 
                                                            Value="天" ClientInstanceName="cbAddFrequencyPeriod">
                                                            <Items>
                                                                <dx:ListEditItem Text="天" Value="天" />
                                                                <dx:ListEditItem Text="週" Value="週" />
                                                            </Items>
                                                        </dx:ASPxComboBox>
                                                    </div>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                        
                                        <dx:LayoutItem ShowCaption="false">
                                            <LayoutItemNestedControlCollection>
                                                <dx:LayoutItemNestedControlContainer>
                                                    <div class="footer">
                                                        <dx:ASPxButton ID="btnAddConfirm" runat="server" Text="確認" Width="80" 
                                                            AutoPostBack="false" ClientInstanceName="btnAddConfirm">
                                                            <ClientSideEvents Click="function(s, e) { addNewRecord(); }" />
                                                        </dx:ASPxButton>
                                                        <dx:ASPxButton ID="btnCancel" runat="server" Text="取消" Width="80" 
                                                            AutoPostBack="false">
                                                            <ClientSideEvents Click="function(s, e) { popupAddRecord.Hide(); }" />
                                                        </dx:ASPxButton>
                                                    </div>
                                                </dx:LayoutItemNestedControlContainer>
                                            </LayoutItemNestedControlCollection>
                                        </dx:LayoutItem>
                                    </Items>
                                </dx:LayoutGroup>
                            </Items>
                        </dx:ASPxFormLayout>
                    </dx:PopupControlContentControl>
                </ContentCollection>
            </dx:ASPxPopupControl>
            
            <!-- Hidden ASPxCallback for processing save action -->
            <dx:ASPxCallback ID="CallbackSave" runat="server" ClientInstanceName="callbackSave" 
                OnCallback="CallbackSave_Callback">
                <ClientSideEvents CallbackComplete="function(s, e) { 
                    if (e.result === 'success') {
                        alert('資料已成功儲存');
                        gridSpcToolRank.Refresh();
                    } else {
                        alert('儲存失敗: ' + e.result);
                    }
                }" />
            </dx:ASPxCallback>
        </div>
    </form>
    
    <script type="text/javascript">
        // Search grid by CHP GRP
        function searchGrid() {
            var searchText = txtSearch.GetText();
            gridSpcToolRank.ClearFilter();
            
            if (searchText && searchText.length > 0) {
                gridSpcToolRank.ApplyFilter(["ChpGrp"], "Contains", searchText);
            }
        }
        
        // Add new record from popup form
        function addNewRecord() {
            if (ASPxClientEdit.ValidateGroup(null)) {
                var frequency = formatFrequency(
                    seAddFrequencyCount.GetValue(),
                    seAddFrequencyPeriodValue.GetValue(),
                    cbAddFrequencyPeriod.GetValue()
                );
                
                gridSpcToolRank.AddNewRow({
                    ChpGrp: cmbChpGrp.GetValue(),
                    Layer: txtLayer.GetValue(),
                    OpeNo: txtOpeNo.GetValue(),
                    PR: txtPR.GetValue(),
                    Frequency: frequency
                });
                
                popupAddRecord.Hide();
            }
        }
        
        // Format frequency string in the format: n次:n天 or n次:n週
        function formatFrequency(count, periodValue, periodType) {
            return count + '次:' + periodValue + periodType;
        }
        
        // Save all changes to database
        function saveChanges() {
            if (confirm('確定要儲存所有更改嗎?')) {
                callbackSave.PerformCallback();
            }
        }
    </script>
</body>
</html>