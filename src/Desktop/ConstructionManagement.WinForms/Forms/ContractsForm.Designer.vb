Namespace Forms
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class ContractsForm
    Inherits MaterialSkin.Controls.MaterialForm

    Private components As System.ComponentModel.IContainer
    Friend WithEvents lblStatus As MaterialSkin.Controls.MaterialLabel

    Private Sub InitializeComponent()
        Me.lblStatus = New MaterialSkin.Controls.MaterialLabel()
        Me.SuspendLayout()
        '
        'lblStatus
        '
        Me.lblStatus.AutoSize = True
        Me.lblStatus.Depth = 0
        Me.lblStatus.Location = New System.Drawing.Point(50, 100)
        Me.lblStatus.Name = "lblStatus"
        Me.lblStatus.Size = New System.Drawing.Size(120, 19)
        Me.lblStatus.Text = "جاري التحميل..."
        '
        'ContractsForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(800, 450)
        Me.Controls.Add(Me.lblStatus)
        Me.Name = "ContractsForm"
        Me.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.RightToLeftLayout = True
        Me.Text = "إدارة العقود"
        Me.ResumeLayout(False)
    End Sub
End Class
End Namespace
