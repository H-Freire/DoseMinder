import 'package:flutter/material.dart';

import 'package:doseminder/model/dosage.dart';
import 'package:doseminder/constants.dart';

class DoseCard extends StatelessWidget {
  const DoseCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final Dosage data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 150,
        margin: const EdgeInsets.all(15),
        color: const Color(dmSecondary),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('id: ${data.recipient}'),
            Text(data.name),
            Text(data.dose.toString()),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
