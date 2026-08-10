//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import flutter_secure_storage_macos
import google_sign_in_ios
import just_audio
import screen_retriever
import shared_preferences_foundation
import sign_in_with_apple
import sqflite_darwin
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FlutterSecureStoragePlugin.register(with: registry.registrar(forPlugin: "FlutterSecureStoragePlugin"))
  FLTGoogleSignInPlugin.register(with: registry.registrar(forPlugin: "FLTGoogleSignInPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SignInWithApplePlugin.register(with: registry.registrar(forPlugin: "SignInWithApplePlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
