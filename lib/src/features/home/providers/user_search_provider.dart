import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/constants/constants.dart';
import '../../../common/models/user_model.dart';
import '../../../common/repository/firebase_auth_repository.dart';
import '../../../common/repository/firebase_firestore_repository.dart';

class UserSearchProvider extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (
        BuildContext context,
        WidgetRef ref,
        Widget? child,
      ) {
        final firebaseFirestoreRepository =
            ref.watch(firebaseFirestoreRepositoryProvider);
        final currentUser = ref.watch(firebaseAuthProvider).currentUser;
        return FutureBuilder(
          future: firebaseFirestoreRepository
              .getUserUidList(Constants.usersCollection),
          builder: (context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (snapshot.hasData) {
              final List<UserModel> userList = snapshot.data!;
              final List<UserModel> searchResults = userList
                  .where((element) =>
                      element.getDisplayName
                          .toLowerCase()
                          .contains(query.toLowerCase()) &&
                      element.uid != currentUser!.uid)
                  .toList();
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(searchResults[index].getPhotoUrl),
                    ),
                    title: Text(searchResults[index].getDisplayName),
                    onTap: () {
                      close(context, searchResults[index].uid);
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
