using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ModelClass.Connection;

namespace BookingSport.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CenterController : ControllerBase
    {
        private readonly BookingDbContext _context;

        public CenterController(BookingDbContext context)
        {
            _context = context;
        }

        [HttpGet("available")]
        public async Task<IActionResult> GetAvailableCenters()
        {
            try
            {
                var centers = await _context.Centers
                    .Where(c => c.Status == "Active")
                    .Include(c => c.CenterImages)
                    .Include(c => c.Courts)
                    .ThenInclude(court => court.Sport)
                    .Select(c => new
                    {
                        id = c.Id,
                        name = c.Name,
                        address = c.Address,
                        location = c.Address,
                        rating = c.AverageRating,
                        reviewCount = _context.Reviews.Count(r =>
                            r.Booking != null && _context.Courts.Any(court =>
                                court.Id == r.Booking!.CourtId && court.CenterId == c.Id)),
                        sportType = c.Courts
                            .Where(court => court.IsActive)
                            .Select(court => court.Sport != null ? court.Sport.Name : null)
                            .FirstOrDefault(name => name != null) ?? "",

                        imageUrl = c.CenterImages.FirstOrDefault(i => i.IsThumbnail) != null
                                   ? c.CenterImages.FirstOrDefault(i => i.IsThumbnail)!.ImageUrl
                                   : "",

                        courtCount = c.Courts.Count(court => court.IsActive)
                    })
                    .ToListAsync();

                return Ok(centers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpGet("courts/{courtId}")]
        public async Task<IActionResult> GetCourtById(Guid courtId)
        {
            try
            {
                var court = await _context.Courts
                    .Include(c => c.Center)
                    .Include(c => c.Sport)
                    .FirstOrDefaultAsync(c => c.Id == courtId && c.IsActive && c.Center != null && c.Center.Status == "Active");

                if (court == null)
                    return NotFound(new { message = "Court not found" });

                return Ok(new
                {
                    id = court.Id,
                    name = court.Name,
                    courtType = court.CourtType,
                    sportName = court.Sport != null ? court.Sport.Name : null,
                    centerId = court.CenterId,
                    centerName = court.Center?.Name,
                    address = court.Center?.Address,
                    isActive = court.IsActive
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpGet("{centerId}/courts")]
        public async Task<IActionResult> GetCenterCourts(Guid centerId)
        {
            try
            {
                var center = await _context.Centers
                    .FirstOrDefaultAsync(c => c.Id == centerId && c.Status == "Active");

                if (center == null)
                    return NotFound(new { message = "Center not found" });

                var courts = await _context.Courts
                    .Include(c => c.Sport)
                    .Where(c => c.CenterId == centerId && c.IsActive)
                    .Select(c => new
                    {
                        id = c.Id,
                        name = c.Name,
                        courtType = c.CourtType,
                        sportName = c.Sport != null ? c.Sport.Name : null,
                        isActive = c.IsActive
                    })
                    .ToListAsync();

                return Ok(courts);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}