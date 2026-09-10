#!/bin/bash
mkdir -p src/Desktop/ConstructionManagement.WinForms/Forms

# Create base files for WinForms UI
cat << 'CS' > src/Desktop/ConstructionManagement.WinForms/Forms/ProjectsForm.vb
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
CS

cat << 'CS' > src/Desktop/ConstructionManagement.WinForms/Forms/ProjectsForm.Designer.vb
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class ProjectsForm
    Inherits MaterialSkin.Controls.MaterialForm

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(800, 450)
        Me.Text = "إدارة المشاريع"
    End Sub

End Class
CS

cat << 'CS' > src/Desktop/ConstructionManagement.WinForms/Forms/ProjectsForm.resx
<?xml version="1.0" encoding="utf-8"?>
<root>
  <resheader name="resmimetype">
    <value>text/microsoft-resx</value>
  </resheader>
  <resheader name="version">
    <value>2.0</value>
  </resheader>
  <resheader name="reader">
    <value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
  </resheader>
  <resheader name="writer">
    <value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
  </resheader>
</root>
CS

# Update ApiClient Base URL logic
sed -i 's/Private ReadOnly _baseUrl As String = "http:\/\/localhost:5000\/api\/v1\/"/Private ReadOnly _baseUrl As String = ConfigurationManager.AppSettings("ApiBaseUrl")/g' src/Desktop/ConstructionManagement.WinForms/Services/ApiClient.vb
