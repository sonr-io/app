import 'package:sonr_app/modules/payload/content/item_thumbnail.dart';
import 'package:sonr_app/style.dart';
import 'package:sonr_app/pages/transfer/transfer.dart';

class PayloadItemInfo extends StatelessWidget {
  final SonrFile_Item item;
  const PayloadItemInfo({Key? key, required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: item.prettyName().subheading(color: SonrTheme.itemColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: item.prettySize().light(color: SonrTheme.itemColor),
          )
        ],
      ),
    );
  }
}

class PayloadListItemHeader extends GetView<ItemController> {
  @override
  Widget build(BuildContext context) {
    final file = TransferController.invite.file;
    return Container(
      decoration: BoxDecoration(color: SonrTheme.foregroundColor, borderRadius: BorderRadius.circular(37)),
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: file.prettyName().subheading(color: SonrTheme.itemColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: file.prettySize().light(color: SonrTheme.itemColor),
          )
        ],
      ),
    );
  }
}

class PayloadListItem extends GetView<ItemController> {
  final GlobalKey key;
  final bool isSingle;
  final SonrFile_Item? fileItem;
  final int? index;
  const PayloadListItem({required this.key, required this.isSingle, this.fileItem, this.index});

  /// Builds Payload List Item for Single Entry
  factory PayloadListItem.single({required GlobalKey key}) {
    return PayloadListItem(key: key, isSingle: true);
  }

  factory PayloadListItem.multi({required GlobalKey key, required SonrFile_Item item, required int index}) {
    return PayloadListItem(
      isSingle: false,
      key: key,
      fileItem: item,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: [
      PayloadThumbnail(
        item: isSingle ? null : fileItem!,
      ),
      _buildTitle(),
      Container(
        alignment: Alignment.topRight,
        child: InfoButton(
          onPressed: () {
            AppRoute.positioned(
              Infolist(options: [
                InfolistOption("Replace", SonrIcons.Reload, controller.replace),
                InfolistOption("Remove", SonrIcons.Trash, controller.delete),
                InfolistOption("Cancel", SonrIcons.Cancel, controller.cancel),
              ]),
              offset: Offset(35, 0),
              parentKey: key,
            );
          },
        ),
      ),
    ]));
  }

  Widget _buildTitle() {
    if (isSingle) {
      return _PayloadListItemTitle.single(TransferController.invite);
    } else {
      return _PayloadListItemTitle.multi(fileItem!);
    }
  }
}

class _PayloadListItemTitle extends StatelessWidget {
  final InviteRequest? invite;
  final SonrFile_Item? item;
  final bool isSingle;

  factory _PayloadListItemTitle.single(InviteRequest invite) => _PayloadListItemTitle(isSingle: true, invite: invite);

  factory _PayloadListItemTitle.multi(SonrFile_Item item) => _PayloadListItemTitle(isSingle: false, item: item);

  const _PayloadListItemTitle({Key? key, this.invite, this.item, required this.isSingle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (isSingle) {
      return _buildSingleTitle();
    } else {
      return _buildMultiTitle();
    }
  }

  Widget _buildSingleTitle() {
    if (invite!.payload == Payload.CONTACT) {
      // Build Text View
      return Container(
          width: Width.ratio(0.5),
          height: Height.ratio(0.15),
          padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: [
                ContactService.contact.value.firstName.paragraph(color: SonrTheme.itemColor),
                " ".paragraph(color: SonrTheme.itemColor),
                ContactService.contact.value.lastName.light(color: SonrTheme.itemColor)
              ].row(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: "Contact Card".paragraph(),
            )
          ]));
    } else if (invite!.payload == Payload.URL) {
      // Build Text View
      return Container(
          width: Width.ratio(0.5),
          height: Height.ratio(0.15),
          padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: invite!.file.prettyName().paragraph(color: SonrTheme.itemColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: invite!.file.prettySize().paragraph(color: Get.theme.hintColor),
            )
          ]));
    } else {
      // Build Text View
      return Container(
          width: Width.ratio(0.5),
          height: Height.ratio(0.15),
          padding: EdgeInsets.only(left: 16, right: 8, top: 0, bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 16.0), child: invite!.file.prettyType().subheading(color: SonrTheme.itemColor)),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: invite!.file.prettyName().light(color: Get.theme.hintColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: invite!.file.prettySize().paragraph(color: Get.theme.hintColor),
            )
          ]));
    }
  }

  Widget _buildMultiTitle() {
    return Container(
        width: Width.ratio(0.5),
        height: Height.ratio(0.15),
        padding: EdgeInsets.only(left: 16, right: 8, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: item!.prettyType().subheading(color: SonrTheme.itemColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: item!.prettyName().paragraph(color: Get.theme.hintColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: item!.prettySize().paragraph(color: Get.theme.hintColor),
          )
        ]));
  }
}
