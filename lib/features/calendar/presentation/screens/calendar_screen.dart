import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    HijriCalendar.setLocal(Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.hijriCalendar,
          style: TextStyle(fontFamily: "Bakra", fontSize: 22.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTableCalendar(isDark),
          const SizedBox(height: 20),
          _buildSelectedDateDetails(isDark),
        ],
      ),
    );
  }

  Widget _buildTableCalendar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: TableCalendar(
        locale: Localizations.localeOf(context).toString(),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.saturday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: "Cairo",
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.islamicGold,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.islamicGold,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: isDark ? Colors.redAccent : Colors.red,
          ),
          defaultTextStyle: TextStyle(
            fontFamily: "Cairo",
            color: isDark ? Colors.white : Colors.black,
          ),

          // Today decoration
          todayDecoration: BoxDecoration(
            color: AppColors.islamicGold.withOpacity(0.5),
            shape: BoxShape.circle,
          ),

          // Selected decoration
          selectedDecoration: BoxDecoration(
            color: AppColors.islamicGold,
            shape: BoxShape.circle,
          ),
        ),

        // Custom Builder to show Hijri Day
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isDark);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isDark, isSelected: true);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isDark, isToday: true);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    bool isDark, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    HijriCalendar hijriDate = HijriCalendar.fromDate(day);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.islamicGold
            : (isToday
                  ? AppColors.islamicGold.withOpacity(0.3)
                  : Colors.transparent),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: isToday && !isSelected
            ? Border.all(color: AppColors.islamicGold, width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hijri Day (Big)
          Text(
            "${hijriDate.hDay}",
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          // Gregorian Day (Small)
          Text(
            "${day.day}",
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected
                  ? Colors.white70
                  : (isDark ? Colors.grey : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDetails(bool isDark) {
    if (_selectedDay == null) return const SizedBox.shrink();

    HijriCalendar hijriDate = HijriCalendar.fromDate(_selectedDay!);
    String gregorianDate = DateFormat(
      'EEEE, d MMMM yyyy',
      Localizations.localeOf(context).languageCode,
    ).format(_selectedDay!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? AppColors.darkCard : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              hijriDate.toFormat("dd MMMM yyyy"), // Hijri Date Full
              style: TextStyle(
                fontFamily: "Bakra",
                fontSize: 20.sp,
                color: AppColors.islamicGold,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Text(
              gregorianDate,
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Placeholder for events
            if (_hasEvent(hijriDate))
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.islamicGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.islamicGold),
                ),
                child: Text(
                  _getEventName(context, hijriDate),
                  style: TextStyle(
                    fontFamily: "Cairo",
                    color: AppColors.islamicGold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasEvent(HijriCalendar hijri) {
    // Simple example events
    if (hijri.hMonth == 9) return true; // Ramadan
    if (hijri.hMonth == 10 && hijri.hDay == 1) return true; // Eid Al Fitr
    if (hijri.hMonth == 12 && hijri.hDay == 10) return true; // Eid Al Adha
    return false;
  }

  String _getEventName(BuildContext context, HijriCalendar hijri) {
    if (hijri.hMonth == 9) return AppLocalizations.of(context)!.ramadanEvent;
    if (hijri.hMonth == 10 && hijri.hDay == 1) {
      return AppLocalizations.of(context)!.eidFitrEvent;
    }
    if (hijri.hMonth == 12 && hijri.hDay == 10) {
      return AppLocalizations.of(context)!.eidAdhaEvent;
    }
    return "";
  }
}
