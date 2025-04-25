明白了您的情况，现在我更清楚您的代码结构了。基于您描述的代码结构，我可以提供一个针对性的解决方案。

您的问题是在 OnRowInserting 事件中无法获取 FREQUENCY 字段的值，而其他字段可以正常获取。这主要是因为您使用了自定义的 EditItemTemplate 包含多个控件来组成一个字段值。

以下是一个适合您情况的解决方案：

### 解决方案1：使用隐藏字段和客户端脚本

这是最简单、最不侵入的解决方案。在您的 EditItemTemplate 中添加一个隐藏字段，然后使用客户端脚本在提交前合并值：

```aspx
<dx:GridViewDataColumn FieldName="FREQUENCY" Caption="频率">
  <EditItemTemplate>
    <div>
      <dx:ASPxSpinEdit ID="txtFreqCount" runat="server" Value='<%# GetFreqValue(Eval("FREQUENCY")) %>'
        ClientInstanceName="txtFreqCount">
        <ClientSideEvents ValueChanged="function(s, e) { UpdateFrequencyField(); }" />
      </dx:ASPxSpinEdit>
      
      <dx:ASPxSpinEdit ID="txtFreqUnitCount" runat="server" Value='<%# GetFreqUnitCounValue(Eval("FREQUENCY")) %>'
        ClientInstanceName="txtFreqUnitCount">
        <ClientSideEvents ValueChanged="function(s, e) { UpdateFrequencyField(); }" />
      </dx:ASPxSpinEdit>
      
      <dx:ASPxComboBox ID="cmbFreqUnit" runat="server" Value='<%# GetFreqUnitValue(Eval("FREQUENCY")) %>'
        ClientInstanceName="cmbFreqUnit">
        <Items>
          <dx:ListEditItem Text="天" Value="day" />
          <dx:ListEditItem Text="週" Value="week" />
        </Items>
        <ClientSideEvents SelectedIndexChanged="function(s, e) { UpdateFrequencyField(); }" />
      </dx:ASPxComboBox>
      
      <!-- 添加隐藏字段，使用实际的 FieldName -->
      <dx:ASPxTextBox ID="hiddenFrequency" runat="server" 
          ClientInstanceName="hiddenFrequency" 
          ClientVisible="false"
          Value='<%# Eval("FREQUENCY") %>'
          Name="FREQUENCY">
      </dx:ASPxTextBox>
    </div>
    
    <script type="text/javascript">
      function UpdateFrequencyField() {
        var value = txtFreqCount.GetValue();
        var unitCount = txtFreqUnitCount.GetValue();
        var unit = cmbFreqUnit.GetValue();
        hiddenFrequency.SetValue(value + '|' + unitCount + '|' + unit);
      }
      
      // 页面加载时初始化一次
      $(document).ready(function() {
        if (typeof txtFreqCount !== 'undefined' && 
            typeof txtFreqUnitCount !== 'undefined' && 
            typeof cmbFreqUnit !== 'undefined') {
          UpdateFrequencyField();
        }
      });
    </script>
  </EditItemTemplate>
</dx:GridViewDataColumn>
```

这样当您在 OnRowInserting 事件中，e.NewValues["FREQUENCY"] 就会包含合并后的值。

### 解决方案2：修改 OnRowInserting 事件处理

如果您不想或不能修改前端代码，可以尝试在后台事件中查找并获取控件值：

```csharp
protected void YourGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    ASPxGridView grid = sender as ASPxGridView;
    
    // 尝试方法1：使用GetChildControl查找
    Control newFormRow = grid.FindControl("DXInsertForm");
    
    ASPxSpinEdit txtFreqCount = null;
    ASPxSpinEdit txtFreqUnitCount = null;
    ASPxComboBox cmbFreqUnit = null;
    
    if (newFormRow != null)
    {
        // 可能需要调整控件查找的路径，您可能需要递归查找
        txtFreqCount = FindControlRecursive(newFormRow, "txtFreqCount") as ASPxSpinEdit;
        txtFreqUnitCount = FindControlRecursive(newFormRow, "txtFreqUnitCount") as ASPxSpinEdit;
        cmbFreqUnit = FindControlRecursive(newFormRow, "cmbFreqUnit") as ASPxComboBox;
    }
    
    // 如果找到了控件，从控件中获取值并合并
    if (txtFreqCount != null && txtFreqUnitCount != null && cmbFreqUnit != null)
    {
        string frequencyStr = string.Format("{0}|{1}|{2}", 
            txtFreqCount.Value, 
            txtFreqUnitCount.Value, 
            cmbFreqUnit.Value);
        
        e.NewValues["FREQUENCY"] = frequencyStr;
    }
    else
    {
        // 尝试方法2：从请求表单中获取值
        // DevExpress控件的ClientInstanceName会在提交表单时使用
        if (Page.Request.Form["txtFreqCount"] != null &&
            Page.Request.Form["txtFreqUnitCount"] != null &&
            Page.Request.Form["cmbFreqUnit"] != null)
        {
            string frequencyStr = string.Format("{0}|{1}|{2}", 
                Page.Request.Form["txtFreqCount"], 
                Page.Request.Form["txtFreqUnitCount"], 
                Page.Request.Form["cmbFreqUnit"]);
            
            e.NewValues["FREQUENCY"] = frequencyStr;
        }
        else
        {
            // 设置默认值
            e.NewValues["FREQUENCY"] = "1|1|day";
        }
    }
    
    // 继续处理其他值...
}

// 递归查找控件的辅助方法
private Control FindControlRecursive(Control root, string controlID)
{
    if (root.ID == controlID)
        return root;
        
    foreach (Control c in root.Controls)
    {
        Control found = FindControlRecursive(c, controlID);
        if (found != null)
            return found;
    }
    
    return null;
}
```

### 解决方案3：使用 ASPxCallback 或 ASPxCallbackPanel

如果上述两种方法都不适用，可以考虑使用 ASPxCallback 或 ASPxCallbackPanel 进行异步提交：

```aspx
<dx:ASPxCallback ID="freqCallback" runat="server" OnCallback="freqCallback_Callback" ClientInstanceName="freqCallback">
    <ClientSideEvents CallbackComplete="function(s, e) { 
        if (e.result) {
            // 提交成功后刷新网格
            ASPxGridView1.Refresh();
        }
    }" />
</dx:ASPxCallback>

<script type="text/javascript">
    function SubmitNewRow() {
        // 获取所有需要的值
        var freqCount = txtFreqCount.GetValue();
        var freqUnitCount = txtFreqUnitCount.GetValue();
        var freqUnit = cmbFreqUnit.GetValue();
        
        // 其他字段的值
        var otherField1 = someOtherControl.GetValue();
        
        // 通过回调提交数据
        freqCallback.PerformCallback(JSON.stringify({
            freqCount: freqCount,
            freqUnitCount: freqUnitCount,
            freqUnit: freqUnit,
            otherField1: otherField1
        }));
        
        return false; // 阻止默认提交
    }
</script>
```

然后在后台处理回调:

```csharp
protected void freqCallback_Callback(object source, DevExpress.Web.CallbackEventArgs e)
{
    // 解析JSON数据
    JavaScriptSerializer serializer = new JavaScriptSerializer();
    Dictionary<string, object> values = serializer.Deserialize<Dictionary<string, object>>(e.Parameter);
    
    // 组合频率值
    string freqCount = values["freqCount"].ToString();
    string freqUnitCount = values["freqUnitCount"].ToString();
    string freqUnit = values["freqUnit"].ToString();
    
    string frequencyStr = string.Format("{0}|{1}|{2}", freqCount, freqUnitCount, freqUnit);
    
    // 创建新行
    DataTable dt = ViewState["GridData"] as DataTable;
    DataRow newRow = dt.NewRow();
    newRow["FREQUENCY"] = frequencyStr;
    newRow["OtherField1"] = values["otherField1"];
    
    // 添加行并重新绑定
    dt.Rows.Add(newRow);
    ASPxGridView1.DataSource = dt;
    ASPxGridView1.DataBind();
    
    e.Result = "true"; // 返回成功标志
}
```

### 基于您现有代码的最佳建议：

考虑到您提供的信息和结构，我建议采用解决方案1（添加隐藏字段），这是最简单且侵入性最小的方法。如果您不能修改前端代码，那么解决方案2（修改后台代码查找控件）可能是您的最佳选择。

不管您选择哪种解决方案，为了调试目的，先在 OnRowInserting 事件中添加代码查看 e.NewValues 集合的内容：

```csharp
protected void YourGrid_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    string keys = string.Join(", ", e.NewValues.Keys.Cast<string>());
    string logMsg = "可用的键: " + keys;
    
    // 记录到日志或显示在页面上
    System.Diagnostics.Debug.WriteLine(logMsg);
    
    // 继续处理...
}
```

这将帮助您确认 FREQUENCY 字段是否确实缺失，以及哪些字段是可用的。

希望以上建议能够帮助您解决问题！​​​​​​​​​​​​​​​​