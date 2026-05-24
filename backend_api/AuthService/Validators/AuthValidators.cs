using FluentValidation;
using AuthService.Controllers;

namespace AuthService.Validators
{
    public class RegisterRequestValidator : AbstractValidator<AuthController.RegisterRequest>
    {
        public RegisterRequestValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required")
                .MinimumLength(3).WithMessage("Username must be at least 3 characters")
                .MaximumLength(50).WithMessage("Username must not exceed 50 characters")
                .Matches(@"^[a-zA-Z0-9_.-]+$").WithMessage("Username can only contain letters, numbers, dots, underscores, and hyphens");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Email format is invalid");

            RuleFor(x => x.FullName)
                .NotEmpty().WithMessage("Full name is required")
                .MinimumLength(2).WithMessage("Full name must be at least 2 characters")
                .MaximumLength(100).WithMessage("Full name must not exceed 100 characters");

            RuleFor(x => x.PhoneNumber)
                .NotEmpty().WithMessage("Phone number is required")
                .Matches(@"^\d{10,15}$").WithMessage("Phone number must be between 10-15 digits");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required")
                .MinimumLength(6).WithMessage("Password must be at least 6 characters")
                .MaximumLength(128).WithMessage("Password must not exceed 128 characters");
        }
    }

    public class LoginRequestValidator : AbstractValidator<AuthController.LoginRequest>
    {
        public LoginRequestValidator()
        {
            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required")
                .EmailAddress().WithMessage("Email format is invalid");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required");
        }
    }
}
