超重要資訊！你提到的是 使用 GridViewToolbarItem 的 Command="New" 加出來的新行，這代表你是在 頂部或底部的編輯行（EditForm） 做新增操作。

而這種情況，DevExpress GridView 其實會產生一個 插入編輯列，但這一列的本質是「EditForm 模式」，不是像你想像中的「EditRow 模式」。這直接影響了：

【為什麼你用 FindEditRowCellTemplateControl() 抓不到】

這個方法只在「Edit Row 模式」下有效，
你現在是「Insert Form 模式（Command=‘New’）」，所以抓不到！

✅ 解法：請改用 FindEditFormTemplateControl()！

DevExpress 有提供對應方法，正確做法如下：

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    // 這裡不是 CellTemplateControl，而是 EditFormTemplateControl！
    ASPxSpinEdit spin1 = ASPxGridView1.FindEditFormTemplateControl("spinValue1") as ASPxSpinEdit;
    ASPxSpinEdit spin2 = ASPxGridView1.FindEditFormTemplateControl("spinValue2") as ASPxSpinEdit;
    ASPxSpinEdit spin3 = ASPxGridView1.FindEditFormTemplateControl("spinValue3") as ASPxSpinEdit;

    if (spin1 != null) e.NewValues["Value1"] = spin1.Value;
    if (spin2 != null) e.NewValues["Value2"] = spin2.Value;
    if (spin3 != null) e.NewValues["Value3"] = spin3.Value;
}

✅ 使用條件：你的 GridView 要設定為 EditForm 模式（這其實你已經用了）

你可以確認這一段在 .aspx 中：

<dx:ASPxGridView ID="ASPxGridView1" runat="server" ... 
    KeyFieldName="ID"
    SettingsEditing-Mode="EditForm" ... >

✅ 補充：三個 ASPxSpinEdit 建議放在 EditFormTemplate 裡

如果你現在的控制項是在自訂的插入畫面裡，建議你用這種結構：

<Templates>
    <EditForm>
        <dx:ASPxSpinEdit ID="spinValue1" runat="server" />
        <dx:ASPxSpinEdit ID="spinValue2" runat="server" />
        <dx:ASPxSpinEdit ID="spinValue3" runat="server" />
    </EditForm>
</Templates>

不然如果你只是包在 Column 裡的 EditItemTemplate，又不是在 Cell Editing 模式下，控制項其實不會出現在編輯區域，或者抓不到。

小結論

狀況	抓法	備註
修改現有列 (Edit Row)	FindEditRowCellTemplateControl()	一般 inline 編輯適用
新增列 (ToolbarItem Command=“New”)	FindEditFormTemplateControl()	Insert 模式專用

如果你願意貼 .aspx 中的欄位定義＋Grid 設定部分，我可以直接幫你調整整段結構成「可以抓到值的新列插入畫面」。要嗎？我幫你弄得乾乾淨淨。