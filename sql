非常感謝你清楚描述結構，這樣我能更精準推敲問題點。你目前的情況可以總結如下：

⸻

目前情況
	•	你使用的是 Inline 編輯模式
	•	GridViewDataColumn FieldName="FREQUENCY" 中的 EditItemTemplate 裡有三個控制項：
	•	ASPxSpinEdit ID="txtFreqCount" → 顯示次數
	•	ASPxSpinEdit ID="txtFreqUnitCount" → 顯示單位次數
	•	ASPxComboBox ID="cmbFreqUnit" → 顯示「天」、「週」等單位
	•	這三個控制項的值來自 Eval(FREQUENCY) 分解後呈現
	•	問題是你在 RowInserting 裡抓不到這三個控制項

⸻

問題根源

這裡的關鍵點是：你把值設在 Value='<%# GetFreqXXX(Eval("FREQUENCY")) %>'，但並沒有 Bind() 回資料源。
這導致 DevExpress 不會把控制項值自動寫入 e.NewValues["FREQUENCY"]，而你又在 RowInserting 裡用 FindEditRowCellTemplateControl() 嘗試抓這三個控制項，卻失敗。

根據你描述的樣子，控制項找不到的原因，十之八九是因為 Grid.Columns["FREQUENCY"] 無法對應到那一欄。

⸻

解法一：確認抓欄位方式正確（極可能是這個問題）

請這樣寫：

GridViewDataColumn freqCol = ASPxGridView1.Columns.OfType<GridViewDataColumn>()
    .FirstOrDefault(c => c.FieldName == "FREQUENCY");

var txtFreqCount = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "txtFreqCount") as ASPxSpinEdit;
var txtFreqUnitCount = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "txtFreqUnitCount") as ASPxSpinEdit;
var cmbFreqUnit = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "cmbFreqUnit") as ASPxComboBox;

這段最關鍵的是 FirstOrDefault(c => c.FieldName == "FREQUENCY")，因為直接用 grid.Columns["FREQUENCY"] 可能會取錯欄位（例如是 CommandColumn 或 TemplateColumn 沒有 FieldName）。

這段會找出正確的 frequency 欄位，再去抓控制項。

⸻

解法二（備案）：改用 Page.PreRender 或 HtmlEditFormCreated 先抓控制項

如果上面還是找不到，可以改成預先抓：

private ASPxSpinEdit _txtFreqCount;
private ASPxSpinEdit _txtFreqUnitCount;
private ASPxComboBox _cmbFreqUnit;

protected void ASPxGridView1_HtmlRowPrepared(object sender, ASPxGridViewTableRowEventArgs e)
{
    if (e.RowType == GridViewRowType.Edit && ASPxGridView1.IsNewRowEditing)
    {
        var freqCol = ASPxGridView1.Columns.OfType<GridViewDataColumn>()
            .FirstOrDefault(c => c.FieldName == "FREQUENCY");

        _txtFreqCount = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "txtFreqCount") as ASPxSpinEdit;
        _txtFreqUnitCount = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "txtFreqUnitCount") as ASPxSpinEdit;
        _cmbFreqUnit = ASPxGridView1.FindEditRowCellTemplateControl(freqCol, "cmbFreqUnit") as ASPxComboBox;
    }
}

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    if (_txtFreqCount != null && _txtFreqUnitCount != null && _cmbFreqUnit != null)
    {
        e.NewValues["FREQUENCY"] = $"{_txtFreqCount.Value},{_txtFreqUnitCount.Value},{_cmbFreqUnit.Value}";
    }
}



⸻

最後建議

如果你這樣還是抓不到，可以在 RowInserting 裡面加個測試 log 或 throw new Exception("控制項是 null")，這樣可以確定是 控制項真的不存在 還是 找的方式錯了。

⸻

如果你願意我可以幫你模擬寫一份完整的簡化範例，讓你對照使用，要嗎？