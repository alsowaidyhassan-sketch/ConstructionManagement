using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using System.Collections.Generic;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ContractsController : ControllerBase
    {
        private readonly IContractService _contractService;

        public ContractsController(IContractService contractService) 
        { 
            _contractService = contractService; 
        }

        private (Guid? CustomerId, byte UserType) GetAuthContext()
        {
            byte.TryParse(User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value, out byte userType);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value, out Guid custId);
            return (custId == Guid.Empty ? null : custId, userType);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ContractDto>>> GetContracts()
        {
            var ctx = GetAuthContext();
            var contracts = await _contractService.GetContractsAsync(ctx.CustomerId, ctx.UserType);
            return Ok(contracts);
        }
    }
}
