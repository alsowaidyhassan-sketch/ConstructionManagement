using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ISecurityService _securityService;

        public AuthController(ApplicationDbContext context, ISecurityService securityService)
        {
            _context = context;
            _securityService = securityService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == request.UserName && u.IsActive);
            if (user == null || !_securityService.VerifyPassword(request.Password, user.PasswordHash))
                return Unauthorized(new { Message = "بيانات الدخول غير صحيحة" });

            var token = _securityService.GenerateJwtToken(user);
            return Ok(new { Token = token, FullName = user.FullNameAr, UserType = user.UserType });
        }
    }

    public class LoginRequest
    {
        public string UserName { get; set; }
        public string Password { get; set; }
    }
}
