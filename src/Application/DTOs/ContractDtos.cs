using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ContractDto
    {
        public Guid ContractId { get; set; }
        public Guid ProjectId { get; set; }
        public string ContractNumber { get; set; }
        public decimal OriginalValue { get; set; }
        public decimal CurrentValue { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public byte Status { get; set; }
    }
}
