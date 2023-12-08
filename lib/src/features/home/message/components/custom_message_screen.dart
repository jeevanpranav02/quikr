// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/helper/helper.dart';
import '../../../../common/models/message_model.dart';
import '../../../../common/models/user_model.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_layout.dart';
import '../../../../config/app_secure_storage.dart';
import '../../../../config/app_text.dart';
import '../../repository/chat_repository.dart';
import '../../repository/user_repository.dart';

final pageStorageBucket = PageStorageBucket();

class CustomMessageScreen extends ConsumerStatefulWidget {
  const CustomMessageScreen({required this.userModel, super.key});

  static const routeName = '/custom-message-screen';
  final UserModel userModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomMessageScreenState();
}

class _CustomMessageScreenState extends ConsumerState<CustomMessageScreen> {
  final messageTextController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<MessageModel> messages = <MessageModel>[];
  String uidOfSender = '';

  @override
  void initState() {
    super.initState();
    setCurrentUserUID();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    super.dispose();
  }

  Future<void> setCurrentUserUID() async {
    uidOfSender = await AppSecureStorage.getUID() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: height * 0.08,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          child: Row(
            children: [
              getProfile(context),
              AppLayout.horizontalSpacer(15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userModel.getDisplayName,
                    style: AppText.textStyleAppBar,
                  ),
                  AppLayout.verticalSpacer(5),
                  StreamBuilder(
                    stream: ref
                        .read(userRepositoryProvider)
                        .getUserPresenceStatus(uid: widget.userModel.uid),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        Helper.showAlertDialog(
                          context: context,
                          message: snapshot.error.toString(),
                        );
                        return const SizedBox();
                      } else if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          snapshot.connectionState != ConnectionState.active) {
                        return const SizedBox();
                      }
                      final singleUserModel = snapshot.data!;
                      final lastMessage =
                          Helper.lastSeenMessage(singleUserModel.lastSeen);
                      return Text(
                        singleUserModel.active
                            ? 'online'
                            : "last seen $lastMessage ago",
                        style: AppText.textStyleBody.copyWith(
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: AppLayout.paddingSmall,
              child: StreamBuilder(
                  stream: ref
                      .watch(chatRepositoryProvider)
                      .getAllOneToOneMessage(widget.userModel.uid),
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
                    messages = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.active) {
                      return ListView.builder(
                        reverse: false,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          bool isSender =
                              messages[index].getSenderId == uidOfSender;
                          return Container(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            margin: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                            ),
                            child: ClipPath(
                              clipper: MyClipper(
                                isSender,
                                nipWidth: 8,
                                nipHeight: 10,
                                bubbleRadius: 12,
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                color: isSender
                                    ? Theme.of(context).primaryColor
                                    : AppColors.grey,
                                child: Text(
                                  messages[index].getTextMessage,
                                  style: AppText.textStyleBody.copyWith(
                                    color: isSender
                                        ? AppColors.black
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                    // return PageStorage(
                    //   bucket: pageStorageBucket,
                    //   child: ListView.builder(
                    //     key: const PageStorageKey('message-list'),
                    //     controller: scrollController,
                    //     reverse: true,
                    //     itemCount: snapshot.data!.length ?? 0,
                    //     shrinkWrap: true,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       final message = snapshot.data[index];
                    //       final isSender = message.senderId ==
                    //           ref.read(firebaseAuthProvider).currentUser!.uid;
                    //       final haveNip = (index == 0) ||
                    //           (index == snapshot.data!.length - 1 &&
                    //               message.senderId !=
                    //                   snapshot.data![index - 1].senderId) ||
                    //           (message.senderId !=
                    //                   snapshot.data![index - 1].senderId &&
                    //               message.senderId ==
                    //                   snapshot.data![index + 1].senderId) ||
                    //           (message.senderId !=
                    //                   snapshot.data![index - 1].senderId &&
                    //               message.senderId !=
                    //                   snapshot.data![index + 1].senderId);
                    //       return const Column(
                    //         children: [],
                    //       );
                    //     },
                    //   ),
                    // );
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: AppLayout.paddingSmall.copyWith(
                  left: width * 0.05,
                  right: width * 0.05,
                ),
                child: SizedBox(
                  width: width * 0.8,
                  child: InkWell(
                    child: TextField(
                      controller: messageTextController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: AppText.textStyleHint,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50.0),
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  sendTextMessage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void sendTextMessage() async {
    final uid = await AppSecureStorage.getUID();
    ref.read(chatRepositoryProvider).sendTextMessage(
          context: context,
          textMessage: messageTextController.text,
          receiverId: widget.userModel.uid,
          senderData: await ref
              .read(userRepositoryProvider)
              .getUserDetailsFromUID(uid!),
        );
    messageTextController.clear();
    // await Future.delayed(const Duration(milliseconds: 100));
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   scrollController.animateTo(
    //     scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeOut,
    //   );
    // });
  }

  Widget getProfile(BuildContext context) {
    if (widget.userModel.getPhotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.userModel.getPhotoUrl,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 30,
        child: const Icon(
          Icons.person,
          color: AppColors.black,
        ),
      );
    }
  }

  String getOnlineStatus() {
    if (widget.userModel.getActive) {
      return 'Online';
    } else {
      return '${Helper.lastSeenMessage(widget.userModel.getLastSeen)} ago';
    }
  }
}

class MyClipper extends CustomClipper<Path> {
  final bool isSender;
  final double bubbleRadius;
  final double nipHeight;
  final double nipWidth;
  final double nipRadius;

  MyClipper(
    this.isSender, {
    this.bubbleRadius = 12,
    this.nipHeight = 12,
    this.nipWidth = 16,
    this.nipRadius = 2,
  });

  @override
  Path getClip(Size size) {
    var path = Path();

    if (isSender) {
      path.lineTo(size.width - nipRadius, 0);
      path.arcToPoint(Offset(size.width - nipRadius, nipRadius),
          radius: Radius.circular(nipRadius));
      path.lineTo(size.width - nipWidth, nipHeight);
      path.lineTo(size.width - nipWidth, size.height - bubbleRadius);
      path.arcToPoint(Offset(size.width - nipWidth - bubbleRadius, size.height),
          radius: Radius.circular(bubbleRadius));
      path.lineTo(bubbleRadius, size.height);
      path.arcToPoint(Offset(0, size.height - bubbleRadius),
          radius: Radius.circular(bubbleRadius));
      path.lineTo(0, bubbleRadius);
      path.arcToPoint(Offset(bubbleRadius, 0),
          radius: Radius.circular(bubbleRadius));
    } else {
      path.lineTo(size.width - bubbleRadius, 0);
      path.arcToPoint(Offset(size.width, bubbleRadius),
          radius: Radius.circular(bubbleRadius));
      path.lineTo(size.width, size.height - bubbleRadius);
      path.arcToPoint(Offset(size.width - bubbleRadius, size.height),
          radius: Radius.circular(bubbleRadius));
      path.lineTo(bubbleRadius + nipWidth, size.height);
      path.arcToPoint(Offset(nipWidth, size.height - bubbleRadius),
          radius: Radius.circular(bubbleRadius));
      path.lineTo(nipWidth, nipHeight);
      path.lineTo(nipRadius, nipRadius);
      path.arcToPoint(Offset(nipRadius, 0), radius: Radius.circular(nipRadius));
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => oldClipper != this;
}
