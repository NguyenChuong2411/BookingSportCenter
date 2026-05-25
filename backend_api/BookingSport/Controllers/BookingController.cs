using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ModelClass.BookingService;
using BookingSport.DTOs;
using BookingSport.Services;
using System.Security.Claims;

namespace BookingSport.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BookingController : ControllerBase
    {
        private readonly IBookingService _bookingService;

        public BookingController(IBookingService bookingService)
        {
            _bookingService = bookingService;
        }

        private Guid GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
                throw new UnauthorizedAccessException("User ID not found in token");
            return userId;
        }

        /// <summary>
        /// Create a new booking (chỉ đặt lịch, không thanh toán)
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest request)
        {
            try
            {
                var userId = GetUserId();
                var booking = await _bookingService.CreateBookingAsync(userId, request);

                var response = new BookingResponse
                {
                    Id = booking.Id,
                    UserId = booking.UserId,
                    CourtId = booking.CourtId,
                    BookingDate = booking.BookingDate,
                    StartTime = booking.StartTime,
                    EndTime = booking.EndTime,
                    TotalPrice = booking.TotalPrice,
                    DepositAmount = booking.DepositAmount,
                    Status = booking.Status,
                    PaymentStatus = booking.PaymentStatus,
                    CreatedAt = booking.CreatedAt
                };

                return CreatedAtAction(nameof(GetBookingById), new { id = booking.Id }, response);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error creating booking", error = ex.Message });
            }
        }

        /// <summary>
        /// Get all bookings for current user
        /// </summary>
        [HttpGet("my-bookings")]
        public async Task<IActionResult> GetMyBookings()
        {
            try
            {
                var userId = GetUserId();
                var bookings = await _bookingService.GetUserBookingsAsync(userId);

                var responses = bookings.Select(b => new BookingResponse
                {
                    Id = b.Id,
                    UserId = b.UserId,
                    CourtId = b.CourtId,
                    BookingDate = b.BookingDate,
                    StartTime = b.StartTime,
                    EndTime = b.EndTime,
                    TotalPrice = b.TotalPrice,
                    DepositAmount = b.DepositAmount,
                    Status = b.Status,
                    PaymentStatus = b.PaymentStatus,
                    CreatedAt = b.CreatedAt
                }).ToList();

                return Ok(responses);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching bookings", error = ex.Message });
            }
        }

        /// <summary>
        /// Get booking by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetBookingById(Guid id)
        {
            try
            {
                var userId = GetUserId();
                var booking = await _bookingService.GetBookingByIdAsync(id);

                if (booking == null)
                    return NotFound(new { message = "Booking not found" });

                // Check authorization
                if (booking.UserId != userId && !User.IsInRole("SystemAdmin"))
                    return Forbid("You do not have permission to view this booking");

                var response = new BookingResponse
                {
                    Id = booking.Id,
                    UserId = booking.UserId,
                    CourtId = booking.CourtId,
                    BookingDate = booking.BookingDate,
                    StartTime = booking.StartTime,
                    EndTime = booking.EndTime,
                    TotalPrice = booking.TotalPrice,
                    DepositAmount = booking.DepositAmount,
                    Status = booking.Status,
                    PaymentStatus = booking.PaymentStatus,
                    CreatedAt = booking.CreatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching booking", error = ex.Message });
            }
        }

        /// <summary>
        /// Update booking (chỉ cho Pending bookings)
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateBooking(Guid id, [FromBody] UpdateBookingRequest request)
        {
            try
            {
                var userId = GetUserId();
                var booking = await _bookingService.UpdateBookingAsync(id, userId, request);

                var response = new BookingResponse
                {
                    Id = booking.Id,
                    UserId = booking.UserId,
                    CourtId = booking.CourtId,
                    BookingDate = booking.BookingDate,
                    StartTime = booking.StartTime,
                    EndTime = booking.EndTime,
                    TotalPrice = booking.TotalPrice,
                    DepositAmount = booking.DepositAmount,
                    Status = booking.Status,
                    PaymentStatus = booking.PaymentStatus,
                    CreatedAt = booking.CreatedAt
                };

                return Ok(response);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error updating booking", error = ex.Message });
            }
        }

        /// <summary>
        /// Cancel a booking
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> CancelBooking(Guid id)
        {
            try
            {
                var userId = GetUserId();
                await _bookingService.CancelBookingAsync(id, userId);
                return Ok(new { message = "Booking cancelled successfully" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error cancelling booking", error = ex.Message });
            }
        }

        /// <summary>
        /// Complete a booking
        /// </summary>
        [HttpPost("{id}/complete")]
        public async Task<IActionResult> CompleteBooking(Guid id)
        {
            try
            {
                var userId = GetUserId();
                var booking = await _bookingService.CompleteBookingAsync(id, userId);

                var response = new BookingResponse
                {
                    Id = booking.Id,
                    UserId = booking.UserId,
                    CourtId = booking.CourtId,
                    BookingDate = booking.BookingDate,
                    StartTime = booking.StartTime,
                    EndTime = booking.EndTime,
                    TotalPrice = booking.TotalPrice,
                    DepositAmount = booking.DepositAmount,
                    Status = booking.Status,
                    PaymentStatus = booking.PaymentStatus,
                    CreatedAt = booking.CreatedAt
                };

                return Ok(response);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error completing booking", error = ex.Message });
            }
        }

        /// <summary>
        /// Get available time slots for a court on a specific date
        /// </summary>
        [HttpGet("available-slots")]
        public async Task<IActionResult> GetAvailableSlots([FromQuery] Guid courtId, [FromQuery] DateOnly date)
        {
            try
            {
                if (courtId == Guid.Empty || date == default)
                    return BadRequest(new { message = "CourtId and date are required" });

                var availableSlots = await _bookingService.GetAvailableSlots(courtId, date);
                return Ok(availableSlots);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching available slots", error = ex.Message });
            }
        }
    }
}
