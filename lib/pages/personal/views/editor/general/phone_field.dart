import 'package:sonr_app/pages/personal/controllers/personal_controller.dart';
import 'package:sonr_app/style.dart';

/// @ Edit Profile Details View
class EditPhoneView extends GetView<PersonalController> {
  EditPhoneView({Key? key}) : super(key: key);
  final FocusNode _primaryNumberFocus = FocusNode();
  final scrollController = ScrollController();
  final hintName = SonrTextField.hintName();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Height.ratio(0.4),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(children: [
          SonrTextField(
              hint: "+1-555-555-5555",
              label: "Primary",
              textInputAction: TextInputAction.done,
              controller: TextEditingController(text: UserService.contact.value.hasPhone() ? UserService.contact.value.phonePrimary : ""),
              value: controller.editedLastName.value,
              focusNode: _primaryNumberFocus,
              onEditingComplete: () {
                controller.saveEditedDetails();
                _primaryNumberFocus.unfocus();
              },
              onChanged: (val) => controller.editedPhone(val))
        ]),
      ),
    );
  }
}