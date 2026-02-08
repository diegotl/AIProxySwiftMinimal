//
//  BackgroundNetworker.swift
//
//
//  Created by Lou Zell on 12/23/24.
//

import Foundation

@AIProxyActor enum BackgroundNetworker {
    static func makeRequestAndWaitForData(
        _ urlSession: URLSession,
        _ request: URLRequest
    ) async throws -> (Data, URLResponse) {
        return try await urlSession.data(for: request)
    }

    static func makeRequestAndWaitForAsyncBytes(
        _ urlSession: URLSession,
        _ request: URLRequest
    ) async throws -> (URLSession.AsyncBytes, URLResponse) {
        let (asyncBytes, response) = try await urlSession.bytes(for: request)
        return (asyncBytes, response)
    }
}
