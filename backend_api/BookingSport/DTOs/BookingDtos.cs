namespace BookingSport.DTOs
{
    public class CreateBookingRequest
    {
        public Guid CourtId { get; set; }
        public DateOnly BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    public class UpdateBookingRequest
    {
        public DateOnly BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    public class BookingResponse
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid CourtId { get; set; }
        public DateOnly BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal TotalPrice { get; set; }
        public decimal DepositAmount { get; set; }
        public string Status { get; set; } = null!;
        public string PaymentStatus { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }

    public class GetCourtRequest
    {
        public Guid CourtId { get; set; }
    }

    public class CourtResponse
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public string? CourtType { get; set; }
        public bool IsActive { get; set; }
        public Guid CenterId { get; set; }
        public string CenterName { get; set; } = null!;
    }
}
