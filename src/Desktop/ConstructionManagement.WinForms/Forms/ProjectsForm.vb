Imports System.Windows.Forms
Imports System.Threading.Tasks
Imports MaterialSkin.Controls
Imports Newtonsoft.Json
Imports ConstructionManagement.WinForms.Services

Namespace Forms
    Public Class ProjectsForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
        End Sub

        Private Async Sub ProjectsForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            Await LoadProjects()
        End Sub

        Private Async Function LoadProjects() As Task
            Try
                Dim json = Await ApiClient.GetAsync(Of Object)("Projects")
                MessageBox.Show("تم تحميل المشاريع بنجاح")
            Catch ex As Exception
                MessageBox.Show("خطأ في تحميل المشاريع")
            End Try
        End Function
    End Class
End Namespace
