<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class MainForm
    Inherits MaterialSkin.Controls.MaterialForm

    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    Private components As System.ComponentModel.IContainer

    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.materialTabControl1 = New MaterialSkin.Controls.MaterialTabControl()
        Me.tabDashboard = New System.Windows.Forms.TabPage()
        Me.lblTotalProjects = New MaterialSkin.Controls.MaterialLabel()
        Me.lblActiveProjects = New MaterialSkin.Controls.MaterialLabel()
        Me.tabProjects = New System.Windows.Forms.TabPage()
        Me.dgvProjects = New System.Windows.Forms.DataGridView()
        Me.materialTabControl1.SuspendLayout()
        Me.tabDashboard.SuspendLayout()
        Me.tabProjects.SuspendLayout()
        CType(Me.dgvProjects, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'materialTabControl1
        '
        Me.materialTabControl1.Controls.Add(Me.tabDashboard)
        Me.materialTabControl1.Controls.Add(Me.tabProjects)
        Me.materialTabControl1.Depth = 0
        Me.materialTabControl1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.materialTabControl1.Location = New System.Drawing.Point(3, 64)
        Me.materialTabControl1.MouseState = MaterialSkin.MouseState.HOVER
        Me.materialTabControl1.Multiline = True
        Me.materialTabControl1.Name = "materialTabControl1"
        Me.materialTabControl1.SelectedIndex = 0
        Me.materialTabControl1.Size = New System.Drawing.Size(994, 533)
        Me.materialTabControl1.TabIndex = 0
        '
        'tabDashboard
        '
        Me.tabDashboard.Controls.Add(Me.lblActiveProjects)
        Me.tabDashboard.Controls.Add(Me.lblTotalProjects)
        Me.tabDashboard.Location = New System.Drawing.Point(4, 24)
        Me.tabDashboard.Name = "tabDashboard"
        Me.tabDashboard.Padding = New System.Windows.Forms.Padding(3)
        Me.tabDashboard.Size = New System.Drawing.Size(986, 505)
        Me.tabDashboard.TabIndex = 0
        Me.tabDashboard.Text = "لوحة القيادة"
        Me.tabDashboard.UseVisualStyleBackColor = True
        '
        'lblTotalProjects
        '
        Me.lblTotalProjects.AutoSize = True
        Me.lblTotalProjects.Depth = 0
        Me.lblTotalProjects.Font = New System.Drawing.Font("Roboto", 14.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel)
        Me.lblTotalProjects.Location = New System.Drawing.Point(800, 50)
        Me.lblTotalProjects.MouseState = MaterialSkin.MouseState.HOVER
        Me.lblTotalProjects.Name = "lblTotalProjects"
        Me.lblTotalProjects.Size = New System.Drawing.Size(120, 19)
        Me.lblTotalProjects.TabIndex = 0
        Me.lblTotalProjects.Text = "إجمالي المشاريع: 0"
        '
        'lblActiveProjects
        '
        Me.lblActiveProjects.AutoSize = True
        Me.lblActiveProjects.Depth = 0
        Me.lblActiveProjects.Font = New System.Drawing.Font("Roboto", 14.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel)
        Me.lblActiveProjects.Location = New System.Drawing.Point(800, 100)
        Me.lblActiveProjects.MouseState = MaterialSkin.MouseState.HOVER
        Me.lblActiveProjects.Name = "lblActiveProjects"
        Me.lblActiveProjects.Size = New System.Drawing.Size(120, 19)
        Me.lblActiveProjects.TabIndex = 1
        Me.lblActiveProjects.Text = "المشاريع النشطة: 0"
        '
        'tabProjects
        '
        Me.tabProjects.Controls.Add(Me.dgvProjects)
        Me.tabProjects.Location = New System.Drawing.Point(4, 24)
        Me.tabProjects.Name = "tabProjects"
        Me.tabProjects.Padding = New System.Windows.Forms.Padding(3)
        Me.tabProjects.Size = New System.Drawing.Size(986, 505)
        Me.tabProjects.TabIndex = 1
        Me.tabProjects.Text = "المشاريع"
        Me.tabProjects.UseVisualStyleBackColor = True
        '
        'dgvProjects
        '
        Me.dgvProjects.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgvProjects.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvProjects.Location = New System.Drawing.Point(3, 3)
        Me.dgvProjects.Name = "dgvProjects"
        Me.dgvProjects.RowTemplate.Height = 25
        Me.dgvProjects.Size = New System.Drawing.Size(980, 499)
        Me.dgvProjects.TabIndex = 0
        '
        'MainForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(1000, 600)
        Me.Controls.Add(Me.materialTabControl1)
        Me.DrawerTabControl = Me.materialTabControl1
        Me.Name = "MainForm"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Construction Management System"
        Me.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.RightToLeftLayout = True
        Me.materialTabControl1.ResumeLayout(False)
        Me.tabDashboard.ResumeLayout(False)
        Me.tabDashboard.PerformLayout()
        Me.tabProjects.ResumeLayout(False)
        CType(Me.dgvProjects, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub

    Friend WithEvents materialTabControl1 As MaterialSkin.Controls.MaterialTabControl
    Friend WithEvents tabDashboard As System.Windows.Forms.TabPage
    Friend WithEvents tabProjects As System.Windows.Forms.TabPage
    Friend WithEvents lblTotalProjects As MaterialSkin.Controls.MaterialLabel
    Friend WithEvents lblActiveProjects As MaterialSkin.Controls.MaterialLabel
    Friend WithEvents dgvProjects As System.Windows.Forms.DataGridView
End Class
