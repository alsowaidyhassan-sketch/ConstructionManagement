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
