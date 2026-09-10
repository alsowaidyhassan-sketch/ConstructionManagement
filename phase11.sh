#!/bin/bash

# MAUI Token Storage using SecureStorage
cat << 'CS' > src/Mobile/ConstructionManagement.Mobile/Services/TokenService.cs
using System.Threading.Tasks;
using Microsoft.Maui.Storage;

namespace ConstructionManagement.Mobile.Services
{
    public class TokenService
    {
        public async Task SaveTokenAsync(string token)
        {
            await SecureStorage.Default.SetAsync("jwt_token", token);
        }

        public async Task<string> GetTokenAsync()
        {
            return await SecureStorage.Default.GetAsync("jwt_token");
        }
        
        public void RemoveToken()
        {
            SecureStorage.Default.Remove("jwt_token");
        }
    }
}
CS

cat << 'CS' > src/Mobile/ConstructionManagement.Mobile/AppConfig.cs
namespace ConstructionManagement.Mobile
{
    public static class AppConfig
    {
        // Should be loaded from preferences or environment, not hardcoded to localhost in production
        public static string ApiBaseUrl { get; set; } = "https://api.yourdomain.com/api/v1/";
    }
}
CS

