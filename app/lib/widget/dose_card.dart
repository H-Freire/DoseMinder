import 'package:doseminder/constants.dart';
import 'package:flutter/material.dart';

import 'package:doseminder/model/dosage.dart';

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
        height: 97,
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(dmPrimary),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: 6.0,
                height: 60.0,
                //margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(dmPrimary),
                  borderRadius: BorderRadius.circular(10),
                    //shape: BoxShape.rectangle,
                    border: Border.all(
                    color: Color(dmPrimary),
                    width: 2.0,)
                ),
                child: Center(child: Text(data.recipient.toString(),
                                          style:
                                                const TextStyle(fontSize: 15, /* fontWeight: FontWeight.bold, */ color: Colors.white)
                                      )
                        )
              ),
            ),
            //Text('id: ${data.recipient}'),
            Expanded(
              flex: 3,
              child: Text(
                data.name,
                textAlign: TextAlign.left,
                style:
                     const TextStyle(fontSize: 18, /* fontWeight: FontWeight.bold */color: Colors.white)
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    data.dose.toString(),              
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  const Image(
                    image: AssetImage('assets/icon.png'),
                    height: 60,
                    fit: BoxFit.scaleDown)
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
