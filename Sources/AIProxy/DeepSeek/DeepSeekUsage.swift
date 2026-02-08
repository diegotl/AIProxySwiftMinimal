//
//  DeepSeekUsage.swift
//  AIProxy
//
//  Created by Lou Zell on 1/27/25.
//

import Foundation

/// Usage statistics for a chat completion request
///
/// https://api-docs.deepseek.com/api/create-chat-completion#responses
nonisolated public struct DeepSeekUsage: Decodable, Sendable {
    /// Number of tokens in the prompt
    public let promptTokens: Int

    /// Number of tokens in the completion
    public let completionTokens: Int

    /// Total number of tokens (prompt + completion)
    public let totalTokens: Int

    /// Reasoning tokens used (if applicable)
    public let promptCacheHitTokens: Int?
    public let promptCacheMissTokens: Int?

    private enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptCacheHitTokens = "prompt_cache_hit_tokens"
        case promptCacheMissTokens = "prompt_cache_miss_tokens"
    }

    public init(
        promptTokens: Int,
        completionTokens: Int,
        totalTokens: Int,
        promptCacheHitTokens: Int? = nil,
        promptCacheMissTokens: Int? = nil
    ) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
        self.promptCacheHitTokens = promptCacheHitTokens
        self.promptCacheMissTokens = promptCacheMissTokens
    }
}
