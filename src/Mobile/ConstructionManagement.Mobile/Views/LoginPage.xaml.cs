using System;
using Microsoft.Maui.Controls;

namespace ConstructionManagement.Mobile.Views;

public partial class LoginPage : ContentPage
{
    public LoginPage()
    {
        InitializeComponent();
    }

    private async void OnLoginClicked(object sender, EventArgs e)
    {
        // Simple mock login for structural demonstration
        if (UsernameEntry.Text == "customer" && PasswordEntry.Text == "customer")
        {
            await Navigation.PushAsync(new DashboardPage());
        }
        else
        {
            await DisplayAlert("خطأ", "اسم المستخدم أو كلمة المرور غير صحيحة", "موافق");
        }
    }
}
