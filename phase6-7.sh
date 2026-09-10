#!/bin/bash
# DTOs
cat << 'CS' > src/Application/DTOs/DocumentDtos.cs
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
CS

cat << 'CS' > src/Application/DTOs/ProfitCalculationDto.cs
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
CS

# Interfaces
cat << 'CS' > src/Application/Interfaces/IFinanceService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IFinanceService
    {
        Task<ProfitCalculationDto> CalculateProjectProfitAsync(Guid projectId, Guid? customerId, byte userType, bool includeOverhead);
        Task<CustomerPaymentDto> RecordCustomerPaymentAsync(CustomerPaymentDto dto, Guid userId);
    }
}
CS

cat << 'CS' > src/Application/Interfaces/IDocumentService.cs
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
CS

# Services
cat << 'CS' > src/Application/Services/FinanceService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Security;

namespace ConstructionManagement.Application.Services
{
    public class FinanceService : IFinanceService
    {
        private readonly ApplicationDbContext _context;

        public FinanceService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<ProfitCalculationDto> CalculateProjectProfitAsync(Guid projectId, Guid? customerId, byte userType, bool includeOverhead)
        {
            if (userType == 2) throw new UnauthorizedAccessException("Customers cannot view profit calculations.");

            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (project == null) throw new KeyNotFoundException();

            decimal expenses = await _context.Expenses.Where(e => e.ProjectId == projectId).SumAsync(e => e.Amount);
            decimal contractorPayments = await _context.ContractorPayments.Where(c => c.ProjectId == projectId).SumAsync(c => c.Amount);
            
            decimal overhead = 0;
            if (includeOverhead)
            {
                // Simple logic: Company overhead / Total Projects
                var totalOverhead = await _context.Expenses.Where(e => e.ProjectId == null && e.CompanyId == project.CompanyId).SumAsync(e => e.Amount);
                var activeProjectsCount = await _context.Projects.CountAsync(p => p.CompanyId == project.CompanyId && p.Status != 5);
                if (activeProjectsCount > 0) overhead = totalOverhead / activeProjectsCount;
            }

            return new ProfitCalculationDto
            {
                ProjectId = projectId,
                CurrentContractValue = project.CurrentContractValue,
                TotalProjectExpenses = expenses,
                TotalContractorPayments = contractorPayments,
                AllocatedCompanyOverhead = includeOverhead ? overhead : null
            };
        }

        public async Task<CustomerPaymentDto> RecordCustomerPaymentAsync(CustomerPaymentDto dto, Guid userId)
        {
            var payment = new CustomerPayment
            {
                PaymentId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                Amount = dto.Amount,
                PaymentDate = dto.PaymentDate,
                PaymentMethod = dto.PaymentMethod,
                PaymentNumber = dto.PaymentNumber,
                Status = 2, // Confirmed
                CreatedBy = userId,
                CreatedAtUtc = DateTime.UtcNow
            };
            
            _context.CustomerPayments.Add(payment);
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), Action = "Payment", EntityName = "CustomerPayment", EntityId = payment.PaymentId.ToString(), TimestampUtc = DateTime.UtcNow, UserId = userId });
            
            await _context.SaveChangesAsync();
            dto.PaymentId = payment.PaymentId;
            return dto;
        }
    }
}
CS

cat << 'CS' > src/Application/Services/DocumentService.cs
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

namespace ConstructionManagement.Application.Services
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
CS

# Register in DI (will run a sed command next script or replace later)

