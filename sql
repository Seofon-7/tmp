我理解您在 ASP.NET 的 GridView 控件中使用 OnRowUpdating 事件时可以找到 ASPxSpinEdit 控件的值，但在 OnRowInserting 事件中却无法找到。这是因为在插入新行时与更新已有行的处理方式有所不同。

针对您的问题，在 OnRowInserting 事件中获取 ASPxSpinEdit 控件的值，您可以尝试以下解决方案：

```csharp
protected void GridView_RowInserting(object sender, ASPxGridViewInsertingEventArgs e)
{
    // 获取插入行中的控件
    ASPxSpinEdit spinEditValue = GridView.FindEditFormTemplateControl("spinEditID") as ASPxSpinEdit;
    ASPxSpinEdit spinEditUnitCount = GridView.FindEditFormTemplateControl("spinEditUnitCountID") as ASPxSpinEdit;
    ASPxComboBox comboBoxUnit = GridView.FindEditFormTemplateControl("comboBoxUnitID") as ASPxComboBox;
    
    if (spinEditValue != null)
    {
        // 获取控件的值并赋给e.NewValues集合
        e.NewValues["frequency"] = ConvertToFrequency(spinEditValue.Value, spinEditUnitCount.Value, comboBoxUnit.Value);
    }
}

// 辅助方法，用于将各个控件的值转换为frequency值
private string ConvertToFrequency(object value, object unitCount, object unit)
{
    // 实现您的转换逻辑
    // 例如：return value.ToString() + unitCount.ToString() + unit.ToString();
}
```

如果您使用的是内联编辑模式(inline edit mode)，那么需要使用不同的方法获取控件：

```csharp
protected void GridView_RowInserting(object sender, ASPxGridViewInsertingEventArgs e)
{
    GridViewRow row = GridView.FindChildControl("GridView1").NamingContainer as GridViewRow;
    
    // 注意这里的路径应该与您的控件层次结构匹配
    ASPxSpinEdit spinEditValue = row.FindControl("spinEditID") as ASPxSpinEdit;
    ASPxSpinEdit spinEditUnitCount = row.FindControl("spinEditUnitCountID") as ASPxSpinEdit;
    ASPxComboBox comboBoxUnit = row.FindControl("comboBoxUnitID") as ASPxComboBox;
    
    if (spinEditValue != null)
    {
        e.NewValues["frequency"] = ConvertToFrequency(spinEditValue.Value, spinEditUnitCount.Value, comboBoxUnit.Value);
    }
}
```

另外，您也可以尝试直接从 e.NewValues 字典中获取值，因为 ASPxGridView 在触发 RowInserting 事件前会将控件的值收集到这个字典中：

```csharp
protected void GridView_RowInserting(object sender, ASPxGridViewInsertingEventArgs e)
{
    // 假设您的ASPxSpinEdit控件的DataField属性已设置好
    object value = e.NewValues["spinEditDataField"];
    object unitCount = e.NewValues["unitCountDataField"];
    object unit = e.NewValues["unitDataField"];
    
    e.NewValues["frequency"] = ConvertToFrequency(value, unitCount, unit);
}
```

如果以上方法都不起作用，您可能需要在页面加载时给这些控件添加事件处理器，并在事件中保存控件的值到一个静态变量或者ViewState中，然后在OnRowInserting事件中使用这些保存的值。

希望这些建议对您有所帮助！如果您能提供更具体的代码示例，我可以给出更精确的解决方案。​​​​​​​​​​​​​​​​