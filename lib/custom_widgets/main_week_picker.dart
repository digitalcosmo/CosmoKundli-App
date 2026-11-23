import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/mbAlgo_controller.dart';
import '../values/app_constants.dart';

class WeekPickerWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime lastDay;
  final DateTime initialDay;
  final ValueChanged<Map<String, dynamic>> onDateSelected;

  const WeekPickerWidget({
    super.key,
    required this.startDate,
    required this.lastDay,
    required this.initialDay,
    required this.onDateSelected,
  });

  @override
  _WeekPickerWidgetState createState() => _WeekPickerWidgetState();
}

class _WeekPickerWidgetState extends State<WeekPickerWidget> {
  late DateTime selectedDate;
  late int currentWeekNumber;
  late int currentYear;
  late DateTime weekStartDate;
  late DateTime weekEndDate;
  final ScrollController _scrollController = ScrollController();

  final MbalgoController _mbAlgoController = Get.find(tag: GetTags.mbAlgoTag);

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.initialDay; // Initialize with the *provided* initialDay
    currentWeekNumber = _mbAlgoController.getWeekNumber(selectedDate);
    _updateWeekDates(selectedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedWeek();
    });
  }

  @override
  void didUpdateWidget(covariant WeekPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is now *only* for external changes (from the arrows)
    if (widget.initialDay != oldWidget.initialDay) {
      setState(() {
        _mbAlgoController.initialDate.value =
            widget.initialDay; // Update *only* when external change
        currentWeekNumber = _mbAlgoController
            .getWeekNumber(_mbAlgoController.initialDate.value);
        _updateWeekDates(_mbAlgoController.initialDate.value);
        _scrollToSelectedWeek();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("Dispose");
  }

  void _updateWeekDates(DateTime date) {
    int weekday = date.weekday;
    weekStartDate = date.subtract(Duration(days: weekday - 1));
    weekEndDate = weekStartDate.add(const Duration(days: 6));

    // Handle the edge case: If weekStartDate is in Dec but part of Week 1 of next year
    if (_mbAlgoController.getWeekNumber(weekStartDate) == 1 &&
        weekStartDate.year < weekEndDate.year) {
      weekStartDate = DateTime(weekEndDate.year, 1, 1)
          .subtract(Duration(days: weekEndDate.weekday - 1));
      weekEndDate = weekStartDate.add(const Duration(days: 6));
    }

    // Handle the edge case: If weekEndDate is in Jan but part of the last week of the previous year
    if (_mbAlgoController.getWeekNumber(weekEndDate) > 50 &&
        weekStartDate.year < weekEndDate.year) {
      weekEndDate = DateTime(weekStartDate.year, 12, 31);
      weekStartDate =
          weekEndDate.subtract(Duration(days: weekEndDate.weekday - 1));
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date; // Update *internal* selectedDate
      currentWeekNumber = _mbAlgoController.getWeekNumber(selectedDate);
      _updateWeekDates(selectedDate);
    });

    _mbAlgoController.selectedDate.value = date;

    widget.onDateSelected({
      // Callback with the *actual* selected date
      'weekNumber': currentWeekNumber,
      'date': date,
    });
  }

  void _scrollToSelectedWeek() {
    int weeksFromStartDate = (_mbAlgoController.selectedDate.value
                .difference(widget.startDate)
                .inDays /
            7)
        .floor();
    double targetOffset = weeksFromStartDate * 70.0; // Adjust 70.0 as needed
    if (_scrollController.hasClients) {
      // Check if controller is attached
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65.w,
      height: 50.h,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Week',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: _getTotalWeeks(),
              itemBuilder: (context, index) {
                DateTime firstDisplayedWeekStart = widget.startDate
                    .subtract(Duration(days: widget.startDate.weekday - 1));

                DateTime startOfWeek =
                    firstDisplayedWeekStart.add(Duration(days: index * 7));
                DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

                // Handle week transition edge case here too:
                int weekNumber = _mbAlgoController.getWeekNumber(startOfWeek);
                if (weekNumber == 1 && startOfWeek.year < endOfWeek.year) {
                  startOfWeek = DateTime(endOfWeek.year, 1, 1)
                      .subtract(Duration(days: endOfWeek.weekday - 1));
                  endOfWeek = startOfWeek.add(const Duration(days: 6));
                }

                if (startOfWeek.isBefore(widget.startDate)) {
                  startOfWeek = widget.startDate;
                }
                if (endOfWeek.isAfter(widget.lastDay)) {
                  endOfWeek = widget.lastDay;
                }

                String formattedWeek =
                    '${_mbAlgoController.getWeekInfo(startOfWeek)['formattedWeek']}';

                bool isSelected = _mbAlgoController.initialDate.value
                        .isAtSameMomentAs(startOfWeek) ||
                    (_mbAlgoController.initialDate.value.isAfter(startOfWeek) &&
                        _mbAlgoController.initialDate.value
                            .isBefore(endOfWeek)) ||
                    _mbAlgoController.initialDate.value
                        .isAtSameMomentAs(endOfWeek);

                return GestureDetector(
                  onTap: () {
                    _onDateSelected(startOfWeek);
                    String formattedWeek2 =
                        '${_mbAlgoController.getWeekInfo(startOfWeek)['formattedWeek']}';
                    _mbAlgoController.getWeekInfo(startOfWeek);
                    _mbAlgoController.formatedWeekDays.value = formattedWeek2;
                    _mbAlgoController.fetchStarPowerReport(AppConstants
                        .iconList[_mbAlgoController
                        .selectedIconIndex.value]['name']
                        .toString());
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: formattedWeek ==
                                _mbAlgoController.formatedWeekDays.value
                            ? CkColors.linkBlue
                            : CkColors.textMuted,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      color: formattedWeek ==
                              _mbAlgoController.formatedWeekDays.value
                          ? CkColors.linkBlue.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Text(
                      formattedWeek,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? CkColors.linkBlue : CkColors.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalWeeks() {
    DateTime startOfFirstWeek =
        widget.startDate.subtract(Duration(days: widget.startDate.weekday - 1));
    DateTime endOfLastWeek =
        widget.lastDay.add(Duration(days: 7 - widget.lastDay.weekday));
    int totalDays = endOfLastWeek.difference(startOfFirstWeek).inDays + 1;
    return (totalDays / 7).ceil();
  }

  updateWeek({required bool isIncrement}) async {
    int weekChange = isIncrement ? 1 : -1;
    _mbAlgoController.initialDate.value =
        _mbAlgoController.initialDate.value.add(Duration(days: weekChange * 7));
    _mbAlgoController.initialDateCalendar.value =
        _mbAlgoController.initialDate.value; // Update for arrows
    _mbAlgoController.selectedDateFromPicker.value =
        _mbAlgoController.initialDate.value; // Update for arrows
    getWeekNumber(_mbAlgoController.initialDate.value);

    Map<String, dynamic> weekInfo =
        _mbAlgoController.getWeekInfo(_mbAlgoController.initialDate.value);

    _mbAlgoController.formatedWeekDays.value = weekInfo['formattedWeek'];
  }

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber == 53 ? 1 : weekNumber;
  }
}
