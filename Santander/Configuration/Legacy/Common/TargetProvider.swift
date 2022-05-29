//
//  TargetProviderImplementation.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 10/2/21.
//

import Foundation
import SANLibraryV3
import SANLegacyLibrary
import Alamofire
import RetailLegacy
import CoreFoundationLib
import ESCommons

public class TargetProvider: TargetProviderProtocol {
    
    public let alamofireManager: SessionManager
    public let webServicesUrlProvider: WebServicesUrlProvider
    public let bsanDataProvider: BSANDataProvider
    let demoInterpreter: DemoInterpreterProtocol

    public init(webServicesUrlProvider: WebServicesUrlProvider, bsanDataProvider: BSANDataProvider, compilation: CompilationProtocol) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.alamofireManager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: compilation.isTrustInvalidCertificateEnabled ? .development : .production
        )
        
        self.webServicesUrlProvider = webServicesUrlProvider
        self.bsanDataProvider = bsanDataProvider
        self.demoInterpreter = DemoInterpreter(demoProvider: bsanDataProvider, defaultDemoUser: XCConfig["DEFAULT_DEMO_USER"] ?? "")
    }

    public func getDemoInterpreter() -> DemoInterpreterProtocol {
        return demoInterpreter
    }

    public func getSoapCallExecutorProvider() -> SoapServiceExecutor {
        return AlamoExecutor(alamofireManager)
    }
    
    public func getRestCallExecutorProvider() -> RestServiceExecutor {
        return RestAlamoExecutor(alamofireManager, webServicesUrlProvider: webServicesUrlProvider, bsanDataProvider: bsanDataProvider)
    }
    
    public func getRestCallJsonExecutorProvider() -> RestServiceExecutor {
        return RestJSONAlamoExecutor(alamofireManager, webServicesUrlProvider: webServicesUrlProvider, bsanDataProvider: bsanDataProvider)
    }
    
    public func getSoapDemoExecutorProvider() -> SoapServiceExecutor? {
        return SoapDemoExecutor(demoInterpreter: demoInterpreter)
    }
    
    public func getRestDemoExecutorProvider() -> RestServiceExecutor? {
        return RestDemoExecutor(demoInterpreter: demoInterpreter)
    }
}
