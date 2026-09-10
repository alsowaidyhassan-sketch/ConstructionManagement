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
