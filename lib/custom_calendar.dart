class CustomCalendar extends StatefulWidget {
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color primaryColor;
  final Color textColor;
  final Color disabledColor;
  final String? fontFamily;
  final Locale locale;
  final bool isRTL;
  final Function(DateTime, DateTime)? startEndDateChange;

  const CustomCalendar({
    Key? key,
    this.minimumDate,
    this.maximumDate,
    this.initialStartDate,
    this.initialEndDate,
    required this.primaryColor,
    required this.textColor,
    required this.disabledColor,
    this.fontFamily,
    required this.locale,
    required this.isRTL,
    this.startEndDateChange,
  }) : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  List<DateTime> dateList = <DateTime>[];
  DateTime currentMonthDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    setListOfDate(currentMonthDate);
  }

  TextStyle _getTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: widget.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? widget.textColor,
    );
  }

  void setListOfDate(DateTime monthDate) {
    dateList.clear();
    final DateTime newDate = DateTime(monthDate.year, monthDate.month, 0);
    int previousMonthDay = 0;

    if (newDate.weekday < 7) {
      previousMonthDay = newDate.weekday;
      for (int i = 1; i <= previousMonthDay; i++) {
        dateList.add(newDate.subtract(Duration(days: previousMonthDay - i)));
      }
    }

    for (int i = 0; i < (42 - previousMonthDay); i++) {
      dateList.add(newDate.add(Duration(days: i + 1)));
    }

    // For RTL, we need to reverse the weeks to display correctly
    if (widget.isRTL) {
      List<DateTime> reversedList = [];
      for (int i = 0; i < dateList.length; i += 7) {
        var week = dateList.sublist(i, i + 7);
        reversedList.addAll(week.reversed);
      }
      dateList = reversedList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Month navigation header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Row(
            children: <Widget>[
              // Previous month button
              IconButton(
                icon: Icon(
                  widget.isRTL
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentMonthDate = DateTime(
                      currentMonthDate.year,
                      currentMonthDate.month,
                      0,
                    );
                    setListOfDate(currentMonthDate);
                  });
                },
              ),
              // Month/year display
              Expanded(
                child: Center(
                  child: Text(
                    intl.DateFormat(
                      'MMMM, yyyy',
                      widget.locale.toString(),
                    ).format(currentMonthDate),
                    style: _getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Next month button
              IconButton(
                icon: Icon(
                  widget.isRTL
                      ? Icons.keyboard_arrow_left
                      : Icons.keyboard_arrow_right,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentMonthDate = DateTime(
                      currentMonthDate.year,
                      currentMonthDate.month + 2,
                      0,
                    );
                    setListOfDate(currentMonthDate);
                  });
                },
              ),
            ],
          ),
        ),
        // Day names header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: getDaysNameUI()),
        ),
        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: getDaysNoUI()),
        ),
      ],
    );
  }

  List<Widget> getDaysNameUI() {
    final List<Widget> listUI = <Widget>[];
    final firstDay = widget.isRTL ? dateList[6] : dateList[0];
    final dateFormat = intl.DateFormat('EEE', widget.locale.toString());

    for (int i = 0; i < 7; i++) {
      final dayDate = firstDay.add(Duration(days: widget.isRTL ? -i : i));
      listUI.add(
        Expanded(
          child: Center(
            child: Text(
              dateFormat.format(dayDate),
              style: _getTextStyle(
                color: widget.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    return listUI;
  }

  List<Widget> getDaysNoUI() {
    final List<Widget> noList = <Widget>[];
    int count = 0;

    for (int i = 0; i < dateList.length / 7; i++) {
      final List<Widget> listUI = <Widget>[];

      for (int j = 0; j < 7; j++) {
        final DateTime date = dateList[count];
        final bool isCurrentMonth = currentMonthDate.month == date.month;
        final bool isDisabled = _isDateDisabled(date);
        final bool isSelected = getIsItStartAndEndDate(date);
        final bool isInRange = getIsInRange(date);

        listUI.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32.0),
                    onTap: isDisabled ? null : () => onDateClick(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.primaryColor
                            : isInRange
                            ? widget.primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: _getDateBorderRadius(date),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${date.day}',
                              style: _getTextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isCurrentMonth
                                    ? isDisabled
                                          ? widget.disabledColor
                                          : widget.textColor
                                    : widget.disabledColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isToday(date))
                            Positioned(
                              bottom: 6,
                              right: 0,
                              left: 0,
                              child: Center(
                                child: Container(
                                  height: 4,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : widget.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        count++;
      }

      noList.add(Row(children: listUI));
    }

    return noList;
  }

  bool _isDateDisabled(DateTime date) {
    if (widget.minimumDate != null && date.isBefore(widget.minimumDate!)) {
      return true;
    }
    if (widget.maximumDate != null && date.isAfter(widget.maximumDate!)) {
      return true;
    }
    return false;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool getIsInRange(DateTime date) {
    if (startDate != null && endDate != null) {
      return date.isAfter(startDate!) && date.isBefore(endDate!);
    }
    return false;
  }

  bool getIsItStartAndEndDate(DateTime date) {
    if (startDate != null &&
        startDate!.day == date.day &&
        startDate!.month == date.month &&
        startDate!.year == date.year) {
      return true;
    }
    if (endDate != null &&
        endDate!.day == date.day &&
        endDate!.month == date.month &&
        endDate!.year == date.year) {
      return true;
    }
    return false;
  }

  BorderRadius _getDateBorderRadius(DateTime date) {
    final bool isStart =
        startDate != null &&
        startDate!.day == date.day &&
        startDate!.month == date.month;
    final bool isEnd =
        endDate != null &&
        endDate!.day == date.day &&
        endDate!.month == date.month;

    if (isStart && isEnd) {
      return BorderRadius.circular(24.0);
    } else if (isStart) {
      return widget.isRTL
          ? const BorderRadius.only(
              topRight: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            )
          : const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
            );
    } else if (isEnd) {
      return widget.isRTL
          ? const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
            )
          : const BorderRadius.only(
              topRight: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            );
    } else if (date.weekday == (widget.isRTL ? 7 : 1)) {
      return widget.isRTL
          ? const BorderRadius.only(
              topRight: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            )
          : const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
            );
    } else if (date.weekday == (widget.isRTL ? 1 : 7)) {
      return widget.isRTL
          ? const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0),
            )
          : const BorderRadius.only(
              topRight: Radius.circular(24.0),
              bottomRight: Radius.circular(24.0),
            );
    }
    return BorderRadius.zero;
  }

  void onDateClick(DateTime date) {
    setState(() {
      if (startDate == null) {
        startDate = date;
      } else if (startDate != date && endDate == null) {
        endDate = date;
      } else if (startDate!.day == date.day && startDate!.month == date.month) {
        startDate = null;
      } else if (endDate != null &&
          endDate!.day == date.day &&
          endDate!.month == date.month) {
        endDate = null;
      }

      if (startDate == null && endDate != null) {
        startDate = endDate;
        endDate = null;
      }

      if (startDate != null && endDate != null) {
        if (!endDate!.isAfter(startDate!)) {
          final DateTime temp = startDate!;
          startDate = endDate;
          endDate = temp;
        }
      }

      widget.startEndDateChange?.call(startDate ?? date, endDate ?? date);
    });
  }
}

/// Helper function to show the date range picker dialog
void showCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  required Function(DateTime startDate, DateTime endDate) onApplyClick,
  required Function() onCancelClick,
  required Color backgroundColor,
  required Color primaryColor,
  Color textColor = Colors.black,
  Color disabledColor = Colors.grey,
  String? fontFamily,
  Locale locale = const Locale('en', 'US'),
}) {
  FocusScope.of(context).requestFocus(FocusNode());

  showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => Directionality(
      textDirection: locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Localizations.override(
        context: context,
        locale: locale,
        child: CustomDateRangePicker(
          barrierDismissible: dismissible,
          backgroundColor: backgroundColor,
          primaryColor: primaryColor,
          textColor: textColor,
          disabledColor: disabledColor,
          fontFamily: fontFamily,
          locale: locale,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          initialStartDate: startDate,
          initialEndDate: endDate,
          onApplyClick: onApplyClick,
          onCancelClick: onCancelClick,
        ),
      ),
    ),
  );
}
void showCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  required Function(DateTime startDate, DateTime endDate) onApplyClick,
  required Function() onCancelClick,
  required Color backgroundColor,
  required Color primaryColor,
  Color textColor = Colors.black,
  Color disabledColor = Colors.grey,
  String? fontFamily,
  Locale locale = const Locale('en', 'US'),
}) {
  FocusScope.of(context).requestFocus(FocusNode());

  showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => Directionality(
      textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Localizations.override(
        context: context,
        locale: locale,
        child: CustomDateRangePicker(
          barrierDismissible: dismissible,
          backgroundColor: backgroundColor,
          primaryColor: primaryColor,
          textColor: textColor,
          disabledColor: disabledColor,
          fontFamily: fontFamily,
          locale: locale,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          initialStartDate: startDate,
          initialEndDate: endDate,
          onApplyClick: onApplyClick,
          onCancelClick: onCancelClick,
        ),
      ),
    ),
  );
}