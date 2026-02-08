import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum AIProxy {

    /// The current sdk version
    nonisolated public static let sdkVersion = "0.145.0"

    /// Configures the AIProxy SDK. Call this during app launch by adding an `init` to your SwiftUI MyApp.swift file, e.g.
    ///
    ///     import AIProxy
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         init() {
    ///             AIProxy.configure(
    ///                 logLevel: .debug,
    ///                 printRequestBodies: true,
    ///                 printResponseBodies: true,
    ///                 resolveDNSOverTLS: true,
    ///                 useStableID: true
    ///             )
    ///         }
    ///         // ...
    ///     }
    ///
    /// Or in your UIKit app's applicationDidFinishLaunching:
    ///
    ///     import AIProxy
    ///
    ///     @UIApplicationMain
    ///     class AppDelegate: UIResponder, UIApplicationDelegate {
    ///
    ///          var window: UIWindow?
    ///
    ///          func application(_ application: UIApplication,
    ///                           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ///              AIProxy.configure(
    ///                  logLevel: .debug,
    ///                  printRequestBodies: true,
    ///                  printResponseBodies: true,
    ///                  resolveDNSOverTLS: true,
    ///                  useStableID: true
    ///              )
    ///              // ...
    ///              return true
    ///          }
    ///          // ...
    ///      }
    ///
    /// - Parameters:
    ///   - logLevel:            Sets the threshold severity of SDK logs that will be shown in the Xcode console.
    ///                          For the most verbose logging, set this to `.debug`
    ///
    ///   - printRequestBodies:  Print API request bodies to the Xcode console.
    ///                          Request bodies are logged at the `.debug` level, so if you would like to use this feature please also set `logLevel` to `.debug`
    ///
    ///   - printResponseBodies: Print API response bodies to the Xcode console.
    ///                          Response bodies are logged at the `.debug` level, so if you would like to use this feature please also set `logLevel` to `.debug`
    ///
    ///   - resolveDNSOverTLS:   Set this to true to perform DNS resolution over TLS using Cloudflare's resolver.
    ///                          The SDK defaults to true for this unless you explicitly set it to false here.
    ///                          It prevents your customer's ISP from snooping on or blocking requests to AIProxy.
    ///
    ///   - useStableID:         Set this to true to perform a best effort attempt to use the same anonymous ID in requests to AIProxy for an app store user across multiple devices.
    ///                          You must add the 'iCloud key-value storage' capability to use this:
    ///                              1. Tap on your project in Xcode's project tree
    ///                              2. Tap on your target in the sidebar
    ///                              3. Tap on Signing & Capabilities in the top nav
    ///                              4. Tap the plus sign next to 'Capability'
    ///                              5. Add iCloud
    ///                              6. Select the 'Key-value storage' service
    ///
    ///                          If possible, StoreKit's appTransactionID will be used as the stable ID.
    ///                          If the app store receipt cannot be verified then we fall back to a GUID synced across iCloud-backed keychain and UKVS.
    nonisolated public static func configure(
        logLevel: AIProxyLogLevel,
        printRequestBodies: Bool,
        printResponseBodies: Bool,
        resolveDNSOverTLS: Bool,
        useStableID: Bool
    ) {
        let previouslyUsingStableID = self.configuration?.useStableID ?? false
        AIProxyLogLevel.callerDesiredLogLevel = logLevel
        self.configuration = AIProxyConfiguration(
            resolveDNSOverTLS: resolveDNSOverTLS,
            printRequestBodies: printRequestBodies,
            printResponseBodies: printResponseBodies,
            useStableID: useStableID
        )
        if useStableID && !previouslyUsingStableID {
            Task { @AIProxyActor in
                if let newStableID = await AIProxyConfiguration.getStableIdentifier() {
                    self.configuration?.stableID = newStableID
                }
            }
        }
    }

    /// This must only be accessed through `ProtectedPropertyQueue.configuration`.
    nonisolated(unsafe) static private var _configuration: AIProxyConfiguration?
    nonisolated static var configuration: AIProxyConfiguration? {
        get {
            ProtectedPropertyQueue.configuration.sync { self._configuration }
        }
        set {
            ProtectedPropertyQueue.configuration.async(flags: .barrier) { self._configuration = newValue }
        }
    }

    /// Flag to use DNS over TLS.
    /// See this Apple Developer forum post for motivation: https://developer.apple.com/forums/thread/780602
    /// Note that this does add some latency to your first request.
    /// In my testing, at least for my location in SF, it added about 50ms.
    /// You can test for yourself with these commands (the first is similar to flipping this flag to true):
    ///
    ///    kdig @1.1.1.1 api.aiproxy.com +tls +noall +stats
    ///
    /// Compare to udp perf using your default resolver:
    ///
    ///    kdig api.aiproxy.com +noall +stats
    ///
    /// Or using cloudflare's resolver
    ///
    ///    kdig @1.1.1.1 api.aiproxy.com +noall +stats
    nonisolated public static var resolveDNSOverTLS: Bool {
        self.configuration?.resolveDNSOverTLS ?? false
    }

    nonisolated public static var stableID: String? {
        self.configuration?.stableID
    }

    nonisolated public static var printRequestBodies: Bool {
        self.configuration?.printRequestBodies ?? false
    }

    nonisolated public static var printResponseBodies: Bool {
        self.configuration?.printResponseBodies ?? false
    }

    /// - Parameters:
    ///   - partialKey: Your partial key is displayed in the AIProxy dashboard when you submit your provider's key.
    ///     AIProxy takes your key, encrypts it, and stores part of the result on our servers. The part that you include
    ///     here is the other part. Both pieces are needed to decrypt your key and fulfill the request to your provider.
    ///
    ///   - serviceURL: The service URL is displayed in the AIProxy dashboard when you submit your provider's key.
    ///
    ///   - clientID: An optional clientID to attribute requests to specific users or devices. It is OK to leave this blank for
    ///     most applications. You would set this if you already have an analytics system, and you'd like to annotate AIProxy
    ///     requests with IDs that are known to other parts of your system.
    ///
    ///     If you do not supply your own clientID, the internals of this lib will generate UUIDs for you. The default UUIDs are
    ///     persistent on macOS and can be accurately used to attribute all requests to the same device. The default UUIDs
    ///     on iOS are pesistent until the end user chooses to rotate their vendor identification number.
    ///
    ///   - proxyPath: The path that you want to forward the request onto. For example, if you are trying to reach
    ///     api.example.com/v1/chat/completions, then you would set the proxyPath to `/v1/chat/completions`
    ///
    ///   - body: An optional request body
    ///
    ///   - verb: The HTTP verb to use for this request. If you leave the default selection of 'automatic', then requests that
    ///     contain a body will default to `POST` while requests with no body will default to `GET`
    ///
    ///   - contentType: The optional content type of the request body.
    ///
    ///   - headers: An optional set of additional headers to include in the request.
    ///
    /// - Returns: A request containing all headers that AIProxy expects. The request is ready to be used with a url session
    ///            that you create with `AIProxy.session()`
    nonisolated public static func request(
        partialKey: String,
        serviceURL: String,
        clientID: String? = nil,
        proxyPath: String,
        body: Data? = nil,
        verb: AIProxyHTTPVerb = .automatic,
        headers: [String: String] = [:]
    ) async throws -> URLRequest {
        return try await AIProxyURLRequest.create(
            partialKey: partialKey,
            serviceURL: serviceURL,
            clientID: clientID,
            proxyPath: proxyPath,
            body: body,
            verb: verb,
            secondsToWait: 60,
            additionalHeaders: headers
        )
    }

    /// Returns a URLSession for communication with AIProxy.
    nonisolated public static func session() -> URLSession {
        return AIProxyURLSession.create()
    }


    /// Service that makes request directly to OpenAI. No protections are built-in for this service.
    /// Please only use this for BYOK use cases.
    ///
    /// - Parameters:
    ///   - unprotectedAPIKey: Your OpenAI API key
    ///   - baseURL: Optional base URL for the API requests
    ///   - requestFormat: If you are sending requests to your own Azure deployment, set this to `.azureDeployment`.
    ///                   Otherwise, you may leave this set to its default value of `.standard`
    /// - Returns: An instance of OpenAIService configured and ready to make requests
    nonisolated public static func openAIDirectService(
        unprotectedAPIKey: String,
        baseURL: String? = nil,
        requestFormat: OpenAIRequestFormat = .standard
    ) -> OpenAIService {
        return OpenAIDirectService(
            unprotectedAPIKey: unprotectedAPIKey,
            requestFormat: requestFormat,
            baseURL: baseURL
        )
    }


    /// Service that makes request directly to Gemini. No protections are built-in for this service.
    /// Please only use this for BYOK use cases.
    ///
    /// - Parameters:
    ///   - unprotectedAPIKey: Your Gemini API key
    /// - Returns: An instance of  GeminiService configured and ready to make requests
    nonisolated public static func geminiDirectService(
        unprotectedAPIKey: String
    ) -> GeminiService {
        return GeminiDirectService(
            unprotectedAPIKey: unprotectedAPIKey
        )
    }



    /// Service that makes request directly to DeepSeek. No protections are built-in for this service.
    /// Please only use this for BYOK use cases.
    ///
    /// - Parameters:
    ///   - unprotectedAPIKey: Your DeepSeek API key
    /// - Returns: An instance of  DeepSeek configured and ready to make requests
    nonisolated public static func deepSeekDirectService(
        unprotectedAPIKey: String,
        baseURL: String? = nil
    ) -> DeepSeekService {
        return DeepSeekDirectService(
            unprotectedAPIKey: unprotectedAPIKey,
            baseURL: baseURL
        )
    }

}
