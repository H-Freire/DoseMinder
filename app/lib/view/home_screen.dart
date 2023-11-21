import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doseminder/model/dosage.dart';
import 'package:doseminder/providers.dart';
import 'package:doseminder/widget/dose_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('DoseMinder'),
        actions: [
          IconButton(
              onPressed: () async {
                await ref.read(signInService).disconnect();
                await ref.read(auth).signOut();
                ref.read(userProvider.notifier).user = null;
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder(
            stream: ref
                .watch(collectionProvider(ref.watch(auth).currentUser!.uid))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error!');
              }
              if (snapshot.hasData) {
                final prescriptions =
                    Dosage.fromCollection(snapshot.data!.docs);
                return ListView.builder(
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final data = prescriptions[index];
                    return DoseCard(
                      data: data,
                      onTap: () => ref.read(mqttProvider).publish(
                            topic: 'doseminder/dosage',
                            data: data.toString(),
                          ),
                    );
                  },
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
/*       floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), */
    );
  }
}
