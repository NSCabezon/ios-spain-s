import Foundation
import TealiumIOS
import AdSupport
import RetailLegacy
import CoreFoundationLib

class TealiumRepositoryImpl {
    private let keyDefaultInstance = "DEFAULT_INSTANCE"
    private let account = "santander"
    private let profile = "mobileapps"
    private let tealiumTarget = Compilation().tealiumTarget
    private var fixedParameters: [String: String] = [:]
    private let semaphoreCreator = DispatchSemaphore(value: 1)
    private let semaphoreCaller = DispatchSemaphore(value: 1)
    private var tealiumInstance: Tealium?
    private var tealium: Tealium {
        semaphoreCreator.wait()
        if let tealiumIOS = tealiumInstance {
            semaphoreCreator.signal()
            return tealiumIOS
        } else {
            let tealiumIOS = configureTealium()
            tealiumInstance = tealiumIOS
            semaphoreCreator.signal()
            return tealiumIOS
        }
    }
    
    init() {
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            fixedParameters["app_version"] = appVersion
            fixedParameters["app_id"] = "Santander Retail iOS v\(appVersion)"
        }
        fixedParameters["app_name"] = "Santander Retail"
        fixedParameters["idioma_app"] = "es_es"
        fixedParameters["canal"] = "MOV"
    }
    
    private func configureTealium() -> Tealium {
        let tealConfig = TEALConfiguration(account: account, profile: profile, environment: tealiumTarget)
        tealConfig.logLevel = TEALLogLevel.prod
        let tealium = Tealium.newInstance(forKey: keyDefaultInstance, configuration: tealConfig)
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else { return tealium }
        tealium.addPersistentDataSources(["idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString])
        return tealium
    }
}

extension TealiumRepositoryImpl: MetricsRepository {
    func setUser(personCode: String, personType: String) {
        fixedParameters["cod_cliente"] = personType + personCode
    }
    
    func deleteUser() {
        fixedParameters["cod_cliente"] = nil
        fixedParameters["segmento_comercial"] = nil
        fixedParameters["segmento_estructural"] = nil
    }
    
    func trackScreen(screenId: String, extraParameters: [String: String], language: String) {
        var parameters = fixedParameters.merging(extraParameters, uniquingKeysWith: { (_, last) in last })
        parameters["idioma_app"] = language
        semaphoreCaller.wait()
        tealium.trackView(withTitle: screenId, dataSources: parameters)
        semaphoreCaller.signal()
    }
    
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String], language: String) {
        var parameters = fixedParameters.merging(extraParameters, uniquingKeysWith: { (_, last) in last })
        parameters["screen_title"] = screenId
        parameters["idioma_app"] = language
        semaphoreCaller.wait()
        tealium.trackEvent(withTitle: eventId, dataSources: parameters)
        semaphoreCaller.signal()
    }
}

extension TealiumRepositoryImpl: TealiumRepository {
    func setSegment(comercial: String?, bdp: String?) {
        fixedParameters["segmento_comercial"] = comercial
        fixedParameters["segmento_estructural"] = bdp
    }
}
