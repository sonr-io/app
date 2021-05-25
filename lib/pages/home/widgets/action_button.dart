import 'package:sonr_app/modules/settings/sheet_view.dart';
import 'package:sonr_app/style/style.dart';
import '../home_controller.dart';
import '../views/remote/remote_controller.dart';

class HomeActionButton extends GetView<HomeController> {
  HomeActionButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedSlideSwitcher.fade(
          child: _buildView(controller.view.value),
          duration: const Duration(milliseconds: 2500),
        ));
  }

  // @ Build Page View by Navigation Item
  Widget _buildView(HomeView page) {
    // Return View
    if (page == HomeView.Profile) {
      return ActionButton(
        key: ValueKey<HomeView>(HomeView.Profile),
        icon: SonrIcons.Settings.gradient(size: 28),
        onPressed: () {
          Get.bottomSheet(SettingsSheet());
        },
      );
    } else if (page == HomeView.Activity) {
      return ActionButton(
          key: ValueKey<HomeView>(HomeView.Activity),
          icon: SonrIcons.CheckAll.gradient(size: 28),
          onPressed: () async {
            if (CardService.activity.length > 0) {
              var decision = await SonrOverlay.question(
                  title: "Clear?", description: "Would you like to clear all activity?", acceptTitle: "Yes", declineTitle: "Cancel");
              if (decision) {
                CardService.clearAllActivity();
              }
            }
          });
    } else if (page == HomeView.Remote) {
      return _RemoteActionButton();
    } else if (page == HomeView.Transfer) {
      return Container(width: 56, height: 56);
    } else {
      return Container(width: 56, height: 56);
    }
  }
}

/// @ Profile Action Button Widget
class _RemoteActionButton extends GetView<RemoteController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ActionButton(
          key: ValueKey<HomeView>(HomeView.Main),
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
        return SonrIcons.Plus.gradient(size: 28);
    }
  }
}
