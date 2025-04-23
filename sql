懂了，你的情境是這樣：
	•	你用的是 DevExpress 的 ASPxGridView（或者 GridView + SpinEdit 控制項）。
	•	在 OnRowUpdating 事件裡，用 FindEditRowCellTemplateControl 找到指定 column 內的 control（比如 ASPxSpinEdit），能成功拿到值。
	•	但在 OnRowInserting 事件裡，用一樣的方法卻找不到 control 或取不到值。

對吧？

這個問題其實蠻常見，原因是：

	在 OnRowInserting 時，GridView 還沒完全建好 Edit Template，所以 FindEditRowCellTemplateControl 有時會拿不到 control。

也就是說，Inserting 的時候，編輯列（EditForm、EditRow）的狀態跟 Updating 不一樣。

正確的做法：

方法 1：用 e.NewValues（推薦）

在 OnRowInserting 事件，其實 DevExpress 官方建議直接從 e.NewValues 拿資料，而不是硬抓 control。
像這樣：

protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    object value = e.NewValues["ColumnName"];
    // value 就是你輸入在 SpinEdit 裡的值
}

這樣寫才是比較正確又穩定的方法，而且不怕 control 不存在的問題。

補充：
	•	e.NewValues["欄位名"] 會拿到你在編輯列輸入的最新值。
	•	這個欄位名，要跟你的 GridView 裡設定的 DataField 對應起來。

方法 2：如果你一定要抓 Control

如果真的一定要抓 Control（比如你有一些特殊處理，比如要改 Control 內的屬性），可以這樣：

先確認 GridView 有在 Insert 狀態，然後找：

ASPxSpinEdit spinEdit = ASPxGridView1.FindEditRowCellTemplateControl(GridView.Columns["ColumnName"], "SpinEditID") as ASPxSpinEdit;
if (spinEdit != null)
{
    var value = spinEdit.Value;
}

但是這個方法不一定穩，如果 Insert 模式是用 Popup EditForm、BatchEdit，會不一樣，容易抓不到。

所以一般來說，OnRowInserting 建議用 e.NewValues，不要用 FindControl。

小結論

做法	穩定性	備註
用 e.NewValues["欄位名"]	最穩	DevExpress官方建議
用 FindEditRowCellTemplateControl 找Control	容易失敗	Insert模式時Control可能還沒生成

例子來個完整一點的（給你貼上參考）

protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    var yourValue = e.NewValues["YourColumnName"];
    
    // 你可以做驗證或轉型處理
    if (yourValue != null)
    {
        int intValue = Convert.ToInt32(yourValue);
        // 做你要的事情
    }

    // 之後記得取消預設事件
    e.Cancel = true;
    ASPxGridView1.CancelEdit();
}

要不要直接給我你的 .aspx 頁面那段 grid 的設定（比如你用 TemplateField 放 SpinEdit 的那段），
我可以幫你直接改成符合這種最穩的方法？
（或者如果你真的想知道怎麼抓 control，也可以給你範例！）

要不要？超快。
你只要貼那段 GridView 的 Columns 定義就好！