import 'package:flutter/material.dart';

class RoundedTop extends StatelessWidget {
  const RoundedTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child:Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)
                ),
                child: Container(
                  height: 50.0,
                  // margin: const EdgeInsets.only(top: 6.0),
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0)
                    ),
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.white,
                        width: 0,
                    ),
                  ),
                ),
              ),
            )
        )
    );
  }
}
