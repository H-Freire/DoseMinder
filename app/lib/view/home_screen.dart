//import 'dart:ffi';

import 'package:doseminder/constants.dart';
import 'package:flutter/material.dart';
import 'package:doseminder/providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mqtt_client/mqtt_server_client.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({required this.client, super.key});
  final Future<MqttServerClient> client;

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
                ref.read(user.notifier).user = null;
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
                /* } else if (snapshot.connectionState == ConnectionState.done) {
                return Text('done'); */
              } else if (snapshot.hasError) {
                return Text('Error!');
              }
              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return InkWell(
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.all(15),
                        color: Color(dmSecondary),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('id: ${data['recipient']!}'),
                            Text('${data['name']!}'),
                            Text('${data['dose']!}'),
                          ],
                        ),
                      ),
                      onTap: () {
                        var currentSerial = _dataToSerial(data['dose'], data['recipient']);
                        print("Envia esse serial: $currentSerial");
                      },
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

String _dataToSerial(dynamic dose, dynamic recipient) {
  var doseBinary = dose.toRadixString(2);
  var recipientBinary = recipient.toRadixString(2);
  var parity = '0';

  print(doseBinary);
  print(recipientBinary);

  return parity;
}
