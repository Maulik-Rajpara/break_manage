import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:flutter/services.dart';
import '../widgets/break_widget.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/di/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool breakEnded = false;
  bool userEndedBreak = false;
  bool breakNotStarted = false;
  String? username;
  bool loading = true;
  bool breakLoading = true;
  Map<String, dynamic>? breakData;
  Timer? _timer;
  String _remainingTime = '';
  double _progress = 0.0;
  String _breakEndsTime = '';
  String _breakStartTime = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadBreak();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeAndProgress();
    });
  }

    void _calculateTimeAndProgress() {
    if (breakData == null) return;

    try {
      final start = breakData!['start_time'] as String?;
      final duration = breakData!['duration'] as int?;
      
      if (start != null && duration != null) {
        final startParts = start.split(':');
        final now = DateTime.now();
        
        // Create startDateTime using today's date with the time from Firestore
        final startDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(startParts[0]),
          int.parse(startParts[1]),
          int.parse(startParts[2]),
        );
        
        // Check if break hasn't started yet
        if (startDateTime.isAfter(now)) {
          // Break hasn't started yet
          final startTimeStr = DateFormat('hh:mm a').format(startDateTime);
          setState(() {
            breakNotStarted = true;
            breakEnded = false;
            userEndedBreak = false;
            _breakStartTime = startTimeStr;
          });
          return;
        }
        
        // If start time is in the future (next day), adjust to yesterday
        final adjustedStartDateTime = startDateTime.isAfter(now) 
            ? startDateTime.subtract(const Duration(days: 1))
            : startDateTime;
            
        final endDateTime = adjustedStartDateTime.add(Duration(minutes: duration));
        
        // Calculate remaining time
        final remaining = endDateTime.difference(now);
        if (remaining.isNegative) {
          // Break has ended - show refreshed component
          setState(() {
            breakEnded = true;
            breakNotStarted = false;
            _remainingTime = '00:00';
            _progress = 100.0;
            _breakEndsTime = DateFormat('hh:mm a').format(endDateTime);
          });
          return;
        }
        
        final totalSeconds = duration * 60; // Convert minutes to seconds
        final elapsedSeconds = now.difference(adjustedStartDateTime).inSeconds;
        
        // Format remaining time in MM:SS using the correct remaining duration
        final totalRemainingSeconds = remaining.inSeconds;
        final remainingMinutes = totalRemainingSeconds ~/ 60;
        final remainingSeconds = totalRemainingSeconds % 60;
        final timeString = '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
        
        // Calculate progress percentage (normal - increases as time progresses)
        final progress = (elapsedSeconds / totalSeconds * 100).clamp(0.0, 100.0);
        
        setState(() {
          breakEnded = false; // Ensure timer is shown if break is still active
          breakNotStarted = false;
          _remainingTime = timeString;
          _progress = progress;
          _breakEndsTime = DateFormat('hh:mm a').format(endDateTime);
        });
      }
    } catch (e) {
      // Handle any parsing errors
      setState(() {
        breakEnded = false;
        breakNotStarted = false;
        _remainingTime = '--:--';
        _progress = 0.0;
        _breakEndsTime = '--:--';
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = locator<PreferenceService>();
    final userService = locator<UserService>();
    final userId = await prefs.getUserId();
    if (userId != null) {
      final doc = await userService.usersRef.doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      setState(() {
        username = data?['username'] ?? '';
        loading = false;
      });
    } else {
      setState(() {
        username = '';
        loading = false;
      });
    }
  }

  Future<void> _loadBreak() async {
    final breaksRef = FirebaseFirestore.instance.collection('breaks');
    final query = await breaksRef.orderBy('start_time', descending: true).limit(1).get();
    
    if (query.docs.isNotEmpty) {
      final breakDoc = query.docs.first;
      final breakId = breakDoc.id;
      final breakData = breakDoc.data();
      
      // Check if this break is from today using created_at field
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final breakCreatedAt = breakData['created_at'] as Timestamp?;
      
      if (breakCreatedAt != null) {
        final breakCreatedDate = breakCreatedAt.toDate();
        
        // If break was created before today, create new break for today
        if (breakCreatedDate.isBefore(todayStart)) {
          print('Break is from past (created: ${breakCreatedDate.toString()}), creating new break for today');
          await _createNewBreakForToday();
          return;
        }
      } else {
        // If no created_at field, assume it's old and create new break
        print('No created_at field found, creating new break for today');
        await _createNewBreakForToday();
        return;
      }
      
      setState(() {
        this.breakData = breakData;
      });
      
      // Check if user has already ended this break
      final hasUserEnded = await _checkIfUserEndedBreak(breakId);
      print('User ended break check result: $hasUserEnded');
      
      if (hasUserEnded) {
        // User has ended the break - show "break is over"
        print('User has ended break, showing break over screen');
        setState(() {
          userEndedBreak = true;
          breakEnded = true;
          breakLoading = false;
        });
      } else {
        // User hasn't ended the break - check if break time has expired
        print('User hasn\'t ended break, checking if time expired');
        setState(() {
          userEndedBreak = false;
        });
        
        _calculateTimeAndProgress();
        
        // Only start timer if break hasn't ended
        if (!breakEnded) {
          _startTimer();
        }
        
        setState(() {
          breakLoading = false;
        });
      }
    } else {
      // No breaks exist, create new one
      await _createNewBreakForToday();
    }
  }

  Future<void> _createNewBreakForToday() async {
    final breaksRef = FirebaseFirestore.instance.collection('breaks');
    final now = DateTime.now();
    final startHour = DateTime(now.year, now.month, now.day, now.hour);
    final startTimeStr = DateFormat('HH:00:00').format(startHour);
    
    final docRef = await breaksRef.add({
      'start_time': startTimeStr,
      'duration': 60,
      'created_at': FieldValue.serverTimestamp(),
    });
    final doc = await docRef.get();
    
    setState(() {
      breakData = doc.data() as Map<String, dynamic>?;
      userEndedBreak = false; // New break, user hasn't ended it
    });
    
    _calculateTimeAndProgress();
    
    // Only start timer if break hasn't ended
    if (!breakEnded) {
      _startTimer();
    }
    
    setState(() {
      breakLoading = false;
    });
  }

  Future<void> _refreshBreak() async {
    await _loadBreak();
  }

  Future<bool> _checkIfUserEndedBreak(String breakId) async {
    try {
      final prefs = locator<PreferenceService>();
      final userId = await prefs.getUserId();
      
      if (userId == null) return false;

      final userBreaksRef = FirebaseFirestore.instance.collection('user_breaks');
      final query = await userBreaksRef
          .where('user_id', isEqualTo: userId)
          .where('break_id', isEqualTo: breakId)
          .limit(1)
          .get();
      
      // Debug logging
      print('Checking user_breaks for userId: $userId, breakId: $breakId');
      print('Query results: ${query.docs.length} documents found');
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user ended break: $e');
      return false;
    }
  }

  Future<void> _endBreakNow() async {
    try {
      final prefs = locator<PreferenceService>();
      final userId = await prefs.getUserId();
      
      if (userId == null || breakData == null) {
        print('Error: User ID or break data is null');
        return;
      }

      // Get the current break document ID
      final breaksRef = FirebaseFirestore.instance.collection('breaks');
      final query = await breaksRef.orderBy('start_time', descending: true).limit(1).get();
      
      if (query.docs.isEmpty) {
        print('Error: No break document found');
        return;
      }

      final breakId = query.docs.first.id;
      
      // Check if user has already ended this break today
      final hasUserEnded = await _checkIfUserEndedBreak(breakId);
      
      if (hasUserEnded) {
        print('User has already ended this break today, no new entry needed');
        // Update UI to show break ended (in case it wasn't showing)
        setState(() {
          breakEnded = true;
          userEndedBreak = true;
        });
        return;
      }

      final now = DateTime.now();
      final endTimeStr = DateFormat('HH:mm:ss').format(now);

      // Create entry in user_breaks collection
      final userBreaksRef = FirebaseFirestore.instance.collection('user_breaks');
      final docRef = await userBreaksRef.add({
        'user_id': userId,
        'break_id': breakId,
        'end_time': endTimeStr,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('Break ended successfully: user_id=$userId, break_id=$breakId, end_time=$endTimeStr');
      print('Created user_breaks document with ID: ${docRef.id}');
      
      // Update UI to show break ended
      setState(() {
        breakEnded = true;
        userEndedBreak = true;
      });
      
    } catch (e) {
      print('Error ending break: $e');
      // You might want to show an error message to the user here
    }
  }

  Future<void> _logout() async {
    final prefs = locator<PreferenceService>();
    await prefs.clearUserId();
    if (mounted) {
      context.go('/login');
    }
  }

  void _showEndBreakSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppString.endingBreakTitle,
                style: TextStyle(
                  color: AppColors.primeTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppString.endingBreakMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppString.continueBtn,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _endBreakNow();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.redColor,
                          side: BorderSide(color: AppColors.redColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          AppString.endNowBtn,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.dashboardHeaderAlt,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Stack(
          children: [
            // Header background image
            Container(
              height: 270.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetPath.bgHeader),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Top header row
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row: menu, help, tea icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetPath.menuIcon,
                          width: 28.w,
                          height: 28.w,
                          color: Colors.white,
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.call, color: Colors.white, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                AppString.help,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Image.asset(
                          AssetPath.teaIcon,
                          width: 28.w,
                          height: 28.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    // Second row: greeting and logout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        loading
                          ? SizedBox(
                             width: 0,
                            )
                          : Text(
                              username != null && username!.isNotEmpty
                                ? 'Hi, $username!'
                                : 'Hi!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                        GestureDetector(
                          onTap: _logout,
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Third row: status label
                    Text(
                      breakNotStarted
                          ? 'Break will start soon'
                          : (breakEnded || userEndedBreak) 
                              ? 'Your break is over'
                              : AppString.dashboardStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content (break widget or refreshed card)
            Positioned.fill(
              top: 190.h, // Move card further down
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: breakLoading
                    ? _BreakLoadingCard()
                    : breakNotStarted
                        ? _BreakWillStartCard(startTime: _breakStartTime)
                        : (breakEnded || userEndedBreak)
                            ? _BreakEndedCard()
                            : BreakWidget(
                                key: ValueKey(breakData?['start_time'] ?? 'no-data'),
                                onEndBreak: _showEndBreakSheet,
                                remainingTime: _remainingTime,
                                progress: _progress,
                                breakEndsTime: _breakEndsTime,
                              ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakEndedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dashboardGradientStart,
            AppColors.dashboardGradientMid,
            AppColors.dashboardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.dashboardGradientMid.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Center(
            child: Image.asset(
              AssetPath.checkmarkIcon,
              width: 80.sp,
              height: 80.sp,
            ),
          ),
          SizedBox(height: 32),
          Text(
            AppString.refreshedMsg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dashboardGradientStart,
            AppColors.dashboardGradientMid,
            AppColors.dashboardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.dashboardGradientMid.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Loading break status...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakWillStartCard extends StatelessWidget {
  final String startTime;
  
  const _BreakWillStartCard({required this.startTime});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dashboardGradientStart,
            AppColors.dashboardGradientMid,
            AppColors.dashboardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.dashboardGradientMid.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Center(
              child: Icon(
                Icons.schedule,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Our break will start at $startTime',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
} 