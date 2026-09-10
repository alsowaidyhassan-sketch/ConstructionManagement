<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class LoginForm
    Inherits MaterialSkin.Controls.MaterialForm

    'Form overrides dispose to clean up the component list.
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

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.txtUsername = New MaterialSkin.Controls.MaterialTextBox()
        Me.txtPassword = New MaterialSkin.Controls.MaterialTextBox()
        Me.btnLogin = New MaterialSkin.Controls.MaterialButton()
        Me.lblTitle = New MaterialSkin.Controls.MaterialLabel()
        Me.SuspendLayout()
        '
        'lblTitle
        '
        Me.lblTitle.AutoSize = True
        Me.lblTitle.Depth = 0
        Me.lblTitle.Font = New System.Drawing.Font("Roboto", 24.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Pixel)
        Me.lblTitle.Location = New System.Drawing.Point(120, 90)
        Me.lblTitle.MouseState = MaterialSkin.MouseState.HOVER
        Me.lblTitle.Name = "lblTitle"
        Me.lblTitle.Size = New System.Drawing.Size(150, 29)
        Me.lblTitle.TabIndex = 0
        Me.lblTitle.Text = "تسجيل الدخول"
        '
        'txtUsername
        '
        Me.txtUsername.AnimateReadOnly = False
        Me.txtUsername.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.txtUsername.Depth = 0
        Me.txtUsername.Font = New System.Drawing.Font("Roboto", 16.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel)
        Me.txtUsername.Hint = "اسم المستخدم"
        Me.txtUsername.Location = New System.Drawing.Point(50, 150)
        Me.txtUsername.MaxLength = 50
        Me.txtUsername.MouseState = MaterialSkin.MouseState.OUT
        Me.txtUsername.Multiline = False
        Me.txtUsername.Name = "txtUsername"
        Me.txtUsername.Size = New System.Drawing.Size(300, 50)
        Me.txtUsername.TabIndex = 1
        Me.txtUsername.Text = ""
        '
        'txtPassword
        '
        Me.txtPassword.AnimateReadOnly = False
        Me.txtPassword.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.txtPassword.Depth = 0
        Me.txtPassword.Font = New System.Drawing.Font("Roboto", 16.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel)
        Me.txtPassword.Hint = "كلمة المرور"
        Me.txtPassword.Location = New System.Drawing.Point(50, 220)
        Me.txtPassword.MaxLength = 50
        Me.txtPassword.MouseState = MaterialSkin.MouseState.OUT
        Me.txtPassword.Multiline = False
        Me.txtPassword.Name = "txtPassword"
        Me.txtPassword.Password = True
        Me.txtPassword.Size = New System.Drawing.Size(300, 50)
        Me.txtPassword.TabIndex = 2
        Me.txtPassword.Text = ""
        '
        'btnLogin
        '
        Me.btnLogin.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink
        Me.btnLogin.Density = MaterialSkin.Controls.MaterialButton.MaterialButtonDensity.Default
        Me.btnLogin.Depth = 0
        Me.btnLogin.HighEmphasis = True
        Me.btnLogin.Icon = Nothing
        Me.btnLogin.Location = New System.Drawing.Point(150, 300)
        Me.btnLogin.Margin = New System.Windows.Forms.Padding(4, 6, 4, 6)
        Me.btnLogin.MouseState = MaterialSkin.MouseState.HOVER
        Me.btnLogin.Name = "btnLogin"
        Me.btnLogin.NoAccentTextColor = System.Drawing.Color.Empty
        Me.btnLogin.Size = New System.Drawing.Size(100, 36)
        Me.btnLogin.TabIndex = 3
        Me.btnLogin.Text = "دخول"
        Me.btnLogin.Type = MaterialSkin.Controls.MaterialButton.MaterialButtonType.Contained
        Me.btnLogin.UseAccentColor = False
        Me.btnLogin.UseVisualStyleBackColor = True
        '
        'LoginForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(400, 400)
        Me.Controls.Add(Me.btnLogin)
        Me.Controls.Add(Me.txtPassword)
        Me.Controls.Add(Me.txtUsername)
        Me.Controls.Add(Me.lblTitle)
        Me.Name = "LoginForm"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Construction Management - Login"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

    Friend WithEvents txtUsername As MaterialSkin.Controls.MaterialTextBox
    Friend WithEvents txtPassword As MaterialSkin.Controls.MaterialTextBox
    Friend WithEvents btnLogin As MaterialSkin.Controls.MaterialButton
    Friend WithEvents lblTitle As MaterialSkin.Controls.MaterialLabel
End Class
