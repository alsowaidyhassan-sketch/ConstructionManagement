using System;

namespace ConstructionManagement.Domain.Entities
{
    public class Project
    {
        public Guid ProjectId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid ProjectStatusId { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal? OriginalContractValue { get; set; }
        public decimal? CurrentContractValue { get; set; }
        public DateTime? StartDate { get; set; }
        public bool IsArchived { get; set; }
        
        public Customer Customer { get; set; }
    }
}
