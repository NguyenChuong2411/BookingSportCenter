using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClass.Booking
{
    [Table("centers", Schema = "booking")]
    public class Center
    {
        [Key]
        public Guid Id { get; set; }

        public Guid? OwnerId { get; set; }

        public string Name { get; set; } = null!;
        public string Address { get; set; } = null!;

        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }

        public TimeSpan OpenTime { get; set; }
        public TimeSpan CloseTime { get; set; }

        public string? PhoneContact { get; set; }
        public string? EmailContact { get; set; }
        public string? Description { get; set; }
        public string? Rules { get; set; }
        public string? Amenities { get; set; }

        // JSONB: Trong C# tạm thời lưu là string JSON raw. 
        // Khi dùng sẽ Deserialize ra List object sau.
        [Column(TypeName = "jsonb")]
        public string? SocialLinks { get; set; }

        public string Status { get; set; } = "Pending";
        public decimal AverageRating { get; set; }

        [Column(TypeName = "jsonb")]
        public string? PaymentInfo { get; set; }

        public DateTime CreatedAt { get; set; }

        // Relationship (1 Center có nhiều Court)
        public ICollection<Court> Courts { get; set; } = new List<Court>();
    }
}
