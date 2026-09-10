using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ChangeOrdersController : ControllerBase
    {
        private readonly IChangeOrderService _coService;

        public ChangeOrdersController(IChangeOrderService coService) 
        { 
            _coService = coService; 
        }

        private (Guid? CustomerId, byte UserType, Guid UserId) GetAuthContext()
        {
            byte.TryParse(User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value, out byte userType);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value, out Guid custId);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value, out Guid userId);
            return (custId == Guid.Empty ? null : custId, userType, userId);
        }

        [HttpPost("{id}/approve")]
        public async Task<IActionResult> Approve(Guid id)
        {
            var ctx = GetAuthContext();
            try
            {
                await _coService.ApproveChangeOrderAsync(id, ctx.UserId, ctx.UserType);
                return Ok(new { Message = "Approved successfully." });
            }
            catch(UnauthorizedAccessException ex) { return Forbid(ex.Message); }
            catch(InvalidOperationException ex) { return BadRequest(ex.Message); }
            catch(System.Collections.Generic.KeyNotFoundException ex) { return NotFound(ex.Message); }
        }
    }
}
