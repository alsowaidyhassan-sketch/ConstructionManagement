Imports System.Windows.Forms
Imports System.Threading.Tasks
Imports MaterialSkin.Controls
Imports Newtonsoft.Json

Public Class ProjectsForm
    Inherits MaterialForm

    Private ReadOnly _apiClient As ApiClient
    
    Public Sub New(apiClient As ApiClient)
        InitializeComponent()
        _apiClient = apiClient
    End Sub

    Private Async Sub ProjectsForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Await LoadProjects()
    End Sub

    Private Async Function LoadProjects() As Task
        Try
            Dim json = Await _apiClient.GetAsync("Projects")
            ' Assuming we parse this manually or using Newtonsoft
            MessageBox.Show("تم تحميل المشاريع بنجاح")
        Catch ex As Exception
            MessageBox.Show("خطأ في جلب المشاريع: " & ex.Message)
        End Try
    End Function
End Class
