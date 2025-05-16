是的，你可以在點擊 ASPxGridView 的 ToolbarItem 後，根據條件在後端判斷，並用 ShowPopup() 跳出 DevExpress 的提醒視窗。這需要搭配你目前的 CustomCallback 架構做一點擴充，讓後端能控制是否要顯示 popup。

⸻

實作方式概述

你目前是使用：
	•	Toolbar → PerformCallback("customXXX") 傳參數給後端
	•	後端 → CustomCallback 依參數判斷執行動作

若你要在某個條件下 觸發 DevExpress ASPxPopupControl 顯示提示訊息，可以透過 JSProperties 把 flag 或訊息回傳給前端，再在 JavaScript 中觸發 popup.Show()。

⸻

Step-by-step 範例整合

1. ASPX：加入 ASPxPopupControl

<dx:ASPxPopupControl ID="popupAlert" runat="server" 
    ClientInstanceName="popupAlert"
    PopupHorizontalAlign="WindowCenter"
    PopupVerticalAlign="WindowCenter"
    ShowCloseButton="true"
    ShowHeader="true"
    HeaderText="提醒"
    Width="300px"
    Modal="True">
    <ContentCollection>
        <dx:PopupControlContentControl runat="server">
            <dx:ASPxLabel ID="lblPopupMessage" runat="server" ClientInstanceName="lblPopupMessage" Text="" />
        </dx:PopupControlContentControl>
    </ContentCollection>
</dx:ASPxPopupControl>


⸻

2. JavaScript：接收後端回傳訊息後彈窗

<script type="text/javascript">
    function onToolbarClick(s, e) {
        s.PerformCallback(e.item.name);
    }

    function onEndCallback(s, e) {
        var showPopup = s.cpShowPopup;
        var message = s.cpPopupMessage;

        if (showPopup && message) {
            lblPopupMessage.SetText(message);
            popupAlert.Show();
        }

        // 清除暫存屬性避免重複觸發
        s.cpShowPopup = null;
        s.cpPopupMessage = null;
    }
</script>


⸻

3. ASPxGridView 設定事件

<dx:ASPxGridView ID="ASPxGridView1" runat="server"
    ClientInstanceName="grid"
    OnCustomCallback="ASPxGridView1_CustomCallback">
    <ClientSideEvents ToolbarItemClick="onToolbarClick" EndCallback="onEndCallback" />
</dx:ASPxGridView>


⸻

4. 後端：在條件成立時設定 JSProperties

protected void ASPxGridView1_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
{
    if (e.Parameters == "customLockCheck")
    {
        bool isLocked = CheckIfDataExistsInOracle(); // 你自己的檢查條件

        if (isLocked)
        {
            // 設定前端要用的屬性
            ASPxGridView1.JSProperties["cpShowPopup"] = true;
            ASPxGridView1.JSProperties["cpPopupMessage"] = "目前資料已鎖定，無法進行操作！";
        }
        else
        {
            // 執行其他動作
        }
    }
}


⸻

結論

是的，你可以在點擊 ToolbarItem 後，依據條件呼叫 ShowPopup 跳出提醒視窗，只要透過 DevExpress 的 JSProperties 將訊息從後端傳到前端即可。

是否要我幫你加上完整整合這段邏輯的頁面？