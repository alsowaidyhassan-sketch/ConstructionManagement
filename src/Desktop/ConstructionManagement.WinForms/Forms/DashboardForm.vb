Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms
Imports ConstructionManagement.WinForms.Services

Namespace Forms
    Public Class DashboardForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            Dim materialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
        End Sub
        
        Private Async Sub DashboardForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            Try
                Dim stats = Await ApiClient.GetAsync(Of Object)("dashboard")
                lblTotalProjects.Text = "إجمالي المشاريع: " & stats("totalProjects").ToString()
                lblTotalPayments.Text = "المقبوضات: " & stats("totalPayments").ToString()
            Catch ex As Exception
                MessageBox.Show("خطأ في جلب بيانات لوحة القيادة.", "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End Try
        End Sub
    End Class
End Namespace
