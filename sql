好的，我來提供完整的 ASPX 和后台代码，确保我们对您的需求理解一致。以下是一个完整的例子，包括 ASPX 页面和对应的代码后台：

**ASPX 页面：**

```aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GridViewExample.aspx.cs" Inherits="YourNamespace.GridViewExample" %>

<%@ Register Assembly="DevExpress.Web.v19.2, Version=19.2.0.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" 
    Namespace="DevExpress.Web" TagPrefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>GridView 频率编辑示例</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dx:ASPxGridView ID="ASPxGridView1" runat="server" KeyFieldName="ID" 
                OnRowUpdating="ASPxGridView1_RowUpdating" 
                OnRowInserting="ASPxGridView1_RowInserting"
                Width="100%" AutoGenerateColumns="False">
                <SettingsEditing Mode="Inline" NewItemRowPosition="Top" />
                <SettingsCommandButton>
                    <NewButton Text="新增" />
                    <EditButton Text="编辑" />
                    <DeleteButton Text="删除" />
                    <UpdateButton Text="保存" />
                    <CancelButton Text="取消" />
                </SettingsCommandButton>
                <Columns>
                    <dx:GridViewCommandColumn ShowEditButton="true" ShowNewButtonInHeader="true" ShowDeleteButton="true" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="true" Caption="ID" Width="50" />
                    <dx:GridViewDataTextColumn FieldName="Name" Caption="名称" Width="150" />
                    <dx:GridViewDataTextColumn FieldName="frequency" Caption="频率" Width="200">
                        <EditItemTemplate>
                            <div style="display: flex; align-items: center;">
                                <!-- 频率值控件 -->
                                <dx:ASPxSpinEdit ID="spinEditValue" runat="server" 
                                    Width="80px" 
                                    MinValue="1" 
                                    MaxValue="100" 
                                    Value='<%# GetFrequencyValue(Eval("frequency")) %>'
                                    ClientInstanceName="spinEditValue">
                                </dx:ASPxSpinEdit>
                                
                                <!-- 频率单位数量控件 -->
                                <dx:ASPxSpinEdit ID="spinEditUnitCount" runat="server" 
                                    Width="80px" 
                                    MinValue="1" 
                                    MaxValue="100" 
                                    Value='<%# GetFrequencyUnitCount(Eval("frequency")) %>'
                                    ClientInstanceName="spinEditUnitCount">
                                </dx:ASPxSpinEdit>
                                
                                <!-- 频率单位控件 -->
                                <dx:ASPxComboBox ID="comboBoxUnit" runat="server" 
                                    Width="100px" 
                                    Value='<%# GetFrequencyUnit(Eval("frequency")) %>'
                                    ClientInstanceName="comboBoxUnit">
                                    <Items>
                                        <dx:ListEditItem Text="秒" Value="second" />
                                        <dx:ListEditItem Text="分钟" Value="minute" />
                                        <dx:ListEditItem Text="小时" Value="hour" />
                                        <dx:ListEditItem Text="天" Value="day" />
                                        <dx:ListEditItem Text="周" Value="week" />
                                        <dx:ListEditItem Text="月" Value="month" />
                                    </Items>
                                </dx:ASPxComboBox>
                            </div>
                        </EditItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <!-- 其他列 -->
                </Columns>
            </dx:ASPxGridView>
        </div>
    </form>
</body>
</html>
```

**代码后台（GridViewExample.aspx.cs）：**

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;

namespace YourNamespace
{
    public partial class GridViewExample : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 绑定数据源
                BindGridView();
            }
        }

        private void BindGridView()
        {
            // 创建示例数据
            DataTable dt = new DataTable();
            dt.Columns.Add("ID", typeof(int));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("frequency", typeof(string));

            // 添加示例数据
            dt.Rows.Add(1, "任务1", "2|3|hour");    // 每3小时执行2次
            dt.Rows.Add(2, "任务2", "1|1|day");     // 每1天执行1次
            dt.Rows.Add(3, "任务3", "5|2|week");    // 每2周执行5次

            ASPxGridView1.DataSource = dt;
            ASPxGridView1.DataBind();

            // 保存到 ViewState 中以便在回发后使用
            ViewState["GridData"] = dt;
        }

        // 从频率字符串中提取值部分（格式：值|单位数量|单位）
        protected object GetFrequencyValue(object frequency)
        {
            if (frequency == null || string.IsNullOrEmpty(frequency.ToString()))
                return 1;

            string[] parts = frequency.ToString().Split('|');
            if (parts.Length >= 1)
            {
                int value;
                if (int.TryParse(parts[0], out value))
                    return value;
            }
            return 1;
        }

        // 从频率字符串中提取单位数量部分
        protected object GetFrequencyUnitCount(object frequency)
        {
            if (frequency == null || string.IsNullOrEmpty(frequency.ToString()))
                return 1;

            string[] parts = frequency.ToString().Split('|');
            if (parts.Length >= 2)
            {
                int unitCount;
                if (int.TryParse(parts[1], out unitCount))
                    return unitCount;
            }
            return 1;
        }

        // 从频率字符串中提取单位部分
        protected object GetFrequencyUnit(object frequency)
        {
            if (frequency == null || string.IsNullOrEmpty(frequency.ToString()))
                return "day";

            string[] parts = frequency.ToString().Split('|');
            if (parts.Length >= 3)
                return parts[2];
            
            return "day";
        }

        // 行更新事件 - 在这里可以成功获取控件值
        protected void ASPxGridView1_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
        {
            // 查找编辑行中的控件
            ASPxGridView grid = sender as ASPxGridView;
            
            // 使用 FindEditRowCellTemplateControl 方法找到控件
            ASPxSpinEdit spinEditValue = grid.FindEditRowCellTemplateControl(
                grid.Columns["frequency"] as GridViewDataColumn, "spinEditValue") as ASPxSpinEdit;
                
            ASPxSpinEdit spinEditUnitCount = grid.FindEditRowCellTemplateControl(
                grid.Columns["frequency"] as GridViewDataColumn, "spinEditUnitCount") as ASPxSpinEdit;
                
            ASPxComboBox comboBoxUnit = grid.FindEditRowCellTemplateControl(
                grid.Columns["frequency"] as GridViewDataColumn, "comboBoxUnit") as ASPxComboBox;

            if (spinEditValue != null && spinEditUnitCount != null && comboBoxUnit != null)
            {
                // 组合成频率字符串
                string frequencyStr = string.Format("{0}|{1}|{2}", 
                    spinEditValue.Value, 
                    spinEditUnitCount.Value, 
                    comboBoxUnit.Value);
                
                e.NewValues["frequency"] = frequencyStr;
            }

            // 更新数据源
            DataTable dt = ViewState["GridData"] as DataTable;
            if (dt != null)
            {
                DataRow row = dt.Rows.Find(e.Keys["ID"]);
                if (row != null)
                {
                    foreach (string key in e.NewValues.Keys)
                    {
                        row[key] = e.NewValues[key];
                    }
                }
                ViewState["GridData"] = dt;
                ASPxGridView1.DataSource = dt;
                ASPxGridView1.DataBind();
            }

            e.Cancel = true; // 取消默认更新，因为我们手动更新了
        }

        // 行插入事件 - 这里之前无法获取控件值
        protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
        {
            ASPxGridView grid = sender as ASPxGridView;
            
            // 方法1：尝试使用类似 FindEditRowCellTemplateControl 的方式（但需要调整）
            GridViewDataColumn freqColumn = grid.Columns["frequency"] as GridViewDataColumn;
            
            // 尝试找到新行中的控件
            ASPxSpinEdit spinEditValue = null;
            ASPxSpinEdit spinEditUnitCount = null;
            ASPxComboBox comboBoxUnit = null;
            
            // 遍历所有控件查找我们需要的
            Control container = grid.FindControl("DXInsertForm");
            if (container != null)
            {
                spinEditValue = FindControlRecursive(container, "spinEditValue") as ASPxSpinEdit;
                spinEditUnitCount = FindControlRecursive(container, "spinEditUnitCount") as ASPxSpinEdit;
                comboBoxUnit = FindControlRecursive(container, "comboBoxUnit") as ASPxComboBox;
            }
            
            // 方法2：尝试使用 HttpContext.Current.Request.Form 获取前端提交的值
            if (spinEditValue == null || spinEditUnitCount == null || comboBoxUnit == null)
            {
                // 获取前端控件提交的表单值
                string valueKey = "spinEditValue";
                string unitCountKey = "spinEditUnitCount";
                string unitKey = "comboBoxUnit";
                
                object value = null;
                object unitCount = null;
                object unit = null;
                
                // 从表单中获取值
                if (HttpContext.Current.Request.Form[valueKey] != null)
                    value = HttpContext.Current.Request.Form[valueKey];
                
                if (HttpContext.Current.Request.Form[unitCountKey] != null)
                    unitCount = HttpContext.Current.Request.Form[unitCountKey];
                
                if (HttpContext.Current.Request.Form[unitKey] != null)
                    unit = HttpContext.Current.Request.Form[unitKey];
                
                // 如果能够获取到这些值，组合成频率字符串
                if (value != null && unitCount != null && unit != null)
                {
                    e.NewValues["frequency"] = string.Format("{0}|{1}|{2}", value, unitCount, unit);
                }
                else
                {
                    // 设置默认值
                    e.NewValues["frequency"] = "1|1|day";
                }
            }
            else
            {
                // 如果成功找到了控件，从控件中获取值
                string frequencyStr = string.Format("{0}|{1}|{2}", 
                    spinEditValue.Value, 
                    spinEditUnitCount.Value, 
                    comboBoxUnit.Value);
                
                e.NewValues["frequency"] = frequencyStr;
            }

            // 更新数据源
            DataTable dt = ViewState["GridData"] as DataTable;
            if (dt != null)
            {
                DataRow row = dt.NewRow();
                row["ID"] = dt.Rows.Count + 1; // 自动生成 ID
                
                foreach (string key in e.NewValues.Keys)
                {
                    if (dt.Columns.Contains(key))
                        row[key] = e.NewValues[key];
                }
                
                dt.Rows.Add(row);
                ViewState["GridData"] = dt;
                ASPxGridView1.DataSource = dt;
                ASPxGridView1.DataBind();
            }

            e.Cancel = true; // 取消默认插入，因为我们手动插入了
        }
        
        // 递归查找控件
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
    }
}
```

这个示例包含了完整的 ASPX 页面和后台代码，实现了您的需求：

1. 使用了 DevExpress 19.2 的 ASPxGridView 控件和内联编辑模式
2. 在频率列中使用了三个控件：ASPxSpinEdit (值)、ASPxSpinEdit (单位数量) 和 ASPxComboBox (单位)
3. 在行更新 (OnRowUpdating) 事件中使用 FindEditRowCellTemplateControl 方法成功获取控件值
4. 在行插入 (OnRowInserting) 事件中提供了两种方法尝试获取控件值:
   - 通过递归查找控件
   - 直接从表单提交中获取值

您在实际使用中可能需要根据您的具体项目结构和数据源调整代码，特别是数据绑定和保存的部分。但这个示例应该能够解决您在 OnRowInserting 事件中无法获取控件值的问题。

希望这个完整的示例能够帮助您解决问题！如果您还有任何疑问或需要进一步的调整，请告诉我。​​​​​​​​​​​​​​​​