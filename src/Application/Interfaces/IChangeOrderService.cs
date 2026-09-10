using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IChangeOrderService
    {
        Task<IEnumerable<ChangeOrderDto>> GetChangeOrdersAsync(Guid projectId, Guid? customerId, byte userType);
        Task<ChangeOrderDto> CreateChangeOrderAsync(ChangeOrderDto dto, Guid userId);
        Task<bool> ApproveChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType);
        Task<bool> RejectChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType);
    }
}
