using Microsoft.EntityFrameworkCore; // Dòng này để chữa lỗi CS1061 (Không hiểu UseNpgsql)
using ModelClass.Connection;         // Dòng này để chữa lỗi CS0246 (Không hiểu BookingDbContext)
using Microsoft.IdentityModel.Tokens;
using FluentValidation;
using BookingSport.Validators;
using System.Text;

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

// Khai báo kết nối Database cho BookingService
builder.Services.AddDbContext<BookingDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        x =>
        {
            x.MigrationsAssembly("ModelClass");
            x.MigrationsHistoryTable("__EFMigrationsHistory", "booking");
        }
    )
);

// JWT Authentication Configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = Encoding.ASCII.GetBytes(jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured"));

builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(secretKey),
            ValidateIssuer = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwtSettings["Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddControllers(options =>
{
    options.Filters.Add(typeof(BookingSport.Filters.ValidationFilter));
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<CreateBookingRequestValidator>();

// Register Services
builder.Services.AddScoped<BookingSport.Services.IBookingService, BookingSport.Services.BookingService>();

// Register Validation Filter
builder.Services.AddScoped<BookingSport.Filters.ValidationFilter>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = context =>
    {
        context.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
    }
});
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();