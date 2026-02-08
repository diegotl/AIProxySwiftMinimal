//
//  AIProxyConfiguration.swift
//  AIProxy
//
//  Created by Lou Zell on 7/31/25.
//

nonisolated struct AIProxyConfiguration {

    let resolveDNSOverTLS: Bool
    let printRequestBodies: Bool
    let printResponseBodies: Bool
    let useStableID: Bool
    var stableID: String?

    @AIProxyActor static internal func getStableIdentifier() async -> String? {
        #if !DEBUG
        if let appTransactionID = await AIProxyUtils.getAppTransactionID() {
            return appTransactionID
        }
        #endif
        return nil
    }
}
