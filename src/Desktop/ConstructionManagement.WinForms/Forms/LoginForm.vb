Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms

Namespace Forms
    Public Class LoginForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            
            Dim materialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT
            materialSkinManager.ColorScheme = New ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE)
        End Sub

        Private Sub btnLogin_Click(sender As Object, e As EventArgs) Handles btnLogin.Click
            If txtUsername.Text = "admin" And txtPassword.Text = "admin" Then
                Dim mainForm As New MainForm()
                mainForm.Show()
                Me.Hide()
            Else
                MessageBox.Show("Invalid credentials.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If
        End Sub
    End Class
End Namespace
