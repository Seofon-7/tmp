很好！你提到重點了：
你在 Inline 新增模式（IsNewRowEditing） 使用 FindEditRowCellTemplateControl，但卻「取不到值」。這是 DevExpress Grid 在 inline 插入模式下一個常見的「陷阱」。

⸻

為什麼 FindEditRowCellTemplateControl() 在 RowInserting 時找不到值？

因為在 RowInserting 事件觸發的時候，Grid 的內部控制項還沒完全建立完畢，或者你其實沒有使用 FieldName 對應的方式去包裝那三個控制項，導致它不被 Grid 當成編輯欄位的子控制項，也就不能正確使用 FindEditRowCellTemplateControl() 找到。

⸻

正確處理方式

解法 A：改用 GridView.HtmlRowPrepared 或 GridView.HtmlEditFormCreated 暫存控制項

你可以先在 HtmlEditFormCreated 找到那些控制項，然後在 RowInserting 裡透過變數取值。

範例：

// 全域暫存控制項參考
private ASPxSpinEdit _spnValue, _spnCount;
private ASPxComboBox _cmbUnit;

protected void ASPxGridView1_HtmlEditFormCreated(object sender, ASPxGridViewEditFormEventArgs e)
{
    var grid = sender as ASPxGridView;
    if (grid.IsNewRowEditing)
    {
        _spnValue = grid.FindEditRowCellTemplateControl(
            (GridViewDataColumn)grid.Columns["frequency"], "spnValue") as ASPxSpinEdit;
        _spnCount = grid.FindEditRowCellTemplateControl(
            (GridViewDataColumn)grid.Columns["frequency"], "spnCount") as ASPxSpinEdit;
        _cmbUnit = grid.FindEditRowCellTemplateControl(
            (GridViewDataColumn)grid.Columns["frequency"], "cmbUnit") as ASPxComboBox;
    }
}

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    if (_spnValue != null && _spnCount != null && _cmbUnit != null)
    {
        string combined = $"{_spnValue.Value},{_spnCount.Value},{_cmbUnit.Value}";
        e.NewValues["frequency"] = combined;
    }
}



⸻

解法 B：不要用 TemplateControl，直接加三個欄位 + 隱藏合併欄位

如果你想簡化邏輯又不影響前端樣式，可以這樣做：
	1.	資料表仍保留一個 frequency 欄位。
	2.	GridView 中設三個實體欄位：freq_val, freq_count, freq_unit。
	3.	這三個欄位編輯時是可見的。
	4.	第四個 frequency 欄位是隱藏欄位，用來存組合後的結果（實際寫入 DB）。

然後你在 RowInserting 中這樣組：

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    var val = e.NewValues["freq_val"];
    var cnt = e.NewValues["freq_count"];
    var unit = e.NewValues["freq_unit"];

    e.NewValues["frequency"] = $"{val},{cnt},{unit}";
}

這樣就完全不會遇到 FindEditRowCellTemplateControl 找不到的問題了，因為這些值 DevExpress 自己幫你收好了。

⸻

你想保留 Template 的方式嗎？還是想改成欄位方式比較簡單？我可以根據你的 HTML 結構提供直接改法。你也可以貼上那一欄的 GridView 設定（只要 frequency 那一欄即可），我幫你調整成最穩的方式。