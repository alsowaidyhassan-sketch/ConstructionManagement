using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Domain.Entities.Core
{
    public class Contractor
    {
        public Guid ContractorId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string ContactPerson { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Specialization { get; set; }
        public bool IsActive { get; set; }

        public Company Company { get; set; }
        public ICollection<Project> Projects { get; set; } // The projects they are assigned to
    }
}
