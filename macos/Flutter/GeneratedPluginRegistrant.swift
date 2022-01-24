//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audioplayers
import path_provider_macos
import platform_device_id
import platform_device_id_macos
import shared_preferences_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioplayersPlugin.register(with: registry.registrar(forPlugin: "AudioplayersPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  PlatformDeviceIdPlugin.register(with: registry.registrar(forPlugin: "PlatformDeviceIdPlugin"))
  PlatformDeviceIdMacosPlugin.register(with: registry.registrar(forPlugin: "PlatformDeviceIdMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
