using System;

namespace ConstructionManagement.Application.DTOs
{
    public class DocumentDto
    {
        public Guid DocumentId { get; set; }
        public Guid? ProjectId { get; set; }
        public string FileName { get; set; }
        public long FileSizeBytes { get; set; }
        public byte DocumentType { get; set; }
        public DateTime UploadedAtUtc { get; set; }
    }
}
