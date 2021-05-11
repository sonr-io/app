import 'dart:async';
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:sonr_app/data/database/cards_db.dart';
import 'package:sonr_app/pages/overlay/overlay.dart';
import 'package:sonr_app/style/style.dart';
import 'package:sonr_app/data/data.dart';
export 'package:sonr_app/data/database/cards_db.dart';

class CardService extends GetxService {
  // Service Accessors
  static bool get isRegistered => Get.isRegistered<CardService>();
  static CardService get to => Get.find<CardService>();

  // File Objects
  final _activity = RxList<TransferCardActivity>();
  final _all = RxList<TransferCardItem>();
  final _contacts = RxList<TransferCardItem>();
  final _links = RxList<TransferCardItem>();
  final _metadata = RxList<TransferCardItem>();
  final _categoryCount = RxInt(1);

  // File Count
  final _documentCount = 0.obs;
  final _otherCount = 0.obs;
  final _pdfCount = 0.obs;
  final _presentationCount = 0.obs;
  final _photosCount = 0.obs;
  final _spreadsheetCount = 0.obs;
  final _videosCount = 0.obs;

  // Property Accessors
  static RxList<TransferCardActivity> get activity => to._activity;
  static RxList<TransferCardItem> get all => to._all;
  static RxList<TransferCardItem> get contacts => to._contacts;
  static RxList<TransferCardItem> get links => to._links;
  static RxList<TransferCardItem> get metadata => to._metadata;

  // Count Accessors
  static RxInt get documentCount => to._documentCount;
  static RxInt get otherCount => to._otherCount;
  static RxInt get pdfCount => to._pdfCount;
  static RxInt get presentationCount => to._presentationCount;
  static RxInt get photosCount => to._photosCount;
  static RxInt get spreadsheetCount => to._spreadsheetCount;
  static RxInt get videosCount => to._videosCount;

  // Category Specific Count
  static bool get hasActivity => to._activity.length > 0;
  static bool get hasContacts => to._contacts.length > 0;
  static bool get hasMetadata => to._metadata.length > 0;
  static bool get hasLinks => to._links.length > 0;

  // Total Count
  static RxInt get categoryCount => to._categoryCount;

  // References
  final _database = CardsDatabase();

  // * Constructer * //
  Future<CardService> init() async {
    // Bind Streams
    _activity.bindStream(_database.watchActivity());
    _all.bindStream(_database.watchAll());
    _contacts.bindStream(_database.watchContacts());
    _metadata.bindStream(_database.watchMetadata());
    _links.bindStream(_database.watchUrls());

    // Set Initial Counter
    int counter = 1;
    _contacts.length > 0 ? counter += 1 : counter += 0;
    _metadata.length > 0 ? counter += 1 : counter += 0;
    _links.length > 0 ? counter += 1 : counter += 0;
    _categoryCount(counter);
    return this;
  }

  /// @ Add New Card to Database
  static addCard(TransferCard card) async {
    if (card.payload.isTransfer) {
      await DeviceService.saveTransfer(card.file);

      // Store in Database
      await to._database.addFileCard(card);
      _refreshCount();
    } else {
      // Store in Database
      await to._database.addCard(card);
      _refreshCount();
    }
  }

  /// @ Add New Activity for deleted card
  static addActivityDeleted({
    required Payload payload,
    required Profile owner,
    SonrFile? file,
  }) async {
    if (file != null && file.exists) {
      await to._database.addActivity(ActivityType.Deleted, payload, owner, mime: file.single.mime.type);
    } else {
      await to._database.addActivity(ActivityType.Deleted, payload, owner, mime: MIME_Type.OTHER);
    }
  }

  /// @ Add New Activity for received card
  static addActivityReceived({
    required Payload payload,
    required Profile owner,
    SonrFile? file,
  }) async {
    if (file != null && file.exists) {
      await to._database.addActivity(ActivityType.Deleted, payload, owner, mime: file.single.mime.type);
    } else {
      await to._database.addActivity(ActivityType.Deleted, payload, owner, mime: MIME_Type.OTHER);
    }
  }

  /// @ Add New Activity for deleted card
  static addActivityShared({
    required Payload payload,
    SonrFile? file,
  }) async {
    if (file != null && file.exists) {
      await to._database.addActivity(ActivityType.Deleted, payload, UserService.profile.value, mime: file.single.mime.type);
    } else {
      await to._database.addActivity(ActivityType.Deleted, payload, UserService.profile.value, mime: MIME_Type.OTHER);
    }
  }

  /// @ Returns total Card Count
  static Future<int> cardCount({bool withoutContacts = false, bool withoutMedia = false, bool withoutURLs = false}) async {
    // Get Total Entries
    var cards = await to._database.allCardEntries;

    // Filter from Options
    if (withoutContacts) {
      cards.removeWhere((element) => element.payload == Payload.CONTACT);
    }
    if (withoutMedia) {
      cards.removeWhere((element) => element.payload == Payload.FILE);
    }
    if (withoutURLs) {
      cards.removeWhere((element) => element.payload == Payload.URL);
    }

    // Return Remaining
    return cards.length;
  }

  /// @ Clear Single Activity
  static clearActivity(TransferCardActivity activity) async {
    if (hasActivity) {
      await to._database.clearActivity(activity);
    }
  }

  /// @ Clear All Activity
  static clearAllActivity() async {
    if (hasActivity) {
      await to._database.clearAllActivity();
    }
  }

  /// @ Remove Card and Add Deleted Activity to Database
  static deleteCard(TransferCardItem card) async {
    await to._database.deleteCard(card);
    addActivityDeleted(payload: card.payload, owner: card.owner, file: card.file);
    _refreshCount();
  }

  /// @ Remove Card and Add Deleted Activity to Database
  static deleteCardFromID(int id) async {
    await to._database.deleteCardFromID(id);
    // await to._database.addActivity(ActivityType.Deleted, _transferCardFromItem(card));
    _refreshCount();
  }

  /// @ Remove Card and Add Deleted Activity to Database
  static deleteAllCards() async {
    if (to._all.length > 0) {
      await to._database.deleteAllCards();
    }
  }

  /// @ Load IO File from Metadata
  static Future<File> loadFileFromMetadata(SonrFile_Metadata metadata) async {
    var asset = await AssetEntity.fromId(metadata.id);
    if (asset != null) {
      var file = await asset.file;
      if (file != null) {
        return file;
      }
    }
    return metadata.file;
  }

  /// @ Load SonrFile from Metadata
  static Future<SonrFile> loadSonrFileFromMetadata(SonrFile_Metadata metadata) async {
    return SonrFileUtils.newWithItem(metadata);
  }

  /// @ Handles User Invite Response
  static handleInviteResponse(bool decision, AuthInvite invite, {bool sendBackContact = false, bool closeOverlay = false}) {
    if (invite.payload == Payload.CONTACT) {
      to._handleAcceptContact(invite, sendBackContact);
    } else {
      decision ? to._handleAcceptTransfer(invite) : to._handleDeclineTransfer(invite);
    }
  }

  static void reset() {
    to._database.clearAllActivity();
    to._database.deleteAllCards();
  }

  // @ Handle Accept Transfer Response
  _handleAcceptTransfer(AuthInvite invite) {
    // Check for Remote
    if (invite.hasRemote()) {
      SonrService.respond(true, info: invite.remote);
    } else {
      SonrService.respond(true);
    }

    // Switch View
    SonrOverlay.back();
    SonrOverlay.show(
      ProgressView(invite.file, invite.file.single.size > 5000000),
      barrierDismissible: false,
      disableAnimation: true,
    );

    if (invite.file.single.size > 5000000) {
      // Handle Card Received
      SonrService.completed().then((value) {
        SonrOverlay.back();
      });
    } else {
      // Handle Animation Completed
      Future.delayed(1600.milliseconds, () {
        SonrOverlay.back();
      });
    }
  }

// @ Handle Decline Transfer Response
  _handleDeclineTransfer(AuthInvite invite) {
    if (invite.hasRemote()) {
      SonrService.respond(false, info: invite.remote);
    } else {
      SonrService.respond(false);
    }
    SonrOverlay.back();
  }

// @ Handle Accept Contact Response
  _handleAcceptContact(AuthInvite invite, bool sendBackContact) {
    // Save Card
    // _database.addCard(card);

    // Check if Send Back
    if (sendBackContact) {
      // Check for Remote
      if (invite.hasRemote()) {
        SonrService.respond(true, info: invite.remote);
      } else {
        SonrService.respond(true);
      }
    }

    // Return to HomeScreen
    Get.back();

    // Present Home Controller
    if (Get.currentRoute != "/transfer") {
      Get.offNamed('/home/received');
    }
  }

  // @ Helper: Refresh Category Count
  static void _refreshCount() {
    // Set Category Count
    int counter = 1;
    hasContacts ? counter += 1 : counter += 0;
    hasMetadata ? counter += 1 : counter += 0;
    hasLinks ? counter += 1 : counter += 0;
    to._categoryCount(counter);

    // Set Individual File Count
    if (hasMetadata) {
      to._documentCount(to._metadata.count((i) => i.mime == MIME_Type.TEXT));
      to._pdfCount(to._metadata.count((i) => i.mime == MIME_Type.PDF));
      to._presentationCount(to._metadata.count((i) => i.mime == MIME_Type.PRESENTATION));
      to._spreadsheetCount(to._metadata.count((i) => i.mime == MIME_Type.SPREADSHEET));
      to._otherCount(to._metadata.count((i) => i.mime == MIME_Type.OTHER));
      to._photosCount(to._metadata.count((i) => i.mime == MIME_Type.IMAGE));
      to._videosCount(to._metadata.count((i) => i.mime == MIME_Type.VIDEO));
    }
  }
}
