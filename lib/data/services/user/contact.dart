import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sonr_app/style.dart';
import 'package:sonr_app/data/services/services.dart';

class ContactService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<ContactService>();
  static ContactService get to => Get.find<ContactService>();

  /// ** User Status Properties **
  final _hasUser = false.obs;
  final _isNewUser = false.obs;

  /// ** User Reactive Properties **
  final _contact = Contact().obs;

  //
  static RxBool get hasUser => to._hasUser;
  static RxBool get isNewUser => to._isNewUser;
  static Rx<Contact> get contact => to._contact;

  // Getters for Preferences
  static String get sName => to._hasUser.value ? to._contact.value.sName : "";

  /// ** References **
  final _userBox = GetStorage('User');

  /// @ Open SharedPreferences on Init
  Future<ContactService> init() async {
    // @ Init Shared Preferences
    await GetStorage.init('User');

    // Check User Status
    _hasUser(_userBox.hasData("contact"));

    // Check if Exists
    if (_hasUser.value) {
      try {
        // Get ContactJSOn
        var profileJson = _userBox.read("contact");
        var contact = Contact.fromJson(profileJson);

        // Set User Properties
        Logger.initProfile(contact.profile);

        // Set Contact Values
        _contact(contact);
        _isNewUser(false);

        Logger.info("Returning User");
      } catch (e) {
        // Delete User
        _userBox.remove('contact');
        _hasUser(false);
        _isNewUser(true);

        Logger.warn("RESET: Contact and User");
      }
    } else {
      _isNewUser(true);
      Logger.info("New User!");
    }

    // Handle Contact Updates
    _contact.listen(_handleContact);

    return this;
  }

  /// @ Method to Create New User from Contact
  static Future<void> newContact(Contact newContact) async {
    // Set Valuse
    to._isNewUser(true);

    // Set Contact for User
    to._contact(newContact);
    to._contact.refresh();

    // Save User/Contact to Disk
    await to._userBox.write("contact", newContact.writeToJson());
    to._hasUser(true);
  }

  /// @ Method Collects user Feedback and Sends Email
  static void sendFeedback(String message, Uint8List? screenshot) async {
    var screenshotPath = "";
    bool hasScreenshot = false;

    // Save Image
    if (screenshot != null) {
      final Directory output = await getTemporaryDirectory();
      final String screenshotFilePath = '${output.path}/feedback.png';
      final File screenshotFile = File(screenshotFilePath);
      await screenshotFile.writeAsBytes(screenshot);
      screenshotPath = screenshotFilePath;
      hasScreenshot = true;
    }

    // Check if Has Screenshot
    if (hasScreenshot) {
      // Create Instance
      Reference ref = FirebaseStorage.instance.ref().child('screenshots').child(screenshotPath);

      // Set Metadata
      final feedback = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'path': screenshotPath},
      );

      // Upload to Firebase
      UploadTask uploadTask = ref.putFile(File(screenshotPath), feedback);
      await uploadTask.whenComplete(() => to._handleUploadScreenshot(ref, message));
    } else {
      // Post Only Message
      to._handlePostFeedback(message);
    }
  }


  // # Helper Method to Handle Contact Updates
  void _handleContact(Contact data) async {
    // Save Updated User to Disk
    await to._userBox.write("contact", data.writeToJson());

    // Send Update to Node
    if (NodeService.status.value.isConnected) {
      NodeService.setProfile(data);
    }
  }

  /// @ Helper: Uploads User Screenshot
  FutureOr<dynamic> _handleUploadScreenshot(Reference ref, String message) async {
    // Fetch Link
    String link = await ref.getDownloadURL();
    await _handlePostFeedback(message, link: link);
  }

  /// @ Helper: Posts User Feedback
  Future<void> _handlePostFeedback(String message, {String? link}) async {
    // Update Firestore
    DocumentReference docRef = FirebaseFirestore.instance.collection("feedback").doc();

    // Check for Link
    if (link != null) {
      docRef.update({
        "firstname": ContactService.contact.value.profile.firstName,
        "lastname": ContactService.contact.value.profile.lastName,
        "message": message,
        "screenshot": link,
        "hasScreenshot": true,
      });
    } else {
      docRef.update({
        "firstname": ContactService.contact.value.profile.firstName,
        "lastname": ContactService.contact.value.profile.lastName,
        "message": message,
        "hasScreenshot": false,
      });
    }

    // Log Feedback Event
  }
}
