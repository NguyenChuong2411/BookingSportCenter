using ModelClass.BookingService;
using ModelClass.Connection;
using BookingSport.DTOs;
using Microsoft.EntityFrameworkCore;

namespace BookingSport.Services
{
    public interface IBookingService
    {
        Task<bool> CheckAvailability(Guid courtId, DateOnly date, TimeSpan startTime, TimeSpan endTime);
        Task<List<object>> GetAvailableSlots(Guid courtId, DateOnly date);
        Task<Booking> CreateBookingAsync(Guid userId, CreateBookingRequest request);
        Task<List<Booking>> GetUserBookingsAsync(Guid userId);
        Task<Booking?> GetBookingByIdAsync(Guid bookingId);
        Task<Booking> UpdateBookingAsync(Guid bookingId, Guid userId, UpdateBookingRequest request);
        Task<Booking> CompleteBookingAsync(Guid bookingId, Guid userId);
        Task CancelBookingAsync(Guid bookingId, Guid userId);
    }

    public class BookingService : IBookingService
    {
        private readonly BookingDbContext _context;

        public BookingService(BookingDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Kiểm tra xem khung giờ có trống không
        /// </summary>
        public async Task<bool> CheckAvailability(Guid courtId, DateOnly date, TimeSpan startTime, TimeSpan endTime)
        {
            var conflictingBooking = await _context.Bookings
                .FirstOrDefaultAsync(b =>
                    b.CourtId == courtId &&
                    b.BookingDate == date &&
                    b.StartTime < endTime &&
                    b.EndTime > startTime &&
                    b.Status == "Completed");

            return conflictingBooking == null;
        }

        /// <summary>
        /// Lấy danh sách khung giờ có sẵn trong ngày
        /// </summary>
        public async Task<List<object>> GetAvailableSlots(Guid courtId, DateOnly date)
        {
            var court = await _context.Courts
                .Include(c => c.Center)
                .FirstOrDefaultAsync(c => c.Id == courtId && c.IsActive);
            if (court == null)
                throw new KeyNotFoundException("Court not found or is inactive");

            if (court.Center == null)
                throw new InvalidOperationException("Center not found for this court");

            var bookings = await _context.Bookings
                .Where(b => b.CourtId == courtId && b.BookingDate == date && b.Status == "Completed")
                .OrderBy(b => b.StartTime)
                .ToListAsync();

            var pricings = await _context.CourtPricings
                .Where(p => p.CourtId == courtId)
                .OrderBy(p => p.StartTime)
                .ToListAsync();

            var availableSlots = new List<object>();
            var today = DateOnly.FromDateTime(DateTime.Now);
            var nowTime = DateTime.Now.TimeOfDay;
            var slotLength = TimeSpan.FromMinutes(30);

            foreach (var pricing in pricings)
            {
                if (pricing.StartTime < court.Center.OpenTime || pricing.EndTime > court.Center.CloseTime)
                    continue;

                var current = pricing.StartTime;
                while (current < pricing.EndTime)
                {
                    var slotStart = current;
                    var slotEnd = current + slotLength;

                    if (slotEnd > pricing.EndTime)
                        break;

                    if (date == today && slotStart <= nowTime)
                    {
                        current = slotEnd;
                        continue;
                    }

                    var isAvailable = !bookings.Any(b =>
                        b.StartTime < slotEnd && b.EndTime > slotStart);

                    availableSlots.Add(new
                    {
                        startTime = slotStart,
                        endTime = slotEnd,
                        pricePerHour = pricing.PricePerHour,
                        isAvailable = isAvailable
                    });

                    current = slotEnd;
                }
            }

            return availableSlots;
        }

        /// <summary>
        /// Tạo booking mới - TÍNH TIỀN SÂN nhưng không có thanh toán online
        /// Khách hàng sẽ trả tiền tại sân
        /// </summary>
        public async Task<Booking> CreateBookingAsync(Guid userId, CreateBookingRequest request)
        {
            // Kiểm tra sân tồn tại
            var court = await _context.Courts
                .Include(c => c.Center)
                .FirstOrDefaultAsync(c => c.Id == request.CourtId && c.IsActive);

            if (court == null)
                throw new KeyNotFoundException("Court not found or is inactive");

            if (court.Center == null)
                throw new InvalidOperationException("Center not found for this court");

            var now = DateTime.Now;
            var bookingStart = request.BookingDate.ToDateTime(
                TimeOnly.FromTimeSpan(request.StartTime));
            if (bookingStart <= now)
                throw new InvalidOperationException("Booking start time must be in the future");

            if (request.StartTime < court.Center.OpenTime || request.EndTime > court.Center.CloseTime)
                throw new InvalidOperationException("Booking time is outside center operating hours");

            // Kiểm tra trùng giờ
            var available = await CheckAvailability(request.CourtId, request.BookingDate, request.StartTime, request.EndTime);
            if (!available)
                throw new InvalidOperationException("This time slot is already booked");

            var totalPrice = await CalculateTotalPriceAsync(
                request.CourtId,
                request.StartTime,
                request.EndTime);
            var depositAmount = totalPrice * 0.2m; // 20% deposit (báo giá, khách trả tại sân)

            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                CourtId = request.CourtId,
                BookingDate = request.BookingDate,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                TotalPrice = totalPrice,       // ← TÍNH TIỀN SÂN
                DepositAmount = depositAmount,  // ← Báo giá cho khách
                Status = "Pending",            // Trạng thái "Pending" vì chưa thanh toán
                PaymentStatus = "Unpaid",      // "Unpaid" vì khách trả tại sân
                CreatedAt = DateTime.UtcNow
            };

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return booking;
        }

        /// <summary>
        /// Lấy danh sách booking của user
        /// </summary>
        public async Task<List<Booking>> GetUserBookingsAsync(Guid userId)
        {
            return await _context.Bookings
                .Where(b => b.UserId == userId)
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();
        }

        /// <summary>
        /// Lấy chi tiết booking
        /// </summary>
        public async Task<Booking?> GetBookingByIdAsync(Guid bookingId)
        {
            return await _context.Bookings.FirstOrDefaultAsync(b => b.Id == bookingId);
        }

        /// <summary>
        /// Cập nhật booking (chỉ cho Pending bookings)
        /// </summary>
        public async Task<Booking> UpdateBookingAsync(Guid bookingId, Guid userId, UpdateBookingRequest request)
        {
            var booking = await _context.Bookings
                .Include(b => b.Court)
                .ThenInclude(c => c.Center)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
                throw new KeyNotFoundException("Booking not found");

            if (booking.UserId != userId)
                throw new UnauthorizedAccessException("You do not have permission to update this booking");

            if (booking.Status != "Pending")
                throw new InvalidOperationException("Only pending bookings can be updated");

            if (booking.Court?.Center == null)
                throw new InvalidOperationException("Center not found for this booking");

            var now = DateTime.Now;
            var bookingStart = request.BookingDate.ToDateTime(
                TimeOnly.FromTimeSpan(request.StartTime));
            if (bookingStart <= now)
                throw new InvalidOperationException("Booking start time must be in the future");

            if (request.StartTime < booking.Court.Center.OpenTime || request.EndTime > booking.Court.Center.CloseTime)
                throw new InvalidOperationException("Booking time is outside center operating hours");

            // Kiểm tra slot mới có trống không
            var available = await _context.Bookings
                .FirstOrDefaultAsync(b =>
                    b.CourtId == booking.CourtId &&
                    b.Id != bookingId &&
                    b.BookingDate == request.BookingDate &&
                    b.StartTime < request.EndTime &&
                    b.EndTime > request.StartTime &&
                    b.Status == "Completed");

            if (available != null)
                throw new InvalidOperationException("This time slot is already booked");

            // Cập nhật booking
            booking.BookingDate = request.BookingDate;
            booking.StartTime = request.StartTime;
            booking.EndTime = request.EndTime;
            booking.TotalPrice = await CalculateTotalPriceAsync(
                booking.CourtId,
                request.StartTime,
                request.EndTime);
            booking.DepositAmount = booking.TotalPrice * 0.2m;

            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();

            return booking;
        }

        /// <summary>
        /// Hủy booking
        /// </summary>
        public async Task CancelBookingAsync(Guid bookingId, Guid userId)
        {
            var booking = await _context.Bookings.FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
                throw new KeyNotFoundException("Booking not found");

            if (booking.UserId != userId)
                throw new UnauthorizedAccessException("You do not have permission to cancel this booking");

            if (booking.Status == "Cancelled")
                throw new InvalidOperationException("Booking is already cancelled");

            if (booking.Status == "Completed")
                throw new InvalidOperationException("Cannot cancel a completed booking");

            var now = DateTime.Now;
            var bookingStart = booking.BookingDate.ToDateTime(
                TimeOnly.FromTimeSpan(booking.StartTime));
            if (bookingStart <= now)
                throw new InvalidOperationException("Cannot cancel after the booking has started");

            booking.Status = "Cancelled";
            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();
        }

        public async Task<Booking> CompleteBookingAsync(Guid bookingId, Guid userId)
        {
            var booking = await _context.Bookings
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
                throw new KeyNotFoundException("Booking not found");

            if (booking.UserId != userId)
                throw new UnauthorizedAccessException("You do not have permission to complete this booking");

            if (booking.Status == "Cancelled")
                throw new InvalidOperationException("Booking is already cancelled");

            if (booking.Status == "Completed")
                return booking;

            var now = DateTime.Now;
            var bookingStart = booking.BookingDate.ToDateTime(
                TimeOnly.FromTimeSpan(booking.StartTime));
            if (bookingStart <= now)
                throw new InvalidOperationException("Cannot complete after the booking has started");

            var hasCompletedConflict = await _context.Bookings
                .AnyAsync(b =>
                    b.CourtId == booking.CourtId &&
                    b.Id != bookingId &&
                    b.BookingDate == booking.BookingDate &&
                    b.StartTime < booking.EndTime &&
                    b.EndTime > booking.StartTime &&
                    b.Status == "Completed");

            if (hasCompletedConflict)
                throw new InvalidOperationException("This time slot is already booked");

            booking.Status = "Completed";
            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();

            return booking;
        }

        private async Task<decimal> CalculateTotalPriceAsync(
            Guid courtId,
            TimeSpan startTime,
            TimeSpan endTime)
        {
            if (endTime <= startTime)
                throw new InvalidOperationException("End time must be after start time");

            var pricings = await _context.CourtPricings
                .Where(p => p.CourtId == courtId)
                .OrderBy(p => p.StartTime)
                .ToListAsync();

            if (pricings.Count == 0)
                throw new KeyNotFoundException("No pricing found for this court");

            var remainingStart = startTime;
            decimal totalPrice = 0m;

            foreach (var pricing in pricings)
            {
                if (pricing.EndTime <= remainingStart)
                    continue;

                if (pricing.StartTime >= endTime)
                    break;

                var segmentStart = remainingStart > pricing.StartTime
                    ? remainingStart
                    : pricing.StartTime;
                var segmentEnd = endTime < pricing.EndTime
                    ? endTime
                    : pricing.EndTime;

                if (segmentEnd <= segmentStart)
                    continue;

                var durationHours = (segmentEnd - segmentStart).TotalHours;
                totalPrice += (decimal)durationHours * pricing.PricePerHour;
                remainingStart = segmentEnd;

                if (remainingStart >= endTime)
                    break;
            }

            if (remainingStart < endTime)
                throw new KeyNotFoundException("No pricing found for this time slot");

            return totalPrice;
        }
    }
}
