using System;
using System.Linq;
using ConstructionManagement.Domain.Entities;
using ConstructionManagement.Infrastructure.Services;

namespace ConstructionManagement.Infrastructure.Data
{
    public static class DbInitializer
    {
        public static void Initialize(ApplicationDbContext context)
        {
            context.Database.EnsureCreated();

            if (context.Users.Any())
            {
                return; // DB has been seeded
            }

            var securityService = new SecurityService();

            var admin = new User
            {
                UserId = Guid.NewGuid(),
                UserName = "admin",
                NormalizedUserName = "ADMIN",
                FullNameAr = "مدير النظام",
                PasswordHash = securityService.HashPassword("Admin@123"),
                UserType = 1,
                IsActive = true,
                CreatedAtUtc = DateTime.UtcNow
            };

            context.Users.Add(admin);
            context.SaveChanges();
        }
    }
}
