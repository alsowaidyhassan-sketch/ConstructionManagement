Imports System.Windows.Forms
Imports ConstructionManagement.WinForms.Forms

Namespace ConstructionManagement.WinForms
    Public Module ProgramModule
        <STAThread>
        Public Sub Main()
            Application.EnableVisualStyles()
            Application.SetCompatibleTextRenderingDefault(False)
            Application.Run(New LoginForm())
        End Sub
    End Module
End Namespace
