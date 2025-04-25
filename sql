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


明白了，您需要适用于 .NET 4.7.2 和 DevExpress 19.2 的解决方案。基于这些信息，我来提供更加具体的解决方案：

对于 DevExpress ASPxGridView 控件，在 OnRowInserting 事件中获取内联编辑模式下的 ASPxSpinEdit 控件值，您可以使用以下方法：

```csharp
protected void ASPxGridView_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    ASPxGridView grid = sender as ASPxGridView;
    
    // 使用 GetNestedEditFormControl 方法获取嵌套的控件
    ASPxSpinEdit spinEditValue = grid.GetNestedEditFormControl("spinEditID") as ASPxSpinEdit;
    ASPxSpinEdit spinEditUnitCount = grid.GetNestedEditFormControl("spinEditUnitCountID") as ASPxSpinEdit;
    ASPxComboBox comboBoxUnit = grid.GetNestedEditFormControl("comboBoxUnitID") as ASPxComboBox;
    
    if (spinEditValue != null && spinEditUnitCount != null && comboBoxUnit != null)
    {
        // 合并这些值成为 frequency
        e.NewValues["frequency"] = CombineFrequencyValues(
            spinEditValue.Value, 
            spinEditUnitCount.Value, 
            comboBoxUnit.Value
        );
    }
}

private string CombineFrequencyValues(object value, object unitCount, object unit)
{
    // 实现您的逻辑将这些值组合成所需的 frequency 格式
    return string.Format("{0}|{1}|{2}", value, unitCount, unit);
}
```

如果上面的方法不起作用，您可以尝试以下替代方案：

```csharp
protected void ASPxGridView_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    ASPxGridView grid = sender as ASPxGridView;
    
    // 方法一：通过命名容器查找控件
    GridViewEditFormTemplateContainer container = grid.FindEditFormTemplateControl("EditFormContainer") as GridViewEditFormTemplateContainer;
    
    if (container != null)
    {
        ASPxSpinEdit spinEditValue = container.FindControl("spinEditID") as ASPxSpinEdit;
        ASPxSpinEdit spinEditUnitCount = container.FindControl("spinEditUnitCountID") as ASPxSpinEdit;
        ASPxComboBox comboBoxUnit = container.FindControl("comboBoxUnitID") as ASPxComboBox;
        
        if (spinEditValue != null)
        {
            e.NewValues["frequency"] = CombineFrequencyValues(
                spinEditValue.Value, 
                spinEditUnitCount.Value, 
                comboBoxUnit.Value
            );
        }
    }
    
    // 方法二：如果您知道控件的层次结构，可以直接尝试访问
    try
    {
        var editForm = grid.FindEditFormTemplateControl("EditForm");
        if (editForm != null)
        {
            var div = editForm.FindControl("DivContainer");
            if (div != null)
            {
                ASPxSpinEdit spinEditValue = div.FindControl("spinEditID") as ASPxSpinEdit;
                // ... 获取其他控件
            }
        }
    }
    catch (Exception ex)
    {
        // 处理异常
    }
}
```

对于 DevExpress 19.2 版本，您也可以尝试使用 HttpContext.Current.Items 来暂时存储这些值：

```csharp
// 在控件的 ValueChanged 事件中
protected void SpinEdit_ValueChanged(object sender, EventArgs e)
{
    ASPxSpinEdit spinEdit = sender as ASPxSpinEdit;
    if (spinEdit != null)
    {
        HttpContext.Current.Items[spinEdit.ID + "_Value"] = spinEdit.Value;
    }
}

// 然后在 RowInserting 事件中
protected void ASPxGridView_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    object value = HttpContext.Current.Items["spinEditID_Value"];
    object unitCount = HttpContext.Current.Items["spinEditUnitCountID_Value"];
    object unit = HttpContext.Current.Items["comboBoxUnitID_Value"];
    
    if (value != null && unitCount != null && unit != null)
    {
        e.NewValues["frequency"] = CombineFrequencyValues(value, unitCount, unit);
    }
}
```

最后，如果您使用的是内联编辑模式并且控件绑定到了数据源，您可以尝试直接从 e.NewValues 中获取值：

```csharp
protected void ASPxGridView_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    // 假设您的 ASPxSpinEdit 和 ASPxComboBox 的 FieldName 属性已设置好
    object value = e.NewValues["ValueFieldName"];
    object unitCount = e.NewValues["UnitCountFieldName"];
    object unit = e.NewValues["UnitFieldName"];
    
    if (value != null && unitCount != null && unit != null)
    {
        e.NewValues["frequency"] = CombineFrequencyValues(value, unitCount, unit);
    }
}
```

这些方法应该能够在 .NET 4.7.2 和 DevExpress 19.2 环境中工作。请根据您的具体控件结构和命名选择最合适的方法。​​​​​​​​​​​​​​​​





希望这些建议对您有所帮助！如果您能提供更具体的代码示例，我可以给出更精确的解决方案。​​​​​​​​​​​​​​​​