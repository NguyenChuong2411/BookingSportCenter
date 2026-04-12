using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClass.BookingService
{
    [Table("bookings", Schema = "booking")]
    public class Booking
    {
        [Key]
        public Guid Id { get; set; }

        public Guid UserId { get; set; } // Logical FK từ Authentication

        public Guid CourtId { get; set; }
        [ForeignKey("CourtId")]
        public Court? Court { get; set; }

        public DateOnly BookingDate { get; set; } // Mapping kiểu DATE của SQL
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        public decimal TotalPrice { get; set; }
        public decimal DepositAmount { get; set; }
        public string? PaymentProofUrl { get; set; }

        public string Status { get; set; } = "Pending";
        public string PaymentStatus { get; set; } = "Unpaid";

        public DateTime CreatedAt { get; set; }
    }
}
