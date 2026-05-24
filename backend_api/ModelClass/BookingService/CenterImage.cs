using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ModelClass.BookingService
{
    [Table("center_images", Schema = "booking")]
    public class CenterImage
    {
        [Key]
        public int Id { get; set; }

        public Guid CenterId { get; set; }
        [ForeignKey("CenterId")]
        public Center? Center { get; set; }

        public string ImageUrl { get; set; } = null!;
        public bool IsThumbnail { get; set; }
    }
}