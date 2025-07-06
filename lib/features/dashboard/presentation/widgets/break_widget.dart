import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';

class BreakWidget extends StatelessWidget {
  final VoidCallback onEndBreak;
  final String remainingTime;
  final double progress;
  final String breakEndsTime;
  
  const BreakWidget({
    required this.onEndBreak,
    required this.remainingTime,
    required this.progress,
    required this.breakEndsTime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
          Text(
            AppString.breakEncouragement,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
            width: 200,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  startAngle: 120,
                  endAngle: 60,
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.13,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.white.withOpacity(0.18),
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: progress,
                      width: 0.13,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.white,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: null,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.0,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 50.sp),
                          Text(
                            remainingTime,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          SizedBox(height: 36.sp),
                          Text(
                            AppString.breakLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Divider(
            color: Colors.white.withOpacity(0.18),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 18),
          Text(
            '${AppString.breakEndsAt} $breakEndsTime',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),
          Divider(
            color: Colors.white.withOpacity(0.18),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onEndBreak,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightRedColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                AppString.endMyBreak,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 