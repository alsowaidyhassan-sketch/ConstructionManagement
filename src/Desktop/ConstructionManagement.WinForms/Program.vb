Imports System.Windows.Forms

Public Module ProgramModule
    <STAThread>
    Public Sub Main()
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New LoginForm())
    End Sub
End Module
