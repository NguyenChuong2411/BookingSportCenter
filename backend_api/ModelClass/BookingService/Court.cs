using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClass.Booking
{
    [Table("courts", Schema = "booking")]
    public class Court
    {
        [Key]
        public Guid Id { get; set; }

        public Guid CenterId { get; set; }
        [ForeignKey("CenterId")]
        public Center? Center { get; set; } // Navigation Property

        public int SportId { get; set; }
        [ForeignKey("SportId")]
        public Sport? Sport { get; set; }

        public string Name { get; set; } = null!;
        public string? CourtType { get; set; }
        public bool IsActive { get; set; }
    }
}
