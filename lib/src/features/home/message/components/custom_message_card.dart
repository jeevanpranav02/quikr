import 'package:flutter/material.dart';

import '../../../../common/models/user_model.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_layout.dart';
import '../../../../config/app_text.dart';
import 'custom_message_screen.dart';

class CustomMessageCard extends StatefulWidget {
  const CustomMessageCard({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  State<CustomMessageCard> createState() => _CustomMessageCardState();
}

class _CustomMessageCardState extends State<CustomMessageCard> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: AppLayout.paddingSmall.copyWith(top: 5),
      child: Material(
        child: InkWell(
          splashColor: AppColors.primaryColor,
          borderRadius: AppLayout.borderRadiusSmall,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween = Tween(begin: 0.0, end: 1.0);
                  return FadeTransition(
                    opacity: animation.drive(tween),
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  return CustomMessageScreen(
                    userModel: widget.userModel,
                  );
                },
              ),
            );
          },
          child: Container(
            height: height * 0.1,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.5),
              border: Border.all(
                color: AppColors.grey.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: AppLayout.borderRadiusSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: AppLayout.paddingSmall,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: AppLayout.paddingSmall,
                          child: Text(
                            widget.userModel.getDisplayName,
                            style: AppText.textStyleSubtitle,
                          ),
                        ),
                        Padding(
                          padding: AppLayout.paddingSmall,
                          child: Text(
                            'Last Message',
                            style: AppText.textStyleHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: AppLayout.paddingSmall.copyWith(bottom: 0),
                      child: Text(
                        widget.userModel.getLastSeen.toString(),
                        style: AppText.textStyleHint,
                      ),
                    ),
                    Padding(
                      padding: AppLayout.paddingSmall,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        radius: 10,
                        child: Text(
                          '1',
                          style: AppText.textStyleHint.copyWith(
                            color: AppColors.primaryTextColor,
                            fontSize: 9,
                            fontWeight: AppText.fontWeightMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
