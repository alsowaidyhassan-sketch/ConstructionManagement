using System;

namespace ConstructionManagement.Application.DTOs
{
    public class ProfitCalculationDto
    {
        public Guid ProjectId { get; set; }
        public decimal CurrentContractValue { get; set; }
        public decimal TotalProjectExpenses { get; set; }
        public decimal TotalContractorPayments { get; set; }
        public decimal Profit => CurrentContractValue - TotalProjectExpenses - TotalContractorPayments;
        public decimal? AllocatedCompanyOverhead { get; set; }
        public decimal NetProfit => Profit - (AllocatedCompanyOverhead ?? 0);
    }
}
