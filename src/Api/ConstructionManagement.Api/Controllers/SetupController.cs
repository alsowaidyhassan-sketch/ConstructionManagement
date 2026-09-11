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
                        NormalizedUserName = "ADMIN",
                        PasswordHash = _securityService.HashPassword("admin123"),
                        FullNameAr = "مدير النظام",
                        Email = "admin@system.local",
                        IsActive = true,
                        UserType = 1, // 1: Employee/Admin
                        CreatedAtUtc = DateTime.UtcNow
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
                        Name = "شركة البناء المتقدمة",
                        TaxNumber = "300123456789003",
                        CommercialRecord = "1010123456",
                        Address = "الرياض - طريق الملك فهد",
                        Phone = "0112345678",
                        Email = "info@advanced.test",
                        IsActive = true,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    _context.Companies.Add(company);
                    await _context.SaveChangesAsync(); // Save to get the ID

                    // Add Branch
                    var branch = new Branch
                    {
                        CompanyId = company.CompanyId,
                        Name = "الفرع الرئيسي - الرياض",
                        Location = "الرياض",
                        IsActive = true
                    };
                    _context.Branches.Add(branch);

                    // Add Customer
                    var customer = new Customer
                    {
                        CompanyId = company.CompanyId,
                        CustomerCode = "CUST-001",
                        FullNameAr = "مؤسسة الأفق للتطوير العقاري",
                        Phone = "0501234567",
                        Email = "info@horizon.test",
                        Address = "الرياض",
                        IsActive = true,
                        CreatedAtUtc = DateTime.UtcNow
                    };
                    _context.Customers.Add(customer);
                    
                    // Add Contractor
                    var contractor = new Contractor
                    {
                        CompanyId = company.CompanyId,
                        Name = "مقاولات السريع",
                        Specialization = "أعمال الحفر والأساسات",
                        Phone = "0559876543",
                        ContactPerson = "أحمد السريع",
                        Email = "contractor@test.com",
                        IsActive = true
                    };
                    _context.Contractors.Add(contractor);

                    // Add Project Type
                    var projectType = new ProjectType
                    {
                        CompanyId = company.CompanyId,
                        Name = "مبنى تجاري"
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
