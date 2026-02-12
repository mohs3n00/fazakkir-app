import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
// import '../../../../core/services/notification_service.dart';
import '../../data/repositories/khatma_repository.dart';
import '../../../../l10n/app_localizations.dart';

class CreateKhatmaDialog extends StatefulWidget {
  const CreateKhatmaDialog({super.key});

  @override
  State<CreateKhatmaDialog> createState() => _CreateKhatmaDialogState();
}

class _CreateKhatmaDialogState extends State<CreateKhatmaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final KhatmaRepository _repository = KhatmaRepository();

  bool _isDateBased = true; // true: By Date, false: By Daily Amount
  DateTime? _selectedDate;
  int _dailyPages = 20;

  bool _enableReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 21,
    minute: 0,
  ); // 9 PM default

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _calculateDailyPages() {
    if (_selectedDate == null) return;
    final days = _selectedDate!.difference(DateTime.now()).inDays;
    if (days <= 0) {
      _dailyPages = 604;
    } else {
      _dailyPages = (604 / days).ceil();
    }
    setState(() {});
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isDateBased && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectDate)),
      );
      return;
    }

    await _repository.createKhatma(
      name: _nameController.text,
      targetDate: _isDateBased ? _selectedDate : null,
      dailyPageGoal: _isDateBased ? _dailyPages : _dailyPages,
      reminderEnabled: _enableReminder,
      reminderTime: _reminderTime,
      reminderTitle: AppLocalizations.of(context)!.khatmaReminderTitle,
      reminderBody: AppLocalizations.of(
        context,
      )!.khatmaReminderBody(_nameController.text),
    );

    /* 
    // Logic moved to Repository
    if (_enableReminder) {
      // Use NativeSchedulerService for standard notification sound
      await NativeSchedulerService().scheduleDailyKhatma(
        id: newKhatmaId.hashCode, // Unique ID based on Khatma ID
        title: AppLocalizations.of(context)!.khatmaReminderTitle,
        body: AppLocalizations.of(
          context,
        )!.khatmaReminderBody(_nameController.text),
        time: _reminderTime,
      );
    } 
    */

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.newKhatma,
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 20.sp,
                    color: isDark ? Colors.white : AppColors.islamicBrown,
                  ),
                ),
                SizedBox(height: 20.h),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.khatmaNameHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? l10n.required : null,
                ),
                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.byDate,
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        value: true,
                        groupValue: _isDateBased,
                        onChanged: (v) => setState(() => _isDateBased = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.byAmount,
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        value: false,
                        groupValue: _isDateBased,
                        onChanged: (v) => setState(() => _isDateBased = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                if (_isDateBased) ...[
                  ListTile(
                    title: Text(
                      _selectedDate == null
                          ? l10n.selectEndDate
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      style: TextStyle(fontFamily: "Cairo"),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                      );
                      if (d != null) {
                        setState(() => _selectedDate = d);
                        _calculateDailyPages();
                      }
                    },
                  ),
                  Text(
                    l10n.dailyPagesGoal(_dailyPages),
                    style: TextStyle(
                      color: AppColors.islamicGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.dailyPages,
                          style: TextStyle(fontFamily: "Cairo"),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: "20",
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _dailyPages = int.tryParse(v) ?? 20,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 16.h),
                Divider(color: Colors.grey.withOpacity(0.3)),

                SwitchListTile(
                  title: Text(
                    l10n.dailyReminder,
                    style: TextStyle(fontFamily: "Cairo", fontSize: 14.sp),
                  ),
                  subtitle: _enableReminder
                      ? Text(
                          _reminderTime.format(context),
                          style: TextStyle(
                            color: AppColors.islamicGold,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  value: _enableReminder,
                  activeThumbColor: AppColors.islamicGold,
                  onChanged: (v) => setState(() => _enableReminder = v),
                ),

                if (_enableReminder)
                  ListTile(
                    title: Text(
                      l10n.reminderTime,
                      style: TextStyle(fontFamily: "Cairo", fontSize: 14.sp),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: AppColors.islamicGold,
                    ),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (t != null) setState(() => _reminderTime = t);
                    },
                  ),

                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.islamicGold,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.startKhatma,
                    style: TextStyle(fontFamily: "Bakra", color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
