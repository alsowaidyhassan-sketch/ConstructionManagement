#!/bin/bash
# Refactor ApiClient to be robust
cat << 'VB' > src/Desktop/ConstructionManagement.WinForms/Services/ApiClient.vb
Imports System.Net.Http
Imports System.Net.Http.Headers
Imports System.Text
Imports Newtonsoft.Json
Imports System.Threading.Tasks
Imports System.Configuration ' Need this for real projects
Imports System.IO

Namespace Services
    Public Class ApiClient
        Private Shared ReadOnly _client As HttpClient
        Private Shared _token As String = ""
        ' Ideally this is loaded from App.config in a true WinForms prod app
        Private Shared ReadOnly _baseUrl As String = "https://localhost:5001/api/v1/"

        Shared Sub New()
            ' Disable SSL verification for development only, if needed. 
            ' In Prod, remove this handler injection.
            Dim handler As New HttpClientHandler()
            handler.ServerCertificateCustomValidationCallback = Function(message, cert, chain, errors) True
            
            _client = New HttpClient(handler)
            _client.BaseAddress = New Uri(_baseUrl)
            _client.Timeout = TimeSpan.FromSeconds(30)
        End Sub

        Public Shared Sub SetToken(token As String)
            _token = token
            _client.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", _token)
        End Sub

        Public Shared Async Function GetAsync(Of T)(endpoint As String) As Task(Of T)
            Dim response = Await _client.GetAsync(endpoint)
            Await EnsureSuccessWithBodyAsync(response)
            Dim json = Await response.Content.ReadAsStringAsync()
            Return JsonConvert.DeserializeObject(Of T)(json)
        End Function

        Public Shared Async Function PostAsync(Of TResult, TRequest)(endpoint As String, data As TRequest) As Task(Of TResult)
            Dim json = JsonConvert.SerializeObject(data)
            Dim content = New StringContent(json, Encoding.UTF8, "application/json")
            Dim response = Await _client.PostAsync(endpoint, content)
            Await EnsureSuccessWithBodyAsync(response)
            Dim responseJson = Await response.Content.ReadAsStringAsync()
            Return JsonConvert.DeserializeObject(Of TResult)(responseJson)
        End Function

        Public Shared Async Function PutAsync(Of TResult, TRequest)(endpoint As String, data As TRequest) As Task(Of TResult)
            Dim json = JsonConvert.SerializeObject(data)
            Dim content = New StringContent(json, Encoding.UTF8, "application/json")
            Dim response = Await _client.PutAsync(endpoint, content)
            Await EnsureSuccessWithBodyAsync(response)
            Dim responseJson = Await response.Content.ReadAsStringAsync()
            Return JsonConvert.DeserializeObject(Of TResult)(responseJson)
        End Function

        Public Shared Async Function DeleteAsync(endpoint As String) As Task(Of Boolean)
            Dim response = Await _client.DeleteAsync(endpoint)
            Await EnsureSuccessWithBodyAsync(response)
            Return True
        End Function
        
        Public Shared Async Function PostMultipartAsync(Of TResult)(endpoint As String, filePath As String, fileParamName As String, additionalFormData As Dictionary(Of String, String)) As Task(Of TResult)
            Using content = New MultipartFormDataContent()
                If additionalFormData IsNot Nothing Then
                    For Each kvp In additionalFormData
                        content.Add(New StringContent(kvp.Value), kvp.Key)
                    Next
                End If
                
                Dim fileBytes = Await File.ReadAllBytesAsync(filePath)
                Dim fileContent = New ByteArrayContent(fileBytes)
                fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("application/octet-stream")
                content.Add(fileContent, fileParamName, Path.GetFileName(filePath))

                Dim response = Await _client.PostAsync(endpoint, content)
                Await EnsureSuccessWithBodyAsync(response)
                Dim responseJson = Await response.Content.ReadAsStringAsync()
                Return JsonConvert.DeserializeObject(Of TResult)(responseJson)
            End Using
        End Function

        Private Shared Async Function EnsureSuccessWithBodyAsync(response As HttpResponseMessage) As Task
            If Not response.IsSuccessStatusCode Then
                Dim errorBody = Await response.Content.ReadAsStringAsync()
                ' If token is expired (401), we could intercept here and trigger Refresh Token logic
                Throw New HttpRequestException($"API Error: {response.StatusCode} - {errorBody}")
            End If
        End Function
    End Class
End Namespace
VB
