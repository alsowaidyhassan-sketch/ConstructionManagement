using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Infrastructure.Services
{
    public class ContractService : IContractService
    {
        private readonly ApplicationDbContext _context;

        public ContractService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ContractDto>> GetContractsAsync(Guid? customerId, byte userType)
        {
            var query = _context.Contracts.Include(c => c.Project).AsQueryable();

            if (userType == 2) 
            {
                if (!customerId.HasValue) throw new UnauthorizedAccessException("Customer ID missing.");
                query = query.Where(c => c.Project.CustomerId == customerId.Value);
            }

            return await query.Select(c => new ContractDto
            {
                ContractId = c.ContractId,
                ProjectId = c.ProjectId,
                ContractNumber = c.ContractNumber,
                OriginalValue = c.OriginalValue,
                CurrentValue = c.CurrentValue,
                StartDate = c.StartDate,
                EndDate = c.EndDate,
                Status = c.Status
            }).ToListAsync();
        }

        public async Task<ContractDto> GetContractByIdAsync(Guid contractId, Guid? customerId, byte userType)
        {
            var contract = await _context.Contracts.Include(c => c.Project).FirstOrDefaultAsync(c => c.ContractId == contractId);
            if (contract == null) return null;

            if (userType == 2 && contract.Project.CustomerId != customerId)
                throw new UnauthorizedAccessException("Access denied to this contract.");

            return new ContractDto
            {
                ContractId = contract.ContractId,
                ProjectId = contract.ProjectId,
                ContractNumber = contract.ContractNumber,
                OriginalValue = contract.OriginalValue,
                CurrentValue = contract.CurrentValue,
                StartDate = contract.StartDate,
                EndDate = contract.EndDate,
                Status = contract.Status
            };
        }

        public async Task<ContractDto> CreateContractAsync(ContractDto dto, Guid userId)
        {
            var contract = new Contract
            {
                ContractId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                ContractNumber = dto.ContractNumber ?? $"CONT-{DateTime.UtcNow:yyyyMMddHHmmss}",
                OriginalValue = dto.OriginalValue,
                CurrentValue = dto.OriginalValue,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Status = 1 // Draft
            };
            
            _context.Contracts.Add(contract);
            await _context.SaveChangesAsync();
            dto.ContractId = contract.ContractId;
            return dto;
        }
    }
}
