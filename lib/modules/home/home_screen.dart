import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonar_app/modules/home/transfer_item.dart';
import 'package:sonar_app/theme/theme.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    // Build View
    controller.fetch();
    return SonrTheme(
        child: Scaffold(
            backgroundColor: NeumorphicTheme.baseColor(context),
            appBar: SonrHomeBar(() {
              Get.offNamed("/profile");
            }),
            floatingActionButton: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 80,
                  height: 240,
                  child: Column(
                      verticalDirection: VerticalDirection.up,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        NeumorphicButton(
                          onPressed: () {
                            controller.queueTest();
                          },
                          child: SonrText.normal("File"),
                        ),
                        NeumorphicButton(
                          onPressed: () {
                            controller.queueFatTest();
                          },
                          child: SonrText.normal("Fat File"),
                        ),
                        NeumorphicButton(
                          onPressed: () {
                            controller.queueContact();
                          },
                          child: SonrText.normal("Contact"),
                        )
                      ]),
                )),
            body: _HomeView()));
  }
}

class _HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GridView.builder(
          padding: EdgeInsets.only(left: 4, right: 4, bottom: 20, top: 2),
          itemCount: controller.allCards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 4),
          itemBuilder: (context, idx) {
            // Generate File Cell
            return TransferItem(controller.allCards[idx]);
          });
    });
  }
}
