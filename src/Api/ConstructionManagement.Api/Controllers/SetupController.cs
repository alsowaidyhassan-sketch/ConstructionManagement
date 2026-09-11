using Microsoft.AspNetCore.Mvc;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Domain.Entities.Security;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class SetupController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ISecurityService _securityService;

        public SetupController(ApplicationDbContext context, ISecurityService securityService)
        {
            _context = context;
            _securityService = securityService;
        }

        [HttpPost("init-db")]
        public async Task<IActionResult> InitializeDatabase()
        {
            try
            {
                await _context.Database.EnsureCreatedAsync();

                if (!await _context.Users.AnyAsync(u => u.UserName == "admin"))
                {
                    var user = new User
                    {
                        UserName = "admin",
                        PasswordHash = _securityService.HashPassword("admin123"),
                        FullNameAr = "مدير النظام",
                        FullNameEn = "System Admin",
                        Email = "admin@system.local",
                        IsActive = true,
                        UserType = UserType.SystemAdmin,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();
                    
                    return Ok(new { Message = "تم إنشاء قاعدة البيانات وإنشاء المستخدم الافتراضي.", Username = "admin", Password = "admin123" });
                }

                return Ok(new { Message = "قاعدة البيانات موجودة مسبقاً." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "خطأ في تهيئة قاعدة البيانات", Error = ex.Message });
            }
        }
    }
}
