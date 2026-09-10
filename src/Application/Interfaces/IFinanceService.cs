using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IFinanceService
    {
        Task<ProfitCalculationDto> CalculateProjectProfitAsync(Guid projectId, Guid? customerId, byte userType, bool includeOverhead);
        Task<CustomerPaymentDto> RecordCustomerPaymentAsync(CustomerPaymentDto dto, Guid userId);
    }
}
