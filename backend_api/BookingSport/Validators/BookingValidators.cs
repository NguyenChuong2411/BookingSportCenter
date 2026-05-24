using FluentValidation;
using BookingSport.DTOs;

namespace BookingSport.Validators
{
    public class CreateBookingRequestValidator : AbstractValidator<CreateBookingRequest>
    {
        public CreateBookingRequestValidator()
        {
            RuleFor(x => x.CourtId)
                .NotEmpty().WithMessage("Court ID is required");

            RuleFor(x => x.BookingDate)
                .NotEmpty().WithMessage("Booking date is required")
                .GreaterThanOrEqualTo(DateOnly.FromDateTime(DateTime.Now))
                .WithMessage("Booking date cannot be in the past");

            RuleFor(x => x.StartTime)
                .NotEmpty().WithMessage("Start time is required")
                .LessThan(x => x.EndTime).WithMessage("Start time must be before end time");

            RuleFor(x => x.EndTime)
                .NotEmpty().WithMessage("End time is required")
                .GreaterThan(x => x.StartTime).WithMessage("End time must be after start time");

            RuleFor(x => x)
                .Must(request =>
                {
                    var today = DateOnly.FromDateTime(DateTime.Now);
                    if (request.BookingDate > today)
                        return true;

                    if (request.BookingDate < today)
                        return false;

                    var nowTime = DateTime.Now.TimeOfDay;
                    return request.StartTime > nowTime;
                })
                .WithMessage("Start time must be in the future for today");
        }
    }

    public class UpdateBookingRequestValidator : AbstractValidator<UpdateBookingRequest>
    {
        public UpdateBookingRequestValidator()
        {
            RuleFor(x => x.BookingDate)
                .NotEmpty().WithMessage("Booking date is required")
                .GreaterThanOrEqualTo(DateOnly.FromDateTime(DateTime.Now))
                .WithMessage("Booking date cannot be in the past");

            RuleFor(x => x.StartTime)
                .NotEmpty().WithMessage("Start time is required")
                .LessThan(x => x.EndTime).WithMessage("Start time must be before end time");

            RuleFor(x => x.EndTime)
                .NotEmpty().WithMessage("End time is required")
                .GreaterThan(x => x.StartTime).WithMessage("End time must be after start time");

            RuleFor(x => x)
                .Must(request =>
                {
                    var today = DateOnly.FromDateTime(DateTime.Now);
                    if (request.BookingDate > today)
                        return true;

                    if (request.BookingDate < today)
                        return false;

                    var nowTime = DateTime.Now.TimeOfDay;
                    return request.StartTime > nowTime;
                })
                .WithMessage("Start time must be in the future for today");
        }
    }
}
