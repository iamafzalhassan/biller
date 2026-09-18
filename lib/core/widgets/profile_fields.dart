import 'package:flutter/widgets.dart';

import '../../models/business_profile.dart';
import '../utils/invoice_number_gen.dart';

class ProfileFields {
  final FocusNode buildingFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode deviceIdFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode noFocus = FocusNode();
  final FocusNode phone1Focus = FocusNode();
  final FocusNode phone2Focus = FocusNode();
  final FocusNode phone3Focus = FocusNode();
  final FocusNode prefixFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();

  final TextEditingController buildingController;
  final TextEditingController cityController;
  final TextEditingController deviceIdController;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController noController;
  final TextEditingController phone1Controller;
  final TextEditingController phone2Controller;
  final TextEditingController phone3Controller;
  final TextEditingController prefixController;
  final TextEditingController streetController;

  ProfileFields(BusinessProfile profile)
    : buildingController = TextEditingController(text: profile.addressBuilding),
      cityController = TextEditingController(text: profile.addressCity),
      deviceIdController = TextEditingController(text: profile.deviceId),
      emailController = TextEditingController(text: profile.ownerEmail),
      nameController = TextEditingController(text: profile.name),
      noController = TextEditingController(text: profile.addressNo),
      phone1Controller = TextEditingController(text: profile.printablePhones.elementAtOrNull(0)),
      phone2Controller = TextEditingController(text: profile.printablePhones.elementAtOrNull(1)),
      phone3Controller = TextEditingController(text: profile.printablePhones.elementAtOrNull(2)),
      prefixController = TextEditingController(text: profile.invoicePrefix),
      streetController = TextEditingController(text: profile.addressStreet);

  List<String> get phones => <String>[for (final TextEditingController controller in phoneControllers) controller.text.trim()].where((String phone) => phone.isNotEmpty).toList();

  List<TextEditingController> get phoneControllers => <TextEditingController>[phone1Controller, phone2Controller, phone3Controller];

  String invoiceNumber(int sequence) => InvoiceNumberGen.build(sequence: sequence, deviceId: deviceIdController.text.trim().toUpperCase(), prefix: prefixController.text.trim().toUpperCase());

  BusinessProfile toProfile({required String logoPath, required List<String> terms}) => BusinessProfile(
    addressBuilding: buildingController.text.trim(),
    addressCity: cityController.text.trim(),
    addressNo: noController.text.trim(),
    addressStreet: streetController.text.trim(),
    deviceId: deviceIdController.text.trim().toUpperCase(),
    invoicePrefix: prefixController.text.trim().toUpperCase(),
    logoPath: logoPath,
    name: nameController.text.trim(),
    ownerEmail: emailController.text.trim(),
    phones: phones,
    terms: terms,
  );

  void dispose() {
    for (final ChangeNotifier notifier in <ChangeNotifier>[
      buildingFocus,
      cityFocus,
      deviceIdFocus,
      emailFocus,
      nameFocus,
      noFocus,
      phone1Focus,
      phone2Focus,
      phone3Focus,
      prefixFocus,
      streetFocus,
      buildingController,
      cityController,
      deviceIdController,
      emailController,
      nameController,
      noController,
      phone1Controller,
      phone2Controller,
      phone3Controller,
      prefixController,
      streetController,
    ]) {
      notifier.dispose();
    }
  }
}
