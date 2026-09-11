using Microsoft.AspNetCore.Mvc;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Projects;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;

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
                bool dataSeeded = false;

                // 1. Seed System Admin User
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
                    dataSeeded = true;
                }

                // 2. Seed Mock Data for Testing
                if (!await _context.Companies.AnyAsync())
                {
                    // Add Company
                    var company = new Company
                    {
                        NameAr = "شركة البناء المتقدمة",
                        NameEn = "Advanced Construction Co.",
                        TaxNumber = "300123456789003",
                        CommercialRegister = "1010123456",
                        Address = "الرياض - طريق الملك فهد",
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Companies.Add(company);
                    await _context.SaveChangesAsync(); // Save to get the ID

                    // Add Branch
                    var branch = new Branch
                    {
                        CompanyId = company.CompanyId,
                        NameAr = "الفرع الرئيسي - الرياض",
                        NameEn = "Main Branch - Riyadh",
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Branches.Add(branch);

                    // Add Customer
                    var customer = new Customer
                    {
                        NameAr = "مؤسسة الأفق للتطوير العقاري",
                        NameEn = "Horizon Real Estate",
                        PhoneNumber = "0501234567",
                        Email = "info@horizon.test",
                        CompanyId = company.CompanyId,
                        CustomerType = CustomerType.Corporate,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Customers.Add(customer);
                    
                    // Add Contractor
                    var contractor = new Contractor
                    {
                        NameAr = "مقاولات السريع",
                        Specialty = "أعمال الحفر والأساسات",
                        PhoneNumber = "0559876543",
                        CompanyId = company.CompanyId,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Contractors.Add(contractor);
                    await _context.SaveChangesAsync(); // Save to get IDs

                    // Add Project Type
                    var projectType = new ProjectType
                    {
                        NameAr = "مبنى تجاري",
                        NameEn = "Commercial Building",
                        Code = "COM-01",
                        CompanyId = company.CompanyId,
                        IsActive = true
                    };
                    _context.ProjectTypes.Add(projectType);
                    await _context.SaveChangesAsync();

                    dataSeeded = true;
                }

                if (dataSeeded)
                {
                    await _context.SaveChangesAsync();
                    return Ok(new { Message = "تم تهيئة قاعدة البيانات وإنشاء البيانات التجريبية بنجاح.", Username = "admin", Password = "admin123" });
                }

                return Ok(new { Message = "قاعدة البيانات تحتوي على بيانات مسبقاً." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "خطأ في تهيئة قاعدة البيانات", Error = ex.Message, InnerException = ex.InnerException?.Message });
            }
        }
    }
}
