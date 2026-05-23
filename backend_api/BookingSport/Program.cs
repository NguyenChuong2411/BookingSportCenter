using Microsoft.EntityFrameworkCore; // Dòng này để chữa lỗi CS1061 (Không hiểu UseNpgsql)
using ModelClass.Connection;         // Dòng này để chữa lỗi CS0246 (Không hiểu BookingDbContext)

var builder = WebApplication.CreateBuilder(args);

// Khai báo kết nối Database cho BookingService
builder.Services.AddDbContext<BookingDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        x => {
            x.MigrationsAssembly("ModelClass");
            x.MigrationsHistoryTable("__EFMigrationsHistory", "booking"); 
        }
    )
);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();
app.Run();