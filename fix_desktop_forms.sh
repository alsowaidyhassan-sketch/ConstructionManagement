#!/bin/bash
# Adding some crucial missing forms for the Desktop
cat << 'VB' > src/Desktop/ConstructionManagement.WinForms/Forms/ContractsForm.vb
Imports MaterialSkin.Controls
Imports ConstructionManagement.WinForms.Services
Imports System.Windows.Forms

Namespace Forms
    Public Class ContractsForm
        Inherits MaterialForm
        
        Public Sub New()
            InitializeComponent()
            Dim materialSkinManager = MaterialSkin.MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
        End Sub

        Private Async Sub ContractsForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            ' Fetch Contracts logic using ApiClient goes here
            lblStatus.Text = "جاهز لعرض العقود"
        End Sub
    End Class
End Namespace
VB

cat << 'VB' > src/Desktop/ConstructionManagement.WinForms/Forms/ContractsForm.Designer.vb
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
VB

