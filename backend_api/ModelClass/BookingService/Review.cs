using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ModelClass.BookingService
{
    [Table("reviews", Schema = "booking")]
    public class Review
    {
        [Key]
        public Guid Id { get; set; }

        public Guid UserId { get; set; } // Logical FK từ Authentication

        public Guid BookingId { get; set; }
        [ForeignKey("BookingId")]
        public Booking? Booking { get; set; }

        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}