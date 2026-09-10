Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms

Namespace Forms
    Public Class MainForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            
            Dim materialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT
            materialSkinManager.ColorScheme = New ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE)
        End Sub
        
        Private Sub MainForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            ' Load Dashboard Data
            lblTotalProjects.Text = "إجمالي المشاريع: 15"
            lblActiveProjects.Text = "المشاريع النشطة: 8"
        End Sub
    End Class
End Namespace
