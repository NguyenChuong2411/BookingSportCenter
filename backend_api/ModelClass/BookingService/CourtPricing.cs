using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ModelClass.BookingService
{
    [Table("court_pricing", Schema = "booking")]
    public class CourtPricing
    {
        [Key]
        public int Id { get; set; }

        public Guid CourtId { get; set; }
        [ForeignKey("CourtId")]
        public Court? Court { get; set; }

        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal PricePerHour { get; set; }
    }
}