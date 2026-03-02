import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.backgroundGray,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.textWhite
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
