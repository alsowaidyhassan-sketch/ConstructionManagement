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
