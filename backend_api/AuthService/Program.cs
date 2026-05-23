using Microsoft.EntityFrameworkCore;
using ModelClass.Connection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 🔴 CẤU HÌNH LẠI DATABASE ĐỂ ÉP BẢNG LỊCH SỬ VÀO ĐÚNG SCHEMA
builder.Services.AddDbContext<AuthDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        x => {
            x.MigrationsAssembly("ModelClass");
            x.MigrationsHistoryTable("__EFMigrationsHistory", "authentication"); 
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

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();
app.Run();