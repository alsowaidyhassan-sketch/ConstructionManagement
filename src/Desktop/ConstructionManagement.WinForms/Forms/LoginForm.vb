Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms
Imports ConstructionManagement.WinForms.Services

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

        Private Async Sub btnLogin_Click(sender As Object, e As EventArgs) Handles btnLogin.Click
            Try
                Dim loginData = New With { .UserName = txtUsername.Text, .Password = txtPassword.Text }
                Dim response = Await ApiClient.PostAsync(Of Object)("auth/login", loginData)
                
                ApiClient.SetToken(response("token").ToString())
                
                Dim mainForm As New MainForm()
                mainForm.Show()
                Me.Hide()
            Catch ex As Exception
                MessageBox.Show("خطأ في تسجيل الدخول. يرجى التأكد من اسم المستخدم وكلمة المرور.", "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End Try
        End Sub
    End Class
End Namespace
