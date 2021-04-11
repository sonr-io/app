import 'package:sonr_app/theme/theme.dart';
import 'social_view.dart';
import 'tile_controller.dart';

// ** Builds Social Tile ** //
class SocialTileItem extends GetWidget<TileController> {
  final Contact_SocialTile item;
  final int index;
  SocialTileItem(this.item, this.index);
  @override
  Widget build(BuildContext context) {
    // Build View
    controller.initialize(item, index);

    // Build View Controller
    return Stack(children: [
      // Draggable Aspect
      LongPressDraggable(
          feedback: _buildView(controller.isEditing.value, isDragging: true),
          child: _buildView(controller.isEditing.value),
          data: item,
          childWhenDragging: Container(),
          onDragStarted: () {
            HapticFeedback.heavyImpact();
            controller.isDragging(true);
          }),

      DragTarget<Contact_SocialTile>(
        builder: (context, candidateData, rejectedData) {
          return Container();
        },
        // Only accept same tiles
        onWillAccept: (data) {
          return true;
        },
        // Switch Index Positions with animation
        onAccept: (data) {
          UserService.swapSocials(item, data);
        },
      ),
    ]);
  }

  // ^ Builds Neumorohic Item ^ //
  Widget _buildView(bool isEditing, {bool isDragging = false}) {
    // Theming View with Drag
    return GestureDetector(
      onTap: () {
        controller.toggleExpand(index);
        HapticFeedback.lightImpact();
      },
      onDoubleTap: () {
        Get.find<DeviceService>().launchURL(item.links.postLink);
        HapticFeedback.mediumImpact();
      },
      child: Neumorphic(
        margin: EdgeInsets.all(4),
        style: isEditing
            ? NeumorphicStyle(intensity: 0.75, shape: NeumorphicShape.flat, depth: 15)
            : NeumorphicStyle(intensity: 0.75, shape: NeumorphicShape.convex, depth: 8),
        child: Container(
          width: isDragging ? 125 : Get.width,
          height: isDragging ? 125 : Get.height,
          child: isDragging ? Icon(Icons.drag_indicator) : SocialView(controller, item, index),
        ),
      ),
    );
  }
}