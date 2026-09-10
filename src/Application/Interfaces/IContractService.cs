using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IContractService
    {
        Task<IEnumerable<ContractDto>> GetContractsAsync(Guid? customerId, byte userType);
        Task<ContractDto> GetContractByIdAsync(Guid contractId, Guid? customerId, byte userType);
        Task<ContractDto> CreateContractAsync(ContractDto dto, Guid userId);
    }
}
