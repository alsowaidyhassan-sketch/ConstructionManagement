using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Files;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.System;
using Microsoft.IdentityModel.Tokens;

namespace ConstructionManagement.Infrastructure.Security
{
    public class AuthService
    {
        private readonly string _secretKey = "YourSuperSecretKeyForJwtAuthenticationMustBeAtLeast32Bytes";
        
        public string GenerateJwtToken(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_secretKey);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                    new Claim(ClaimTypes.Name, user.UserName),
                    new Claim("CompanyId", user.CompanyId?.ToString() ?? ""),
                    new Claim("CustomerId", user.CustomerId?.ToString() ?? ""),
                    new Claim("UserType", user.UserType.ToString())
                }),
                Expires = DateTime.UtcNow.AddHours(2),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = "ConstructionManagementApi",
                Audience = "ConstructionManagementClients"
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public string HashPassword(string password)
        {
            // Simple PBKDF2 for demonstration, Argon2id recommended for production
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }
            var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
            byte[] hash = pbkdf2.GetBytes(32);
            
            byte[] hashBytes = new byte[48];
            Array.Copy(salt, 0, hashBytes, 0, 16);
            Array.Copy(hash, 0, hashBytes, 16, 32);
            
            return Convert.ToBase64String(hashBytes);
        }
    }
}
