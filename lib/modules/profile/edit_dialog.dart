import 'package:sonr_app/data/constants.dart';
import 'package:sonr_app/theme/theme.dart';

// ** Edit Sheet View for Profile ** //
enum EditType { ColorCombo, NameField }

class EditDialog extends GetView<EditDialogController> {
  final String headerText;
  final EditType type;

  EditDialog(this.type, {this.headerText});

  factory EditDialog.colorComboPicker({@required String text, @required Function(dynamic) onChanged}) {
    return EditDialog(
      EditType.ColorCombo,
    );
  }

  factory EditDialog.nameField({@required String firstValue, @required String lastValue}) {
    return EditDialog(
      EditType.NameField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.only(bottom: 260),
        child: NeumorphicBackground(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            borderRadius: BorderRadius.circular(30),
            backendColor: Colors.transparent,
            child: Neumorphic(
                style: NeumorphicStyle(color: SonrColor.base),
                child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      // @ Top Banner
                      SonrHeaderBar.twoButton(
                          title: SonrText.header("Edit", size: 34),
                          leading: SonrButton.circle(
                              icon: SonrIcon.close,
                              onPressed: () {
                                SonrOverlay.back();
                              }),
                          action: SonrButton.circle(icon: SonrIcon.accept, onPressed: controller.complete)),

                      // @ Window Content

                      _buildView(context),
                    ])))),
      ),
    );
  }

  // ^ Build View by EditType ^ //
  Widget _buildView(BuildContext context) {
    switch (type) {
      case EditType.ColorCombo:
        return Container();
        break;
      case EditType.NameField:
        final lastNameFocus = FocusNode();
        final phoneFocus = FocusNode();
        final scroller = ScrollController();
        var hintName = SonrText.hintName();
        return Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              controller: scroller,
              child: Column(children: [
                SonrTextField(
                    hint: hintName.item1,
                    label: "First Name",
                    autoFocus: true,
                    textInputAction: TextInputAction.next,
                    controller: TextEditingController(text: UserService.firstName.value),
                    value: controller.editFirstName.value,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(lastNameFocus);
                    },
                    onChanged: (val) => controller.editFirstName(val)),
                SonrTextField(
                    hint: hintName.item2,
                    label: "Last Name",
                    focusNode: lastNameFocus,
                    textInputAction: TextInputAction.next,
                    controller: TextEditingController(text: UserService.lastName.value),
                    value: controller.editLastName.value,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(phoneFocus);
                    },
                    onChanged: (val) => controller.editLastName(val)),
                SonrTextField(
                    hint: "+1-555-555-5555",
                    label: "Phone",
                    focusNode: phoneFocus,
                    textInputAction: TextInputAction.done,
                    controller: TextEditingController(text: UserService.phone.value),
                    value: controller.editLastName.value,
                    onEditingComplete: () {
                      FocusScopeNode currentFocus = FocusScope.of(Get.context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus.unfocus();
                      }
                    },
                    onChanged: (val) => controller.editPhone(val)),
                Padding(padding: EdgeInsets.all(8))
              ]),
            ));
        break;
    }
    return Container();
  }
}

class EditDialogController extends GetxController {
  // Properties
  final editFirstName = "".obs;
  final editLastName = "".obs;
  final editPhone = "".obs;

  // ^ Initialize the Controller ^ //
  void onInit() async {
    // Get Initial Values
    var firstInitial = UserService.firstName.value;
    var lastInitial = UserService.lastName.value;
    var phoneInitial = UserService.phone.value;

    // Set Values
    editFirstName(firstInitial);
    editLastName(lastInitial);
    editPhone(phoneInitial);
    super.onInit();
  }

  // ^ Completed Editing ^ //
  void complete() {
    // Update Values in Profile Controller
    UserService.setFirstName(editFirstName.value);
    UserService.setLastName(editLastName.value);
    UserService.setPhone(editPhone.value);
    UserService.saveChanges();

    // Close View
    SonrOverlay.back();
  }
}
