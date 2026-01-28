using Microsoft.EntityFrameworkCore;
using ModelClass.Authentication;

namespace ModelClass.Connection
{
    public class AuthDbContext : DbContext
    {
        public AuthDbContext(DbContextOptions<AuthDbContext> options) : base(options) { }

        // Chỉ khai báo những gì liên quan đến Auth
        public DbSet<User> Users { get; set; }

        // Nếu có bảng RefreshToken thì để vào đây luôn
        // public DbSet<RefreshToken> RefreshTokens { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Cấu hình Schema mặc định nếu muốn chắc chắn
            modelBuilder.HasDefaultSchema("authentication");
        }
    }
}
