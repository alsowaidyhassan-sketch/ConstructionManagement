<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DashboardForm
    Inherits MaterialSkin.Controls.MaterialForm

    Private components As System.ComponentModel.IContainer

    Private Sub InitializeComponent()
        Me.lblTotalProjects = New MaterialSkin.Controls.MaterialLabel()
        Me.lblTotalPayments = New MaterialSkin.Controls.MaterialLabel()
        Me.SuspendLayout()
        
        Me.lblTotalProjects.AutoSize = True
        Me.lblTotalProjects.Depth = 0
        Me.lblTotalProjects.Location = New System.Drawing.Point(50, 100)
        Me.lblTotalProjects.Name = "lblTotalProjects"
        Me.lblTotalProjects.Size = New System.Drawing.Size(120, 19)
        Me.lblTotalProjects.Text = "إجمالي المشاريع: "
        
        Me.lblTotalPayments.AutoSize = True
        Me.lblTotalPayments.Depth = 0
        Me.lblTotalPayments.Location = New System.Drawing.Point(50, 150)
        Me.lblTotalPayments.Name = "lblTotalPayments"
        Me.lblTotalPayments.Size = New System.Drawing.Size(120, 19)
        Me.lblTotalPayments.Text = "المقبوضات: "
        
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(800, 450)
        Me.Controls.Add(Me.lblTotalProjects)
        Me.Controls.Add(Me.lblTotalPayments)
        Me.Name = "DashboardForm"
        Me.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.RightToLeftLayout = True
        Me.Text = "لوحة القيادة"
        Me.ResumeLayout(False)
    End Sub

    Friend WithEvents lblTotalProjects As MaterialSkin.Controls.MaterialLabel
    Friend WithEvents lblTotalPayments As MaterialSkin.Controls.MaterialLabel
End Class
