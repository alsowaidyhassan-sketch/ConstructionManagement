#!/bin/bash

# Fix WinForms project to net48
cat << 'PROJ' > src/Desktop/ConstructionManagement.WinForms/ConstructionManagement.WinForms.vbproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net48</TargetFramework>
    <StartupObject>ConstructionManagement.WinForms.My.MyApplication</StartupObject>
    <UseWindowsForms>true</UseWindowsForms>
    <MyType>WindowsForms</MyType>
    <LangVersion>latest</LangVersion>
  </PropertyGroup>
  <ItemGroup>
    <Import Include="System.Data" />
    <Import Include="System.Drawing" />
    <Import Include="System.Windows.Forms" />
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
    <PackageReference Include="MaterialSkin.2" Version="2.3.1" />
  </ItemGroup>
  <ItemGroup>
    <Reference Include="System.Net.Http" />
  </ItemGroup>
</Project>
PROJ

mkdir -p src/Desktop/ConstructionManagement.WinForms/Services
cat << 'CODE' > src/Desktop/ConstructionManagement.WinForms/Services/ApiClient.vb
Imports System.Net.Http
Imports System.Net.Http.Headers
Imports System.Text
Imports Newtonsoft.Json

Namespace Services
    Public Class ApiClient
        Private Shared ReadOnly _client As New HttpClient() With {.BaseAddress = New Uri("https://localhost:5001/api/v1/")}
        Private Shared _token As String = ""

        Public Shared Sub SetToken(token As String)
            _token = token
            _client.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", _token)
        End Sub

        Public Shared Async Function PostAsync(Of T)(endpoint As String, data As Object) As Task(Of T)
            Dim json = JsonConvert.SerializeObject(data)
            Dim content = New StringContent(json, Encoding.UTF8, "application/json")
            Dim response = Await _client.PostAsync(endpoint, content)
            response.EnsureSuccessStatusCode()
            Dim resultString = Await response.Content.ReadAsStringAsync()
            Return JsonConvert.DeserializeObject(Of T)(resultString)
        End Function

        Public Shared Async Function GetAsync(Of T)(endpoint As String) As Task(Of T)
            Dim response = Await _client.GetAsync(endpoint)
            response.EnsureSuccessStatusCode()
            Dim resultString = Await response.Content.ReadAsStringAsync()
            Return JsonConvert.DeserializeObject(Of T)(resultString)
        End Function
    End Class
End Namespace
CODE

cat << 'CODE' > src/Desktop/ConstructionManagement.WinForms/Forms/LoginForm.vb
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
CODE

cat << 'CODE' > src/Desktop/ConstructionManagement.WinForms/Forms/MainForm.vb
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
CODE

