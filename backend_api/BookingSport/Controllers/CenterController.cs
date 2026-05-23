using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ModelClass.Connection;

namespace BookingSport.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
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
                    .Select(c => new
                    {
                        id = c.Id,
                        name = c.Name,
                        location = "Ho Chi Minh City", // Cập nhật sang tiếng Anh
                        address = c.Address,
                        rating = c.AverageRating,
                        reviewCount = 120, // Tạm fix cứng số lượt đánh giá
                        sportType = "Football",
                        
                        imageUrl = c.CenterImages.FirstOrDefault(i => i.IsThumbnail) != null
                                   ? c.CenterImages.FirstOrDefault(i => i.IsThumbnail)!.ImageUrl
                                   : "",
                                   
                        courtCount = c.Courts.Count
                    })
                    .ToListAsync();

                return Ok(centers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}