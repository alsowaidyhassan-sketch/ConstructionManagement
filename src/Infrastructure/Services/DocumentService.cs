using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Files;
using System.IO;

namespace ConstructionManagement.Infrastructure.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileStorage _fileStorage;

        public DocumentService(ApplicationDbContext context, IFileStorage fileStorage)
        {
            _context = context;
            _fileStorage = fileStorage;
        }

        public async Task<DocumentDto> UploadDocumentAsync(Guid? projectId, Guid? customerId, string originalFileName, string contentType, byte[] content, byte userType, Guid uploaderId)
        {
            // Security Checks
            if (Path.GetExtension(originalFileName).ToLower() == ".exe") throw new InvalidOperationException("Executable files not allowed.");
            
            string path = await _fileStorage.SaveFileAsync(content, $"{Guid.NewGuid()}{Path.GetExtension(originalFileName)}", "Documents");

            var doc = new Document
            {
                DocumentId = Guid.NewGuid(),
                CompanyId = Guid.Empty, // Simplified for single tenant mock
                ProjectId = projectId,
                CustomerId = customerId,
                FileName = $"{Guid.NewGuid()}{Path.GetExtension(originalFileName)}",
                OriginalFileName = originalFileName,
                ContentType = contentType,
                FileSizeBytes = content.Length,
                StoragePath = path,
                IsCustomerVisible = userType == 1 ? true : true,
                UploadedAtUtc = DateTime.UtcNow,
                UploadedBy = uploaderId
            };

            _context.Documents.Add(doc);
            await _context.SaveChangesAsync();

            return new DocumentDto { DocumentId = doc.DocumentId, FileName = doc.OriginalFileName, FileSizeBytes = doc.FileSizeBytes, UploadedAtUtc = doc.UploadedAtUtc };
        }

        public async Task<IEnumerable<DocumentDto>> GetProjectDocumentsAsync(Guid projectId, Guid? customerId, byte userType)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (userType == 2 && project?.CustomerId != customerId) throw new UnauthorizedAccessException();

            var query = _context.Documents.Where(d => d.ProjectId == projectId);
            if (userType == 2) query = query.Where(d => d.IsCustomerVisible);

            return await query.Select(d => new DocumentDto
            {
                DocumentId = d.DocumentId,
                ProjectId = d.ProjectId,
                FileName = d.OriginalFileName,
                FileSizeBytes = d.FileSizeBytes,
                UploadedAtUtc = d.UploadedAtUtc
            }).ToListAsync();
        }

        public async Task<byte[]> DownloadDocumentAsync(Guid documentId, Guid? customerId, byte userType)
        {
            var doc = await _context.Documents.Include(d => d.Project).FirstOrDefaultAsync(d => d.DocumentId == documentId);
            if (doc == null) throw new KeyNotFoundException();

            if (userType == 2)
            {
                if (!doc.IsCustomerVisible) throw new UnauthorizedAccessException();
                if (doc.ProjectId.HasValue && doc.Project.CustomerId != customerId) throw new UnauthorizedAccessException();
                if (doc.CustomerId.HasValue && doc.CustomerId != customerId) throw new UnauthorizedAccessException();
            }

            return await _fileStorage.GetFileAsync(doc.StoragePath);
        }
    }
}
