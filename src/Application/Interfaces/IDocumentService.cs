using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IDocumentService
    {
        Task<DocumentDto> UploadDocumentAsync(Guid? projectId, Guid? customerId, string originalFileName, string contentType, byte[] content, byte userType, Guid uploaderId);
        Task<IEnumerable<DocumentDto>> GetProjectDocumentsAsync(Guid projectId, Guid? customerId, byte userType);
        Task<byte[]> DownloadDocumentAsync(Guid documentId, Guid? customerId, byte userType);
    }
}
