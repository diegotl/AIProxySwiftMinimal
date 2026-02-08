//
//  AIProxyUtils.swift
//
//
//  Created by Lou Zell on 7/9/24.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(Network)
import Network
#endif

enum AIProxyUtils {

    nonisolated static func directURLSession() -> URLSession {
        return URLSession(
            configuration: .ephemeral,
            delegate: DirectURLSessionDataDelegate(),
            delegateQueue: nil
        )
    }

    nonisolated static func proxiedURLSession() -> URLSession {
        #if canImport(Network)
        if AIProxy.resolveDNSOverTLS {
            let host = NWEndpoint.hostPort(host: "one.one.one.one", port: 853)
            let endpoints: [NWEndpoint] = [
                .hostPort(host: "1.1.1.1", port: 853),
                .hostPort(host: "1.0.0.1", port: 853),
                .hostPort(host: "2606:4700:4700::1111", port: 853),
                .hostPort(host: "2606:4700:4700::1001", port: 853)
            ]
            NWParameters.PrivacyContext.default.requireEncryptedNameResolution(
                true,
                fallbackResolver: .tls(host, serverAddresses: endpoints)
            )
        }
        #endif
        return AIProxyURLSession.create()
    }

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    nonisolated static func encodeImageAsJpeg(
        _ image: NSImage,
        _ compressionQuality: CGFloat
    ) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }

    nonisolated static func encodeImageAsURL(
        _ image: NSImage,
        _ compressionQuality: CGFloat
    ) -> URL? {
        guard let jpegData = self.encodeImageAsJpeg(image, compressionQuality) else {
            return nil
        }
        return URL(string: "data:image/jpeg;base64,\(jpegData.base64EncodedString())")
    }
#elseif canImport(UIKit)
    nonisolated static func encodeImageAsJpeg(
        _ image: UIImage,
        _ compressionQuality: CGFloat
    ) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }

    nonisolated static func encodeImageAsURL(
        _ image: UIImage,
        _ compressionQuality: CGFloat
    ) -> URL? {
        guard let jpegData = self.encodeImageAsJpeg(image, compressionQuality) else {
            return nil
        }
        return URL(string: "data:image/jpeg;base64,\(jpegData.base64EncodedString())")
    }
#endif

    nonisolated static func metadataHeader(withBodySize bodySize: Int?) async -> String {
        let ri = await RuntimeInfo.getCurrent()
        let fields: [String] = [
            "v4",
            ri["bundleID"] ?? "unknown",
            ri["appVersion"] ?? "unknown",
            AIProxy.sdkVersion,
            String(Date().timeIntervalSince1970),
            ri["systemName"] ?? "unknown",
            ri["osVersion"] ?? "unknown",
            ri["deviceModel"] ?? "unknown",
            String(bodySize ?? 0)
        ]
        return fields.joined(separator: "|")
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension NSImage {
    nonisolated func jpegData(compressionQuality: CGFloat = 1.0) -> Data? {
        guard let tiffData = self.tiffRepresentation else {
            return nil
        }
        guard let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        let jpegData = bitmapImage.representation(
            using: .jpeg,
            properties: [.compressionFactor: compressionQuality]
        )
        return jpegData
    }
}
#endif
