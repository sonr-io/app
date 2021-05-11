import 'package:sonr_app/modules/peer/card_view.dart';
import 'package:sonr_app/style/style.dart';
import 'transfer_controller.dart';

class LobbyView extends GetView<TransferController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          width: Get.width,
          height: 260,
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: controller.scrollController,
            anchor: 0.225,
            slivers: LobbyService.local.value
                .mapMobileSorted(
                    userPosition: MobileService.position.value,
                    f: (i) => Builder(builder: (context) {
                          return SliverToBoxAdapter(key: ValueKey(i.id.peer), child: PeerCard(i));
                        }))
                .toList(),
          ),
        ));
  }
}