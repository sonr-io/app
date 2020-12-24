import 'package:get/get.dart';
import 'package:sonar_app/social/medium_data.dart';
import 'package:sonar_app/modules/profile/profile_controller.dart';
import 'package:sonar_app/social/social_provider.dart';
import 'package:sonar_app/theme/theme.dart';
import 'package:sonr_core/models/models.dart';

enum TileState {
  Loading,
  Dragging,
  None,
  Editing,
  NewStepOne,
  NewStepTwo,
  NewStepThree,
}

enum SocialAuthType { Link, OAuth }
enum SearchFilter { User, Playlist, Post }

class TileController extends GetxController {
  // Properties
  var fetchedData;
  var state = TileState.Loading;

  // Reactive
  final currentTile = Contact_SocialTile().obs;

  // References
  bool _isEditing = false;

  // ^ Create New Tile ^ //
  createTile() {
    currentTile(Contact_SocialTile());
    state = TileState.NewStepOne;
    update(["TileDialog"]);
  }

  // ^ Toggle Editing Mode ^ //
  editTile(Contact_SocialTile value) {
    _isEditing = !_isEditing;
    if (_isEditing) {
      currentTile(value);
      state = TileState.Editing;
    } else {
      currentTile(Contact_SocialTile());
      state = TileState.None;
    }
    update(["SocialTile"]);
  }

  // ^ Fetch Tile Data ^
  getData(Contact_SocialTile tile) async {
    // Data By Provdider
    if (tile.provider == Contact_SocialTile_Provider.Medium) {
      fetchedData =
          await Get.find<SocialMediaProvider>().getMedium(tile.username);
    }

    state = TileState.None;
    update(["SocialTile"]);
  }

  // ^ Determine Auth Type ^
  getAuthType(Contact_SocialTile tile) {
    // Link Item
    if (tile.provider == Contact_SocialTile_Provider.Medium ||
        tile.provider == Contact_SocialTile_Provider.Spotify ||
        tile.provider == Contact_SocialTile_Provider.YouTube) {
      return SocialAuthType.Link;
    }
    // OAuth Item
    else {
      return SocialAuthType.OAuth;
    }
  }

  // ^ Add Social Tile Move to Next Step ^ //
  nextStep() async {
    // @ Step 2
    if (state == TileState.NewStepOne) {
      if (currentTile.value.hasProvider()) {
        // Update State
        state = TileState.NewStepTwo;
        update(["TileDialog"]);
      } else {
        // Display Error Snackbar
        Get.snackbar("Hold Up!", "Select a social media provider first",
            snackStyle: SnackStyle.FLOATING,
            duration: Duration(milliseconds: 1500),
            forwardAnimationCurve: Curves.bounceIn,
            reverseAnimationCurve: Curves.easeOut,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.warning_outlined,
              color: Colors.white,
            ),
            colorText: Colors.white);
      }
    }
    // @ Step 3
    else if (state == TileState.NewStepTwo) {
      // Update State
      if (currentTile.value.hasUsername()) {
        if (await _checkMediumUsername()) {
          state = TileState.NewStepThree;
          update(["TileDialog"]);
        }
      } else {
        // Display Error Snackbar
        Get.snackbar("Wait!", "Add your information",
            snackStyle: SnackStyle.FLOATING,
            duration: Duration(milliseconds: 1500),
            forwardAnimationCurve: Curves.bounceIn,
            reverseAnimationCurve: Curves.easeOut,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.warning_outlined,
              color: Colors.white,
            ),
            colorText: Colors.white);
      }
    }
    // @ Finish
    else {
      // Validate
      if (currentTile.value.hasType() && state == TileState.NewStepThree) {
        // Add Tile to Contact and Save
        Get.find<ProfileController>().saveSocialTile(currentTile.value);

        // Reset Current Tile
        Get.back();
        state = TileState.None;
        currentTile(Contact_SocialTile());
      } else {
        // Display Error Snackbar
        Get.snackbar("Almost There!", "Pick a Tile Type",
            snackStyle: SnackStyle.FLOATING,
            duration: Duration(milliseconds: 1500),
            forwardAnimationCurve: Curves.bounceIn,
            reverseAnimationCurve: Curves.easeOut,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.warning_outlined,
              color: Colors.white,
            ),
            colorText: Colors.white);
      }
    }
  }

  // ^ Simple Data Validation ^ //
  // TODO: Temporary find Universal Method of Handling API's
  Future<bool> _checkMediumUsername() async {
    // Get Feed Data For Username
    var data = await Get.find<SocialMediaProvider>()
        .getMedium(currentTile.value.username);

    // Get Medium Model
    if (data != null) {
      if (data is MediumData) {
        return true;
      }
    }
    return false;
  }

  // ^ Add Social Tile Move to Next Step ^ //
  previousStep() {
    // First Step
    if (state == TileState.NewStepOne) {
      state = TileState.None;
      update(["TileDialog"]);
    }
    // Step 2
    else if (state == TileState.NewStepTwo) {
      state = TileState.NewStepOne;
      update(["TileDialog"]);
    }
    // Step 3
    else if (state == TileState.NewStepThree) {
      state = TileState.NewStepTwo;
      update(["TileDialog"]);
    }
  }

  // ^ Edit a Social Tile Type ^ //
  editType(Contact_SocialTile tile, dynamic data) {
    // TODO
    update(["SocialTile"]);
  }

  // ^ Edit a Social Tile Type ^ //
  editPosition(Contact_SocialTile tile, dynamic data) {
    // TODO
    update(["SocialTile"]);
  }

  // ^ Edit a Social Tile Type ^ //
  editShowcase(Contact_SocialTile tile, dynamic data) {
    // TODO
    update(["SocialTile"]);
  }

  // ^ Edit a Social Tile Type ^ //
  editFeed(Contact_SocialTile tile, dynamic data) {
    // TODO
    update(["SocialTile"]);
  }

  // ^ Remove a Social Tile ^ //
  deleteTile() {
    // Remove Tile from Contact and Save
    Get.find<ProfileController>().removeSocialTile(currentTile.value);
    update(["SocialTile"]);
  }
}
