//
//  AccountLandingPushDataBridge.swift
//  Commons
//
//  Created by Francisco del Real Escudero on 1/6/21.
//


public class AccountLandingPushDataBridge {
    public let accountTransactionInfo: AccountTransactionPushProtocol
    public let alertInfo: AlertInfoType
    public let deepLinkManager: DeepLinkManagerProtocol
    public let stringLoader: StringLoader
    public let trackerManager: TrackerManager
    public let dependenciesResolver: DependenciesResolver
    
    public init(accountTransactionInfo: AccountTransactionPushProtocol, alertInfo: AlertInfoType, dependenciesResolver: DependenciesResolver) {
        self.accountTransactionInfo = accountTransactionInfo
        self.alertInfo = alertInfo
        self.dependenciesResolver = dependenciesResolver
        self.deepLinkManager = dependenciesResolver.resolve()
        self.stringLoader = dependenciesResolver.resolve()
        self.trackerManager = dependenciesResolver.resolve()
    }
}
