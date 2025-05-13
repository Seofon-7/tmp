你使用的是 DevExpress 的 ASPxGridView 和 GridViewToolbarItem，其中包含一個 ComboBox，你希望當使用者變更下拉選單的選項時，觸發 C# 的伺服端程式碼（即 .cs 裡的 function）。這在 DevExpress 中可以透過下列步驟實作：

⸻

Step 1：定義 ToolbarItem 並加入 ComboBox

你需要在 ASPX 頁面上定義一個 ComboBox ToolbarItem，並指定 ClientInstanceName 以便用 JavaScript 操作它。

<dx:ASPxGridView ID="grid" runat="server" ...>
    <SettingsToolbar ShowToolbars="True" />
    <Toolbars>
        <dx:GridViewToolbar>
            <Items>
                <dx:GridViewToolbarItem>
                    <Template>
                        <dx:ASPxComboBox ID="cbxFilter" runat="server"
                            Width="150px"
                            ClientInstanceName="cbxFilter"
                            AutoPostBack="False"
                            OnInit="cbxFilter_Init">
                        </dx:ASPxComboBox>
                    </Template>
                </dx:GridViewToolbarItem>
            </Items>
        </dx:GridViewToolbar>
    </Toolbars>
</dx:ASPxGridView>


⸻

Step 2：在後端初始化 ComboBox 資料（OnInit）

protected void cbxFilter_Init(object sender, EventArgs e)
{
    ASPxComboBox comboBox = sender as ASPxComboBox;
    comboBox.DataSource = GetYourData(); // 這是你從資料庫撈資料的 function
    comboBox.TextField = "DisplayName";
    comboBox.ValueField = "ID";
    comboBox.DataBind();
}


⸻

Step 3：加上 JavaScript 用來呼叫 Callback

你需要一個 ASPxCallback 控制項來從前端觸發後端程式。

ASPX：

<dx:ASPxCallback ID="cbComboCallback" runat="server" ClientInstanceName="cbComboCallback"
    OnCallback="cbComboCallback_Callback">
</dx:ASPxCallback>

JavaScript：

<script type="text/javascript">
    function OnComboBoxChanged(s, e) {
        var selectedValue = s.GetValue();
        cbComboCallback.PerformCallback(selectedValue);
    }
</script>

將上面的 OnComboBoxChanged 綁定到 ComboBox：

<dx:ASPxComboBox ... ClientInstanceName="cbxFilter" ClientSideEvents-SelectedIndexChanged="OnComboBoxChanged" />


⸻

Step 4：處理後端 Callback

protected void cbComboCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
{
    string selectedValue = e.Parameter;
    // 根據選取的值執行邏輯，例如重新查詢資料或更新 Grid
    // 你可以儲存 ViewState 或 Session，然後 Rebind Grid
    // grid.DataSource = GetFilteredData(selectedValue);
    // grid.DataBind();
}


⸻

Bonus：Grid Rebinding（可選）

如果你希望在選擇變更時刷新 GridView，可以在 Callback 中呼叫 grid.DataBind() 或加入另一個 CallbackPanel 包住 Grid。

⸻

總結

動作	技術
初始化下拉選單	ComboBox.Init 事件從 DB 撈資料
使用者選擇變更	JavaScript 的 SelectedIndexChanged
呼叫後端程式碼	使用 ASPxCallback

如果你希望整合 GridView 資料重新載入，也可以用 ASPxCallbackPanel 或 grid.PerformCallback(...) 來觸發。

如果你提供目前的 ASPX 程式碼片段，我可以幫你進一步整合與簡化。