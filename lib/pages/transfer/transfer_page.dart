import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonr_app/pages/transfer/remote/remote_controller.dart';
import 'package:sonr_app/style/style.dart';
import 'local/local_view.dart';
import 'payload_sheet.dart';
import 'transfer_controller.dart';

/// @ Transfer Screen Entry Point
class TransferScreen extends GetView<TransferController> {
  @override
  Widget build(BuildContext context) {
    // Build View
    return Obx(() => SonrScaffold(
          gradient: SonrGradients.PlumBath,
          appBar: DesignAppBar(
            centerTitle: true,
            leading: ActionButton(icon: SonrIcons.Close.gradient(value: SonrGradients.PhoenixStart), onPressed: () => Get.offNamed("/home")),
            action: _RemoteActionButton(),
            title: controller.title.value.headThree(align: TextAlign.center, color: UserService.isDarkMode ? SonrColor.White : SonrColor.Black),
          ),
          bottomSheet: PayloadSheetView(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // @ Lobby View
              Obx(() {
                // Carousel View
                if (controller.isNotEmpty.value) {
                  return LocalView();
                }

                // Default Empty View
                else {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(54),
                      height: 500,
                      child: SonrAssetIllustration.NoPeers.widget,
                    ),
                  );
                }
              }),
            ],
          ),
        ));
  }
}

/// @ Profile Action Button Widget
class _RemoteActionButton extends GetView<RemoteController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ActionButton(
          icon: _buildIcon(controller.status.value),
          onPressed: () {
            // Creates New Lobby
            if (controller.status.value.isDefault) {
              controller.create();
            }

            // Destroys Created Lobby
            else if (controller.status.value.isCreated) {
              controller.stop();
            }

            // Exits Lobby
            else if (controller.status.value.isJoined) {
              controller.leave();
            }
          },
        ));
  }

  // @ Builds Icon by Status
  Widget _buildIcon(RemoteViewStatus status) {
    switch (status) {
      case RemoteViewStatus.Created:
        return SonrIcons.Logout.gradient(value: SonrGradient.Critical, size: 28);

      case RemoteViewStatus.Joined:
        return SonrIcons.Logout.gradient(value: SonrGradient.Critical, size: 28);

      default:
        return SonrIcons.Compass.gradient(size: 28);
    }
  }
}
