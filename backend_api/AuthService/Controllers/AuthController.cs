using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ModelClass.Authentication;
using ModelClass.Connection;
using AuthService.Services;
using System.Security.Claims;

namespace AuthService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AuthDbContext _context;
        private readonly IJwtTokenService _jwtTokenService;

        public AuthController(AuthDbContext context, IJwtTokenService jwtTokenService)
        {
            _context = context;
            _jwtTokenService = jwtTokenService;
        }

        public class RegisterRequest
        {
            public string Username { get; set; } = null!;
            public string FullName { get; set; } = null!;
            public string Email { get; set; } = null!;
            public string PhoneNumber { get; set; } = null!;
            public string Password { get; set; } = null!;
        }

        public class LoginRequest
        {
            public string Email { get; set; } = null!;
            public string Password { get; set; } = null!;
        }

        public class AuthResponse
        {
            public string Message { get; set; } = null!;
            public string? Token { get; set; }
            public UserDto? User { get; set; }
        }

        public class UserDto
        {
            public Guid Id { get; set; }
            public string Username { get; set; } = null!;
            public string FullName { get; set; } = null!;
            public string Email { get; set; } = null!;
            public string Role { get; set; } = null!;
        }

        public class UserProfileResponse
        {
            public Guid Id { get; set; }
            public string Username { get; set; } = null!;
            public string Email { get; set; } = null!;
            public string FullName { get; set; } = null!;
            public string? PhoneNumber { get; set; }
            public string? AvatarUrl { get; set; }
            public string Role { get; set; } = null!;
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        public class UpdateProfileRequest
        {
            public string FullName { get; set; } = null!;
            public string? PhoneNumber { get; set; }
            public string? AvatarUrl { get; set; }
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                return BadRequest(new AuthResponse { Message = "Email is already used!" });

            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                return BadRequest(new AuthResponse { Message = "Username is already taken!" });

            var user = new User
            {
                Id = Guid.NewGuid(),
                Username = request.Username,
                FullName = request.FullName,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = "Customer",
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var token = _jwtTokenService.GenerateToken(user);

            return Ok(new AuthResponse
            {
                Message = "Register successfully!",
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Username = user.Username,
                    FullName = user.FullName,
                    Email = user.Email,
                    Role = user.Role
                }
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return Unauthorized(new AuthResponse { Message = "Email or password is incorrect!" });

            if (!user.IsActive)
                return Unauthorized(new AuthResponse { Message = "Your account has been banned!" });

            var token = _jwtTokenService.GenerateToken(user);

            return Ok(new AuthResponse
            {
                Message = "Login successfully!",
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Username = user.Username,
                    FullName = user.FullName,
                    Email = user.Email,
                    Role = user.Role
                }
            });
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
                return Unauthorized(new { message = "User ID not found in token" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            return Ok(new UserProfileResponse
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                AvatarUrl = user.AvatarUrl,
                Role = user.Role,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.CreatedAt
            });
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.FullName))
                return BadRequest(new { message = "Full name is required" });

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
                return Unauthorized(new { message = "User ID not found in token" });

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            user.FullName = request.FullName.Trim();
            user.PhoneNumber = request.PhoneNumber;
            user.AvatarUrl = request.AvatarUrl;

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            return Ok(new UserProfileResponse
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                AvatarUrl = user.AvatarUrl,
                Role = user.Role,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = DateTime.UtcNow
            });
        }
    }
}