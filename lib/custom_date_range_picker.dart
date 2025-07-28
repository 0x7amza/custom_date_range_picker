import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';

/// A custom date range picker widget with multi-language, RTL support, and theme customization
class CustomDateRangePicker extends StatefulWidget {
  /// The minimum date that can be selected in the calendar.
  final DateTime minimumDate;

  /// The maximum date that can be selected in the calendar.
  final DateTime maximumDate;

  /// Whether the widget can be dismissed by tapping outside of it.
  final bool barrierDismissible;

  /// The initial start date for the date range picker.
  final DateTime? initialStartDate;

  /// The initial end date for the date range picker.
  final DateTime? initialEndDate;

  /// The primary color used for the date range picker.
  final Color primaryColor;

  /// The background color used for the date range picker.
  final Color backgroundColor;

  /// The text color used in the picker.
  final Color textColor;

  /// The color for disabled dates.
  final Color disabledColor;

  /// The font family to use throughout the picker.
  final String? fontFamily;

  /// The locale to use for formatting dates.
  final Locale locale;

  /// A callback function for when the user applies the selected date range.
  final Function(DateTime, DateTime) onApplyClick;

  /// A callback function for when the user cancels the selection.
  final Function() onCancelClick;

  const CustomDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onApplyClick,
    required this.onCancelClick,
    required this.minimumDate,
    required this.maximumDate,
    this.barrierDismissible = true,
    this.textColor = Colors.black,
    this.disabledColor = Colors.grey,
    this.fontFamily,
    this.locale = const Locale('en', 'US'),
  }) : super(key: key);

  @override
  CustomDateRangePickerState createState() => CustomDateRangePickerState();
}

class CustomDateRangePickerState extends State<CustomDateRangePicker>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          splashColor: Colors.transparent,
          onTap: () {
            if (widget.barrierDismissible) {
              Navigator.pop(context);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with dates
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isRTL ? 'إلى' : 'To',
                                    style: _getTextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    endDate != null
                                        ? intl.DateFormat(
                                            'EEE, dd MMM',
                                            widget.locale.toString(),
                                          ).format(endDate!)
                                        : '--/--',
                                    style: _getTextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 74,
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isRTL ? 'من' : 'From',
                                    style: _getTextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    startDate != null
                                        ? intl.DateFormat(
                                            'EEE, dd MMM',
                                            widget.locale.toString(),
                                          ).format(startDate!)
                                        : '--/--',
                                    style: _getTextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Calendar
                      CustomCalendar(
                        minimumDate: widget.minimumDate,
                        maximumDate: widget.maximumDate,
                        initialStartDate: widget.initialStartDate,
                        initialEndDate: widget.initialEndDate,
                        primaryColor: widget.primaryColor,
                        disabledColor: widget.disabledColor,
                        textColor: widget.textColor,
                        fontFamily: widget.fontFamily,
                        locale: widget.locale,
                        isRTL: isRTL,
                        startEndDateChange: (DateTime start, DateTime end) {
                          setState(() {
                            startDate = start;
                            endDate = end;
                          });
                        },
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: widget.primaryColor,
                                  side: BorderSide(color: widget.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  widget.onCancelClick();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  isRTL ? 'إلغاء' : 'Cancel',
                                  style: _getTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: widget.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  if (startDate != null && endDate != null) {
                                    widget.onApplyClick(startDate!, endDate!);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  isRTL ? 'تطبيق' : 'Apply',
                                  style: _getTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }
}
