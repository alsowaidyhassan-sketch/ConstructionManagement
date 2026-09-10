#!/bin/bash
mkdir -p src/Desktop/ConstructionManagement.WinForms/Forms
mkdir -p src/Mobile/ConstructionManagement.Mobile/Views

# Desktop: DashboardForm
cat << 'VB' > src/Desktop/ConstructionManagement.WinForms/Forms/DashboardForm.vb
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
VB

cat << 'VB' > src/Desktop/ConstructionManagement.WinForms/Forms/DashboardForm.Designer.vb
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DashboardForm
    Inherits MaterialSkin.Controls.MaterialForm

    Private components As System.ComponentModel.IContainer

    Private Sub InitializeComponent()
        Me.lblTotalProjects = New MaterialSkin.Controls.MaterialLabel()
        Me.lblTotalPayments = New MaterialSkin.Controls.MaterialLabel()
        Me.SuspendLayout()
        
        Me.lblTotalProjects.AutoSize = True
        Me.lblTotalProjects.Depth = 0
        Me.lblTotalProjects.Location = New System.Drawing.Point(50, 100)
        Me.lblTotalProjects.Name = "lblTotalProjects"
        Me.lblTotalProjects.Size = New System.Drawing.Size(120, 19)
        Me.lblTotalProjects.Text = "إجمالي المشاريع: "
        
        Me.lblTotalPayments.AutoSize = True
        Me.lblTotalPayments.Depth = 0
        Me.lblTotalPayments.Location = New System.Drawing.Point(50, 150)
        Me.lblTotalPayments.Name = "lblTotalPayments"
        Me.lblTotalPayments.Size = New System.Drawing.Size(120, 19)
        Me.lblTotalPayments.Text = "المقبوضات: "
        
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(800, 450)
        Me.Controls.Add(Me.lblTotalProjects)
        Me.Controls.Add(Me.lblTotalPayments)
        Me.Name = "DashboardForm"
        Me.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.RightToLeftLayout = True
        Me.Text = "لوحة القيادة"
        Me.ResumeLayout(False)
    End Sub

    Friend WithEvents lblTotalProjects As MaterialSkin.Controls.MaterialLabel
    Friend WithEvents lblTotalPayments As MaterialSkin.Controls.MaterialLabel
End Class
VB

# Mobile: Update ProjectDetailsPage with comprehensive tabs equivalent
cat << 'MAUI' > src/Mobile/ConstructionManagement.Mobile/Views/ProjectDetailsPage.xaml
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="ConstructionManagement.Mobile.Views.ProjectDetailsPage"
             Title="تفاصيل المشروع الشاملة"
             BackgroundColor="{StaticResource Background}"
             FlowDirection="RightToLeft">
    <ScrollView>
        <VerticalStackLayout Padding="20" Spacing="20">
            <!-- Project Info -->
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <VerticalStackLayout Spacing="10">
                    <Label Text="فيلا الرمال" FontSize="22" FontAttributes="Bold" TextColor="{StaticResource Primary}" />
                    <Label Text="قيمة العقد: 1,500,000 ريال" TextColor="Gray" />
                    <Label Text="الإنجاز الكلي: 45%" TextColor="Gray" />
                    <ProgressBar Progress="0.45" ProgressColor="{StaticResource Primary}" />
                </VerticalStackLayout>
            </Frame>
            
            <!-- Timeline & Stages -->
            <Label Text="المراحل (Timeline)" FontSize="18" FontAttributes="Bold" />
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <VerticalStackLayout Spacing="10">
                    <Label Text="1. الحفر والأساسات - مكتمل" TextColor="Green" />
                    <Label Text="2. العظم والدور الأول - جاري العمل (60%)" TextColor="Orange" />
                    <Label Text="3. التشطيبات - قيد الانتظار" TextColor="Gray" />
                </VerticalStackLayout>
            </Frame>

            <!-- Actions -->
            <Grid ColumnDefinitions="*,*" RowDefinitions="Auto,Auto" ColumnSpacing="10" RowSpacing="10">
                <Button Grid.Row="0" Grid.Column="0" Text="الدفعات" BackgroundColor="{StaticResource Primary}" TextColor="White" Clicked="OnPaymentsClicked" CornerRadius="8" />
                <Button Grid.Row="0" Grid.Column="1" Text="المستندات" BackgroundColor="Transparent" BorderColor="{StaticResource Primary}" BorderWidth="1" TextColor="{StaticResource Primary}" CornerRadius="8" />
                <Button Grid.Row="1" Grid.Column="0" Text="الصور" BackgroundColor="Transparent" BorderColor="{StaticResource Primary}" BorderWidth="1" TextColor="{StaticResource Primary}" CornerRadius="8" />
                <Button Grid.Row="1" Grid.Column="1" Text="أوامر التغيير" BackgroundColor="Transparent" BorderColor="{StaticResource Primary}" BorderWidth="1" TextColor="{StaticResource Primary}" CornerRadius="8" />
            </Grid>
        </VerticalStackLayout>
    </ScrollView>
</ContentPage>
MAUI
