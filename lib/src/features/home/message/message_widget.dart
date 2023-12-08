import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../common/models/last_message_model.dart';
import '../../../common/models/user_model.dart';
import '../../../config/app_asset_path.dart';
import '../../../config/app_text.dart';
import '../../utils/date_util.dart';
import '../repository/chat_repository.dart';
import '../repository/user_repository.dart';
import 'components/custom_message_screen.dart';

class MessageWidget extends ConsumerStatefulWidget {
  const MessageWidget({super.key});

  static const appBarTitle = 'Messages';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends ConsumerState<MessageWidget> {
  Future<UserModel?> _fromUserUID(String uid) async {
    return await ref.read(userRepositoryProvider).getUserDetailsFromUID(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.watch(chatRepositoryProvider).getAllLastMessageList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  AppAssetPath.SAD_GHOST,
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  "You don't have any message yet",
                  style: AppText.textStyleBody,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            final LastMessageModel data = snapshot.data[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data.getProfileImageUrl),
              ),
              title: Text(data.getUsername),
              subtitle: Text(data.getLastMessage),
              trailing: Text(
                DateUtil.getFormattedDateTime(
                  DateUtil.getDateFromEpoch(data.getTimeSent),
                ),
              ),
              onTap: () async {
                UserModel? currentUser = await _fromUserUID(data.getSenderId);
                Navigator.pushNamed(
                  context,
                  CustomMessageScreen.routeName,
                  arguments: currentUser,
                );
              },
            );
          },
        );
      },
    );
  }
}
