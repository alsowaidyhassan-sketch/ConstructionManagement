using Microsoft.AspNetCore.Mvc;
using ConstructionManagement.Domain.Entities;
using System.Threading.Tasks;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AuthController : ControllerBase
    {
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // Placeholder for real authentication logic
            if (request.UserName == "admin" && request.Password == "admin")
            {
                return Ok(new { Token = "SampleJWTToken", FullName = "System Admin" });
            }
            return Unauthorized("Invalid credentials.");
        }
    }

    public class LoginRequest
    {
        public string UserName { get; set; }
        public string Password { get; set; }
    }
}
