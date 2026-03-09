import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class DateSelector extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.dates.first;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          final isSelected = _isSameDate(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),

              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// white dot
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                    /// SVG border
                    if (isSelected)
                      SvgPicture.asset(
                        "assets/icons/date_selected_border.svg",
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),

                    /// Background circle
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.backgroundGray,
                          width: 2,
                        ),
                      ),
                    ),

                    /// Date text
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontFamily: 'Oughter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.red : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
