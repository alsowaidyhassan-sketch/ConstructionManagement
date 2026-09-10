using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ProjectDto
    {
        public Guid ProjectId { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal? CurrentContractValue { get; set; }
    }
    
    public class ChangeOrderDto
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; }
    }

    public class ProgressUpdateDto
    {
        public Guid ProjectId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public List<string> Base64Images { get; set; }
    }
}
