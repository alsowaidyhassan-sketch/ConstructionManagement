Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms
Imports ConstructionManagement.WinForms.Services

Namespace Forms
    Public Class MainForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            Dim materialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
        End Sub
        
        Private Async Sub MainForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            Try
                Dim projects = Await ApiClient.GetAsync(Of Object)("projects")
                dgvProjects.DataSource = projects
            Catch ex As Exception
                MessageBox.Show("خطأ في جلب البيانات.", "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End Try
        End Sub

        Private Sub btnCustomers_Click(sender As Object, e As EventArgs) Handles btnCustomers.Click
            Dim custForm As New CustomersForm()
            custForm.ShowDialog()
        End Sub
    End Class
End Namespace
