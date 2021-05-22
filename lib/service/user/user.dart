import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sonr_app/data/core/handshake.dart';
import 'package:sonr_app/style/style.dart';
import 'package:sentry/sentry.dart';
import 'package:sonr_app/data/model/model_hs.dart';
import 'package:sonr_app/service/device/device.dart';
import 'package:sonr_plugin/sonr_plugin.dart';

// Username List Constants
const K_RESTRICTED_NAMES = ['elon', 'vitalik', 'prad', 'rishi', 'brax', 'vt', 'isa'];
const K_BLOCKED_NAMES = ['root', 'admin', 'mail', 'auth', 'crypto', 'id', 'app', 'beta', 'alpha', 'code', 'ios', 'android', 'test', 'node', 'sonr'];

class UserService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<UserService>();
  static UserService get to => Get.find<UserService>();

  // Auth Properties
  final _records = RxList<HSRecord>();

  // User Reactive Properties
  final _hasUser = false.obs;
  final _isNewUser = false.obs;
  final _user = User().obs;

  // Contact Reactive Properties
  final _contact = Contact().obs;
  final _profile = Profile().obs;

  // Preferences
  final _isDarkMode = true.val('isDarkMode', getBox: () => GetStorage('Preferences'));
  final _hasFlatMode = true.val('flatModeEnabled', getBox: () => GetStorage('Preferences'));
  final _hasPointToShare = true.val('pointToShareEnabled', getBox: () => GetStorage('Preferences'));

  // Getter Methods for Contact Properties
  static RxBool get hasUser => to._hasUser;
  static RxBool get isNewUser => to._isNewUser;
  static Rx<User> get user => to._user;
  static Rx<Contact> get contact => to._contact;
  static Rx<Profile> get profile => to._profile;

  // Getters for Preferences
  static bool get isDarkMode => to._isDarkMode.val;
  static bool get flatModeEnabled => to._hasFlatMode.val;
  static bool get pointShareEnabled => to._hasPointToShare.val;

  // Auth Checkers
  bool isNameAvailable(String n) => !_records.any((r) => r.equalsName(n));
  bool isNameUnblocked(String n) => !K_BLOCKED_NAMES.any((v) => v == n.toLowerCase());
  bool isNameUnrestricted(String n) => !K_RESTRICTED_NAMES.any((v) => v == n.toLowerCase());
  bool isPrefixAvailable(String n) => !_records.any((r) => r.equalsPrefix(MobileService.newPrefix(n)));
  bool isValidName(String n) => isNameAvailable(n) && isNameUnblocked(n) && isNameUnrestricted(n) && isPrefixAvailable(n);

  // References
  final _nbClient = NamebaseClient();
  final _userBox = GetStorage('User');

  /// @ Open Storage on Init
  Future<UserService> init() async {
    // Get Records
    refreshRecords();

    // Init Storage
    await GetStorage.init('User');
    await GetStorage.init('Preferences');

    // Check User Status
    _hasUser(_userBox.hasData("user"));

    // Check if Exists
    if (_hasUser.value) {
      await _initExisting();
    } else {
      _isNewUser(true);
    }

    // Set Theme
    SonrTheme.setDarkMode(isDark: _isDarkMode.val);
    return this;
  }

  // * Initialize Existing User * //
  Future<void> _initExisting() async {
    if (_hasUser.value) {
      try {
        var profileJson = _userBox.read("user");
        var user = User.fromJson(profileJson);

        // Set Contact Values
        _user(user);
        _contact(user.contact);
        _isNewUser(false);

        // Configure Crypto
        if (DeviceService.isMobile) {
          setCrypto(MobileService.userCrypto);
        }

        // Configure Sentry
        Sentry.configureScope((scope) => scope.user = SentryUser(
              id: DeviceService.device.id,
              username: _contact.value.username,
              extras: {
                "firstName": _contact.value.firstName,
                "lastName": _contact.value.lastName,
              },
            ));
      } catch (e) {
        // Delete User
        _userBox.remove('user');

        // Fetch User Data from Remote
        _hasUser(false);
        _isNewUser(true);

        // Clear Database
        CardService.deleteAllCards();
        CardService.clearAllActivity();
      }
    }
  }

  /// @ Adds User to Record if Provided Name is Allowed
  Future<bool> addUserRecord(String n) async {
    if (DeviceService.isMobile) {
      if (isValidName(n) && MobileService.to.hasAuth) {
        return to._nbClient.addRecord(MobileService.getAuthRecord(n));
      }
    }
    return false;
  }

  /// @ Checks if User is the Same
  bool checkUser(String n) {
    if (DeviceService.isMobile) {
      var prefix = MobileService.newPrefix(n);
      var record = findMatchingRecord(n, prefix);
      if (record != null) {
        return MobileService.verifyFingerprint(record) && record.equals(n, prefix);
      }
    }
    return false;
  }

  /// @ Creates Crypto User Data, Returns Mnemonic Text
  Future<Tuple<String, String>> createUser(String name) async {
    if (DeviceService.isMobile) {
      // Set Crypto and Return Mnemonic
      setCrypto(await MobileService.newCrypto(name));
      await to._userBox.write("username", name);
      return MobileService.mnemonicPrefix;
    }
    return Tuple("", "");
  }

  Future<User?> returningUser(String name) async {
    if (DeviceService.isMobile) {
      var prefix = await MobileService.updatePrefix(name);
      // Fetch User Data
      _user(await SonrService.getUser(id: prefix));

      // Set Valuse
      _isNewUser(false);

      // Set Contact for User
      to._contact(_user.value.contact);
      to._contact.refresh();

      // Save User/Contact to Disk
      var permUser = _user.value;
      await to._userBox.write("user", permUser.writeToJson());
      await to._userBox.write("username", name);
      to._hasUser(true);
      return to._user.value;
    }
    return null;
  }

  /// @ Refreshes Record Table from Namebase Client
  HSRecord? findMatchingRecord(String n, String p) {
    // Add Auth Records from All Records
    var data = _records.singleWhere(
      (r) => r.equals(n, p),
      orElse: () => HSRecord.blank(),
    );

    // Check Data
    if (data.isBlank) {
      return null;
    }
    return data;
  }

  /// @ Method to Create New User from Contact
  static Future<User> saveUser(Contact providedContact, {bool withSonrConnect = false}) async {
    // Set Contact for User
    to._contact(providedContact);
    to._contact.refresh();

    // Set Valuse
    to._isNewUser(true);

    // Connect Sonr Node
    if (withSonrConnect) {
      Get.find<SonrService>().connect();
    }

    // Save User/Contact to Disk
    var permUser = User(contact: to._contact.value);
    await to._userBox.write("user", permUser.writeToJson());
    to._hasUser(true);

    // Save User to Backup Storage
    await SonrService.putUser(user: to._user.value);
    return to._user.value;
  }

  /// @ Refreshes Record Table from Namebase Client
  Future<void> refreshRecords() async {
    // Set Data From Response
    var data = await _nbClient.refresh();
    if (data.item1) {
      _records(data.item2);
      _records.refresh();
    }
  }

  /// @ Sets User Crypto Data
  void setCrypto(User_Crypto data) {
    _user.update((val) {
      if (val != null) {
        val.id = data.prefix;
        val.crypto = data;
      }
    });
  }

  /// @ Trigger iOS Local Network with Alert
  static void toggleDarkMode() async {
    // Update Value
    to._isDarkMode.val = !to._isDarkMode.val;
    SonrTheme.setDarkMode(isDark: to._isDarkMode.val);
  }

  /// @ Trigger iOS Local Network with Alert
  static void toggleFlatMode() async {
    to._hasFlatMode.val = !to._hasFlatMode.val;
  }

  /// @ Trigger iOS Local Network with Alert
  static void togglePointToShare() async {
    to._hasPointToShare.val = !to._hasPointToShare.val;
  }
}
