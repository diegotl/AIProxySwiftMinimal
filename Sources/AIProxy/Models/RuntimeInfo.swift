//
//  RuntimeInfo.swift
//
//
//  Created by Lou Zell on 12/15/24.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Information about the runtime environment
enum RuntimeInfo {

    /// Returns the OS name, e.g., "iOS", "macOS", "watchOS", "visionOS", "Linux"
    static func getOS() -> String {
        #if os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #elseif os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(Linux)
        return "Linux"
        #else
        return "unknown"
        #endif
    }

    /// Returns the OS version, e.g., "17.2"
    static func getOSVersion() -> String {
        #if os(watchOS)
        return WKInterfaceDevice.current().systemVersion
        #elseif os(visionOS)
        // visionOS doesn't have UIDevice or WKInterfaceDevice, use ProcessInfo
        return ProcessInfo.processInfo.operatingSystemVersionString
        #elseif os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS) || os(Linux)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        return "unknown"
        #endif
    }

    /// Returns the model name, e.g., "iPhone16,2"
    static func getModel() -> String {
        #if os(watchOS)
        return WKInterfaceDevice.current().systemVersion
        #elseif targetEnvironment(simulator)
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return "macOS-Simulator"
        #elseif canImport(UIKit)
        return "iOS-Simulator"
        #else
        return "Simulator"
        #endif
        #elseif os(watchOS)
        return WKInterfaceDevice.current().systemVersion
        #elseif os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }
        return machineCode ?? "unknown"
        #elseif os(macOS)
        return "macOS"
        #elseif os(Linux)
        // Try to get system info from /proc/cpuinfo or similar
        #if arch(arm64)
        return "Linux-arm64"
        #elseif arch(x86_64)
        return "Linux-x86_64"
        #else
        return "Linux"
        #endif
        #else
        return "unknown"
        #endif
    }

    /// Returns runtime information as a dictionary
    static func getCurrent() async -> [String: String] {
        #if os(Linux)
        // On Linux, Bundle.main might not have the same structure
        let bundleID = "unknown-linux"
        let appVersion = "unknown"
        #else
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        #endif
        let systemName = getOS()
        let osVersion = getOSVersion()
        let deviceModel = getModel()

        return [
            "bundleID": bundleID,
            "appVersion": appVersion,
            "systemName": systemName,
            "osVersion": osVersion,
            "deviceModel": deviceModel
        ]
    }
}
