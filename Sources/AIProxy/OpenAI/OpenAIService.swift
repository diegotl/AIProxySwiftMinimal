//
//  OpenAIService.swift
//
//
//  Created by Lou Zell on 12/14/24.
//

import Foundation

@AIProxyActor public class OpenAIService: Sendable {
    private let requestFormat: OpenAIRequestFormat
    private let requestBuilder: AIProxyRequestBuilder
    private let serviceNetworker: ServiceMixin

    /// This designated initializer is not public on purpose.
    /// Customers are expected to use the factory `AIProxy.openAIService` or `AIProxy.openAIDirectService` defined in AIProxy.swift.
    nonisolated init(
        requestFormat: OpenAIRequestFormat,
        requestBuilder: AIProxyRequestBuilder,
        serviceNetworker: ServiceMixin
    ) {
        self.requestFormat = requestFormat
        self.requestBuilder = requestBuilder
        self.serviceNetworker = serviceNetworker
    }

    /// Initiates a non-streaming chat completion request to /v1/chat/completions.
    ///
    /// - Parameters:
    ///   - body: The request body to send to openai. See this reference:
    ///           https://platform.openai.com/docs/api-reference/chat/create
    ///   - secondsToWait: The amount of time to wait before `URLError.timedOut` is raised
    ///   - additionalHeaders: Optional headers to pass up with the request alongside the lib's default headers
    /// - Returns: A ChatCompletionResponse. See this reference:
    ///            https://platform.openai.com/docs/api-reference/chat/object
    public func chatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt,
        additionalHeaders: [String: String] = [:]
    ) async throws -> OpenAIChatCompletionResponseBody {
        var body = body
        body.stream = false
        body.streamOptions = nil
        let request = try await self.requestBuilder.jsonPOST(
            path: self.resolvedPath("chat/completions"),
            body: body,
            secondsToWait: secondsToWait,
            additionalHeaders: additionalHeaders
        )
        return try await self.serviceNetworker.makeRequestAndDeserializeResponse(request)
    }

    /// Resolves the path based on the request format (standard, azure deployment, or no version prefix)
    private func resolvedPath(_ path: String) -> String {
        switch requestFormat {
        case .standard:
            "/v1/\(path)"
        case .azureDeployment:
            path
        case .noVersionPrefix:
            "/\(path)"
        }
    }
}
