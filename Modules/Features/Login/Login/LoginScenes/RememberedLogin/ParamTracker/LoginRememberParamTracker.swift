//
//  LoginRememberParamTracker.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/4/20.
//

import Foundation
import CoreFoundationLib

struct LoginRememberParamTracker {
    private let dependenciesResolver: DependenciesResolver
    
    private var deepLinkManager: DeepLinkManagerProtocol {
        return self.dependenciesResolver.resolve(for: DeepLinkManagerProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getDeepLinkParameters() -> [TrackerDimension: String] {
        var parameters = [TrackerDimension: String]()
        if let trackerId = self.deepLinkManager.getScheduledDeepLinkTracker() {
            parameters[TrackerDimension.deeplinkLogin] = trackerId
        }
        return parameters
    }

    func getParameters(user: PersistedUserEntity?, isBiometric: Bool) -> [TrackerDimension: String] {
        var parameters = self.getDeepLinkParameters()
        parameters[TrackerDimension.accessLoginType] = isBiometric ? "touchID" : "clave"
        parameters[TrackerDimension.loginDocumentType] = user?.loginType?.metricsValue
        return parameters
    }
}
