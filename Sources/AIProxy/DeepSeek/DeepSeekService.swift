//
//  DeepSeekService.swift
//  AIProxy
//
//  Created by Lou Zell on 1/27/25.
//

import Foundation

@AIProxyActor public protocol DeepSeekService: Sendable {

    /// Initiates a non-streaming chat completion request to /chat/completions.
    ///
    /// - Parameters:
    ///   - body: The request body to send to DeepSeek. See this reference:
    ///           https://api-docs.deepseek.com/api/create-chat-completion
    ///   - secondsToWait: The amount of time to wait before `URLError.timedOut` is raised
    /// - Returns: The chat response. See this reference:
    ///            https://api-docs.deepseek.com/api/create-chat-completion#responses
    func chatCompletionRequest(
        body: DeepSeekChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> DeepSeekChatCompletionResponseBody
}

extension DeepSeekService {
    public func chatCompletionRequest(
        body: DeepSeekChatCompletionRequestBody
    ) async throws -> DeepSeekChatCompletionResponseBody {
        return try await self.chatCompletionRequest(body: body, secondsToWait: 60)
    }
}
