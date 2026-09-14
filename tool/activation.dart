import 'dart:io';
import 'dart:typed_data';

import 'package:biller/core/licensing/activation_codec.dart';
import 'package:biller/core/licensing/activation_public_key.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

const String publicKeyPath = 'lib/core/licensing/activation_public_key.dart';

String get privateKeyPath {
  final String home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
  return <String>[home, '.biller', 'activation_private_key'].join(Platform.pathSeparator);
}

void main(List<String> arguments) {
  final String command = arguments.isEmpty ? '' : arguments.first;
  switch (command) {
    case 'keygen':
      _keygen();
    case 'sign' when arguments.length > 1:
      _sign(arguments.skip(1).join());
    default:
      _usage();
  }
}

void _keygen() {
  final File privateKeyFile = File(privateKeyPath);
  final File publicKeyFile = File(publicKeyPath);
  if (privateKeyFile.existsSync()) {
    _fail('A private key already exists at ${privateKeyFile.path}\nReplacing it would lock out every device already activated, so keygen stopped.');
    return;
  }
  if (!publicKeyFile.existsSync()) {
    _fail('Run this from the project root, where $publicKeyPath lives.');
    return;
  }
  final ed.KeyPair pair = ed.generateKey();
  privateKeyFile.parent.createSync(recursive: true);
  privateKeyFile.writeAsStringSync(ActivationCodec.bytesToHex(ed.seed(pair.privateKey)));
  publicKeyFile.writeAsStringSync("abstract final class ActivationPublicKey {\n  static const String hex = '${ActivationCodec.bytesToHex(pair.publicKey.bytes)}';\n}\n");
  stdout.writeln('Private key saved to ${privateKeyFile.path}');
  stdout.writeln('Back this file up somewhere safe. Never commit it or share it.');
  stdout.writeln('Public key written to $publicKeyPath. Rebuild the APK so it carries the new key.');
}

void _sign(String deviceCode) {
  final File privateKeyFile = File(privateKeyPath);
  final String normalizedCode = ActivationCodec.normalizeDeviceCode(deviceCode);
  if (!privateKeyFile.existsSync()) {
    _fail('No private key at ${privateKeyFile.path}. Run keygen first.');
    return;
  }
  if (normalizedCode.isEmpty) {
    _fail('That device code is empty. Copy it exactly as the app shows it.');
    return;
  }
  final ed.PrivateKey privateKey = ed.newKeyFromSeed(ActivationCodec.hexToBytes(privateKeyFile.readAsStringSync()));
  final Uint8List signature = ed.sign(privateKey, ActivationCodec.message(normalizedCode));
  if (ActivationCodec.bytesToHex(ed.public(privateKey).bytes) != ActivationPublicKey.hex.toUpperCase()) {
    stderr.writeln('Warning: $publicKeyPath does not match your private key. Keys from this run only work in an APK built with the matching public key.');
  }
  stdout.writeln('Device code: ${ActivationCodec.formatDeviceCode(normalizedCode)}');
  stdout.writeln('Activation key:');
  stdout.writeln(ActivationCodec.encodeKey(signature));
}

void _usage() {
  stdout.writeln('dart run tool/activation.dart keygen');
  stdout.writeln('dart run tool/activation.dart sign <DEVICE-CODE>');
  exitCode = 64;
}

void _fail(String message) {
  stderr.writeln(message);
  exitCode = 1;
}
