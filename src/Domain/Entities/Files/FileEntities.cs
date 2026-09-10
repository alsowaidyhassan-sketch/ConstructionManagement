using System;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Security;

namespace ConstructionManagement.Domain.Entities.Files
{
    public class Document
    {
        public Guid DocumentId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid? ProjectId { get; set; }
        public Guid? CustomerId { get; set; }
        
        public string FileName { get; set; }
        public string OriginalFileName { get; set; }
        public string ContentType { get; set; }
        public long FileSizeBytes { get; set; }
        public string StoragePath { get; set; }
        
        public byte DocumentType { get; set; } // 1: General, 2: Contract, 3: Receipt, 4: Change Order
        public bool IsCustomerVisible { get; set; }
        
        public DateTime UploadedAtUtc { get; set; }
        public Guid UploadedBy { get; set; }

        public Company Company { get; set; }
        public Project Project { get; set; }
        public Customer Customer { get; set; }
        public User Uploader { get; set; }
    }

    public class ProgressUpdateImage
    {
        public Guid ProgressUpdateImageId { get; set; }
        public Guid ProgressUpdateId { get; set; }
        public string StoragePath { get; set; }
        public string ThumbnailPath { get; set; }
        public long FileSizeBytes { get; set; }

        public ProgressUpdate ProgressUpdate { get; set; }
    }
}
