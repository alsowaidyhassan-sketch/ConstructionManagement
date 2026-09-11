Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms

Namespace Forms
    Public Class CustomersForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            
            Dim materialSkinManager As MaterialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT
            materialSkinManager.ColorScheme = New ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE)
        End Sub
        
        Private Sub CustomersForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            ' Mock loading customers from API
            dgvCustomers.Rows.Add("1", "شركة الأفق", "0500000000", "نشط")
            dgvCustomers.Rows.Add("2", "مؤسسة البناء", "0500000001", "نشط")
        End Sub
    End Class
End Namespace
