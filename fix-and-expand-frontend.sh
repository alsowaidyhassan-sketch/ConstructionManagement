#!/bin/bash

# 1. Desktop - CustomersForm.vb
cat << 'FORM' > src/Desktop/ConstructionManagement.WinForms/Forms/CustomersForm.vb
Imports MaterialSkin
Imports MaterialSkin.Controls
Imports System.Windows.Forms

Namespace Forms
    Public Class CustomersForm
        Inherits MaterialForm

        Public Sub New()
            InitializeComponent()
            
            Dim materialSkinManager = MaterialSkinManager.Instance
            materialSkinManager.AddFormToManage(Me)
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT
            materialSkinManager.ColorScheme = New ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE)
        End Sub
        
        Private Sub CustomersForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
            ' Mock loading customers from API
            dgvCustomers.Rows.Add("1", "شركة الأفق", "0500000000", "نشط")
            dgvCustomers.Rows.Add("2", "مؤسسة البناء", "0500000001", "نشط")
        End Sub
    End Class
End Namespace
FORM

cat << 'FORM' > src/Desktop/ConstructionManagement.WinForms/Forms/CustomersForm.Designer.vb
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class CustomersForm
    Inherits MaterialSkin.Controls.MaterialForm

    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    Private components As System.ComponentModel.IContainer

    Private Sub InitializeComponent()
        Me.dgvCustomers = New System.Windows.Forms.DataGridView()
        Me.colId = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.colName = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.colPhone = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.colStatus = New System.Windows.Forms.DataGridViewTextBoxColumn()
        CType(Me.dgvCustomers, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'dgvCustomers
        '
        Me.dgvCustomers.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgvCustomers.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.colId, Me.colName, Me.colPhone, Me.colStatus})
        Me.dgvCustomers.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.dgvCustomers.Location = New System.Drawing.Point(3, 80)
        Me.dgvCustomers.Name = "dgvCustomers"
        Me.dgvCustomers.Size = New System.Drawing.Size(794, 367)
        Me.dgvCustomers.TabIndex = 0
        '
        'colId
        '
        Me.colId.HeaderText = "الرقم"
        Me.colId.Name = "colId"
        '
        'colName
        '
        Me.colName.HeaderText = "الاسم"
        Me.colName.Name = "colName"
        Me.colName.Width = 250
        '
        'colPhone
        '
        Me.colPhone.HeaderText = "الجوال"
        Me.colPhone.Name = "colPhone"
        Me.colPhone.Width = 150
        '
        'colStatus
        '
        Me.colStatus.HeaderText = "الحالة"
        Me.colStatus.Name = "colStatus"
        '
        'CustomersForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(800, 450)
        Me.Controls.Add(Me.dgvCustomers)
        Me.Name = "CustomersForm"
        Me.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.RightToLeftLayout = True
        Me.Text = "إدارة العملاء"
        CType(Me.dgvCustomers, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub

    Friend WithEvents dgvCustomers As System.Windows.Forms.DataGridView
    Friend WithEvents colId As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colName As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colPhone As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colStatus As System.Windows.Forms.DataGridViewTextBoxColumn
End Class
FORM

# 2. Mobile - ProjectDetailsPage & PaymentsPage
cat << 'MAUI' > src/Mobile/ConstructionManagement.Mobile/Views/ProjectDetailsPage.xaml
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="ConstructionManagement.Mobile.Views.ProjectDetailsPage"
             Title="تفاصيل المشروع"
             BackgroundColor="{StaticResource Background}"
             FlowDirection="RightToLeft">
    <ScrollView>
        <VerticalStackLayout Padding="20" Spacing="20">
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <VerticalStackLayout Spacing="10">
                    <Label Text="فيلا الرمال" FontSize="22" FontAttributes="Bold" TextColor="{StaticResource Primary}" />
                    <Label Text="رقم العقد: 1001" TextColor="Gray" />
                    <Label Text="تاريخ البدء: 2024-01-01" TextColor="Gray" />
                </VerticalStackLayout>
            </Frame>
            <Label Text="المراحل (Timeline)" FontSize="18" FontAttributes="Bold" />
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <VerticalStackLayout Spacing="10">
                    <Label Text="1. الحفر والأساسات - مكتمل" TextColor="Green" />
                    <Label Text="2. العظم والدور الأول - جاري العمل (60%)" TextColor="Orange" />
                    <Label Text="3. التشطيبات - قيد الانتظار" TextColor="Gray" />
                </VerticalStackLayout>
            </Frame>
            <Button Text="عرض الدفعات" BackgroundColor="{StaticResource Primary}" TextColor="White" Clicked="OnPaymentsClicked" CornerRadius="8" />
        </VerticalStackLayout>
    </ScrollView>
</ContentPage>
MAUI

cat << 'MAUI' > src/Mobile/ConstructionManagement.Mobile/Views/ProjectDetailsPage.xaml.cs
using System;
using Microsoft.Maui.Controls;

namespace ConstructionManagement.Mobile.Views;

public partial class ProjectDetailsPage : ContentPage
{
    public ProjectDetailsPage()
    {
        InitializeComponent();
    }

    private async void OnPaymentsClicked(object sender, EventArgs e)
    {
        await Navigation.PushAsync(new PaymentsPage());
    }
}
MAUI

cat << 'MAUI' > src/Mobile/ConstructionManagement.Mobile/Views/PaymentsPage.xaml
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="ConstructionManagement.Mobile.Views.PaymentsPage"
             Title="سجل الدفعات"
             BackgroundColor="{StaticResource Background}"
             FlowDirection="RightToLeft">
    <ScrollView>
        <VerticalStackLayout Padding="20" Spacing="15">
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <Grid RowDefinitions="Auto,Auto" ColumnDefinitions="*,*">
                    <Label Grid.Row="0" Grid.Column="0" Text="الدفعة الأولى" FontAttributes="Bold" />
                    <Label Grid.Row="0" Grid.Column="1" Text="50,000 ريال" HorizontalOptions="End" FontAttributes="Bold" />
                    <Label Grid.Row="1" Grid.Column="0" Text="مدفوعة - تحويل بنكي" TextColor="Green" />
                    <Label Grid.Row="1" Grid.Column="1" Text="2024-01-15" HorizontalOptions="End" TextColor="Gray" />
                </Grid>
            </Frame>
            <Frame BackgroundColor="White" CornerRadius="10" Padding="15">
                <Grid RowDefinitions="Auto,Auto,Auto" ColumnDefinitions="*,*">
                    <Label Grid.Row="0" Grid.Column="0" Text="الدفعة الثانية" FontAttributes="Bold" />
                    <Label Grid.Row="0" Grid.Column="1" Text="30,000 ريال" HorizontalOptions="End" FontAttributes="Bold" />
                    <Label Grid.Row="1" Grid.Column="0" Text="بانتظار السداد" TextColor="Red" />
                    <Label Grid.Row="1" Grid.Column="1" Text="مستحقة" HorizontalOptions="End" TextColor="Gray" />
                    <Button Grid.Row="2" Grid.ColumnSpan="2" Margin="0,10,0,0" Text="دفع إلكتروني (Gateway)" BackgroundColor="{StaticResource Primary}" TextColor="White" />
                </Grid>
            </Frame>
        </VerticalStackLayout>
    </ScrollView>
</ContentPage>
MAUI

cat << 'MAUI' > src/Mobile/ConstructionManagement.Mobile/Views/PaymentsPage.xaml.cs
using Microsoft.Maui.Controls;

namespace ConstructionManagement.Mobile.Views;

public partial class PaymentsPage : ContentPage
{
    public PaymentsPage()
    {
        InitializeComponent();
    }
}
MAUI

