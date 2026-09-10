using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ProjectDto
    {
        public Guid ProjectId { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal CurrentContractValue { get; set; }
        public byte Status { get; set; }
        public Guid CustomerId { get; set; }
        public Guid? ContractorId { get; set; }
    }

    public class ProjectDetailsDto : ProjectDto
    {
        public string Address { get; set; }
        public string Description { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? PlannedEndDate { get; set; }
        public decimal InitialContractValue { get; set; }
        public byte ContractorCompensationType { get; set; }
        public decimal ContractorCompensationValue { get; set; }
        public CustomerDto Customer { get; set; }
        public ContractorDto Contractor { get; set; }
        public List<ProjectStageDto> Stages { get; set; }
    }

    public class ProjectStageDto
    {
        public Guid StageId { get; set; }
        public string Name { get; set; }
        public int SortOrder { get; set; }
        public decimal Weight { get; set; }
        public decimal ProgressPercent { get; set; }
        public byte Status { get; set; }
        public List<WorkItemDto> WorkItems { get; set; }
    }

    public class WorkItemDto
    {
        public Guid WorkItemId { get; set; }
        public string Name { get; set; }
        public decimal Quantity { get; set; }
        public string Unit { get; set; }
        public decimal ProgressPercent { get; set; }
    }

    public class ProgressUpdateDto
    {
        public Guid ProjectId { get; set; }
        public Guid? StageId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public List<string> Base64Images { get; set; } // Max 5
    }
}
