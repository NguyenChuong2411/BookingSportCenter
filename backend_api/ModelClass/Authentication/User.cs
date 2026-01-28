using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClass.Authentication
{
    [Table("users", Schema = "authentication")]
    public class User
    {
        [Key]
        public Guid Id { get; set; }

        public string Username { get; set; } = null!;
        public string PasswordHash { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string FullName { get; set; } = null!;
        public string? AvatarUrl { get; set; }
        public string Role { get; set; } = "Customer"; // Enum: Customer, CenterOwner...
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
