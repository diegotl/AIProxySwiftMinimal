# AIProxySwiftMinimal

> **⚠️ This is a minimal, customized fork of [AIProxySwift](https://github.com/lzell/AIProxySwift)**

This package contains only the essential components needed for projects requiring simple AI chat completions, stripped down to maximize performance and minimize code footprint.

## What's Included

This minimal version includes support for only **3 AI providers**:

- **OpenAI** - Chat completions (non-streaming)
- **Google Gemini** - Content generation (non-streaming)
- **DeepSeek** - Chat completions (non-streaming)

## What's Removed

Compared to the original AIProxySwift package, this version removes:

- ❌ All other AI providers (Anthropic, Stability AI, Perplexity, Mistral, etc.)
- ❌ Streaming response support
- ❌ Image generation APIs
- ❌ Audio/speech APIs
- ❌ Embedding APIs
- ❌ File upload APIs
- ❌ Batch processing APIs
- ❌ Function calling and tool use
- ❌ Conversations API
- ❌ All proxy service infrastructure (direct services only)
- ❌ All test files
- ❌ Device attestation and certificate pinning

## Package Size

- **Original:** ~200+ Swift files
- **This minimal version:** 41 Swift files
- **Reduction:** ~80% smaller

## Usage Example

```swift
import AIProxy

// OpenAI - Direct service
let openaiService = AIProxy.openAIDirectService(
    unprotectedAPIKey: "your-api-key"
)

let requestBody = OpenAIChatCompletionRequestBody(
    model: "gpt-4",
    messages: [
        .init(role: .system, content: "You are a helpful assistant"),
        .init(role: .user, content: "Hello!")
    ]
)

let response = try await openaiService.chatCompletionRequest(
    body: requestBody,
    secondsToWait: 60
)

// Gemini - Direct service
let geminiService = AIProxy.geminiDirectService(
    unprotectedAPIKey: "your-api-key"
)

let geminiRequestBody = GeminiGenerateContentRequestBody(
    contents: [
        .init(parts: [.text("Hello!")], role: "user")
    ]
)

let geminiResponse = try await geminiService.generateContentRequest(
    body: geminiRequestBody,
    model: "gemini-1.5-flash",
    secondsToWait: 60
)

// DeepSeek - Direct service
let deepseekService = AIProxy.deepSeekDirectService(
    unprotectedAPIKey: "your-api-key"
)

let deepseekRequestBody = DeepSeekChatCompletionRequestBody(
    model: "deepseek-chat",
    messages: [
        .init(role: .system, content: "You are a helpful assistant"),
        .init(role: .user, content: "Hello!")
    ]
)

let deepseekResponse = try await deepseekService.chatCompletionRequest(
    body: deepseekRequestBody,
    secondsToWait: 60
)
```

## Platform Support

- iOS 15.0+
- macOS 13.0+
- watchOS 9.0+
- visionOS 1.0+

## Installation

Add this package to your `Package.swift`:

```swift
.dependencies: [
    .package(path: "../AIProxySwiftMinimal"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["AIProxy"]
    ),
]
```

Or use a local path:

```swift
.package(url: "https://github.com/yourusername/AIProxySwiftMinimal", from: "1.0.0")
```

## Customization

This minimal fork was created to provide only the essential AI completion functionality. If you need:

- Streaming responses
- Image generation
- Audio/speech features
- More AI providers
- Proxy service features
- Advanced tool calling

Please use the [original AIProxySwift](https://github.com/lzell/AIProxySwift) package instead.

## License

This package maintains the same license as the original AIProxySwift project.

## Acknowledgments

This is a minimized fork of the excellent [AIProxySwift](https://github.com/lzell/AIProxySwift) library by Lou Zell. All credit for the original implementation goes to the original author.

For the full-featured version with support for many more providers and features, please visit:
- https://github.com/lzell/AIProxySwift
