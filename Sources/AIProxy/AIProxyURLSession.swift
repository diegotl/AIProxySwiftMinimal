//
//  AIProxyURLSession.swift
//
//
//  Created by Lou Zell on 8/5/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

nonisolated public enum AIProxyURLSession {
    /// Creates a URLSession that is configured for communication with AI services
    static func create() -> URLSession {
        return URLSession(
            configuration: .ephemeral,
            delegate: nil,
            delegateQueue: nil
        )
    }
}
