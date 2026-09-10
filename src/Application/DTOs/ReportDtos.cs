using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ReportDto
    {
        public string Title { get; set; }
        public DateTime GeneratedAt { get; set; }
        public object Data { get; set; }
    }
}
