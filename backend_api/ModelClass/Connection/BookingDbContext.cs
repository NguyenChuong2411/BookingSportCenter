using ModelClass.Booking;
using BookingEntity = ModelClass.Booking.Booking;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClass.Connection
{
    public class BookingDbContext : DbContext
    {
        public BookingDbContext(DbContextOptions<BookingDbContext> options) : base(options) { }

        // Khai báo các bảng nghiệp vụ
        public DbSet<Center> Centers { get; set; }
        public DbSet<Court> Courts { get; set; }
        public DbSet<BookingEntity> Bookings { get; set; }
        public DbSet<Sport> Sports { get; set; }
        // ... các bảng Pricing, Review, Image

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.HasDefaultSchema("booking");
        }
    }
}
