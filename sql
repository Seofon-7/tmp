如果你依照方案 B 依然拿不到 spinValue、spinCount、cmbUnit，那通常是因為在 Inline 模式下的「新增列」，模板控制項還沒有在 Grid 外層建立完全，直接呼叫 FindEditRowCellTemplateControl 會回傳 null。下面有兩個加強版的作法，你可以擇一試看看。

1. 透過 EditingRowVisibleIndex + FindRowCellTemplateControl

在 Inline 模式下，Grid 的「編輯列」其實就是 EditingRowVisibleIndex 這一列（新增模式下這個 index 也是正確的）。
你可以這樣寫：

protected void gridB_RowInserting(object sender, ASPxDataInsertingEventArgs e) {
    FillFromControls(e.NewValues);
}

void FillFromControls(System.Collections.IDictionary vals) {
    // 1. 取目前的「編輯列」索引
    int editIndex = gridB.EditingRowVisibleIndex;
    
    // 2. 找到那一格 (cell) 裡的控制項
    var col = gridB.Columns["Dummy"] as GridViewDataColumn;
    var spinValue    = gridB.FindRowCellTemplateControl(editIndex, col, "spinValue")    as ASPxSpinEdit;
    var spinCount    = gridB.FindRowCellTemplateControl(editIndex, col, "spinCount")    as ASPxSpinEdit;
    var comboUnit    = gridB.FindRowCellTemplateControl(editIndex, col, "cmbUnit")      as ASPxComboBox;
    
    // 3. 塞值
    if (spinValue != null) vals["unitValue"] = spinValue.Value;
    if (spinCount != null) vals["unitCount"] = spinCount.Value;
    if (comboUnit != null) vals["unitText"]  = comboUnit.Value;
}

	重點
		•	gridB.EditingRowVisibleIndex：這個 index 在「新增列」跟「編輯列」都有效。
	•	FindRowCellTemplateControl( rowIndex, column, controlID )：比單純的 FindEditRowCellTemplateControl 更穩定。

2. 把三個控制項拆到各自的 Column

如果上面還是抓不到，建議第 2 種加強版：把三個控件分到 3 個各自綁欄位的 GridViewDataColumn，這樣 DevExpress 自動會幫你把它們在 Inline 新增時建起來，你就可以直接在事件裡用原生的：

ASPxSpinEdit spinValue = gridB.FindEditRowCellTemplateControl(
    gridB.Columns["Value1"] as GridViewDataColumn, "spinValue") as ASPxSpinEdit;
… 

對照方案 B，把欄位改成：

<dx:GridViewDataColumn FieldName="Value1" Caption="拆分後值">
  <EditItemTemplate>
    <dx:ASPxSpinEdit ID="spinValue" runat="server"
        Value='<%# getFrequencyValue(Eval("frequency")) %>' />
  </EditItemTemplate>
</dx:GridViewDataColumn>
<dx:GridViewDataColumn FieldName="Value2" Caption="單位數">
  <EditItemTemplate>
    <dx:ASPxSpinEdit ID="spinCount" runat="server"
        Value='<%# getFrequencyUnitCount(Eval("frequency")) %>' />
  </EditItemTemplate>
</dx:GridViewDataColumn>
<dx:GridViewDataColumn FieldName="Value3" Caption="單位文字">
  <EditItemTemplate>
    <dx:ASPxComboBox ID="cmbUnit" runat="server"
        Value='<%# getFrequencyUnit(Eval("frequency")) %>' />
  </EditItemTemplate>
</dx:GridViewDataColumn>

然後在 RowInserting/Updating 就真的能穩拿到每個 control：

protected void gridB_RowInserting(object sender, ASPxDataInsertingEventArgs e) {
    var col1 = gridB.Columns["Value1"] as GridViewDataColumn;
    var col2 = gridB.Columns["Value2"] as GridViewDataColumn;
    var col3 = gridB.Columns["Value3"] as GridViewDataColumn;
    var sv   = gridB.FindEditRowCellTemplateControl(col1, "spinValue") as ASPxSpinEdit;
    var sc   = gridB.FindEditRowCellTemplateControl(col2, "spinCount") as ASPxSpinEdit;
    var cb   = gridB.FindEditRowCellTemplateControl(col3, "cmbUnit") as ASPxComboBox;
    if (sv != null) e.NewValues["unitValue"] = sv.Value;
    if (sc != null) e.NewValues["unitCount"] = sc.Value;
    if (cb != null) e.NewValues["unitText"]  = cb.Value;
}

哪個方案適合你？
	•	方案 1：保留欄位合併為「Dummy」，用 EditingRowVisibleIndex 搭配 FindRowCellTemplateControl。
	•	方案 2：拆欄位，各自控制，最穩也最容易 debug。

試試看方案 1，如果抓不到再切到方案 2。任何問題再跟我說！