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
