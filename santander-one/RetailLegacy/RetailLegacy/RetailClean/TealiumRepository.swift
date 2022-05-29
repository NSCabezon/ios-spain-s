import Foundation
import TealiumIOS
import AdSupport
import CoreFoundationLib

public class TealiumRepositoryImpl {
    private let keyDefaultInstance = "DEFAULT_INSTANCE"
    private let account = "santander"
    private let tealiumTarget: String
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
    
    private let compilation: CompilationProtocol
    private let tealiumCompilation: TealiumCompilationProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.tealiumCompilation = dependenciesResolver.resolve(for: TealiumCompilationProtocol.self)
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            fixedParameters["app_version"] = appVersion
            fixedParameters["app_id"] = "\(self.tealiumCompilation.appName) iOS v\(appVersion)"
        }
        fixedParameters["app_name"] = self.tealiumCompilation.appName
        fixedParameters["idioma_app"] = "es_es"
        fixedParameters["canal"] = "MOV"
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
        self.tealiumTarget = compilation.tealiumTarget
    }
    
    private func configureTealium() -> Tealium {
        let profile = self.tealiumCompilation.profile
        let tealConfig = TEALConfiguration(account: account, profile: profile, environment: tealiumTarget)
        tealConfig.logLevel = TEALLogLevel.prod
        let tealium = Tealium.newInstance(forKey: keyDefaultInstance, configuration: tealConfig)
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else { return tealium }
        tealium.addPersistentDataSources(["idfa": ASIdentifierManager.shared().advertisingIdentifier.uuidString])
        return tealium
    }
}

extension TealiumRepositoryImpl: MetricsRepository {
    public func setUser(personCode: String, personType: String) {
        let clientKey = self.tealiumCompilation.clientKey
        let clientIdUpperCased = self.tealiumCompilation.clientIdUpperCased
        let clientId = personType + personCode
        fixedParameters[clientKey] = clientIdUpperCased ? clientId.uppercased() : clientId
    }
    
    public func deleteUser() {
        semaphoreCaller.wait()
        let clientKey = self.tealiumCompilation.clientKey
        fixedParameters[clientKey] = nil
        fixedParameters["segmento_comercial"] = nil
        fixedParameters["segmento_estructural"] = nil
        semaphoreCaller.signal()
    }
    
    public func trackScreen(screenId: String, extraParameters: [String: String], language: String) {
        var parameters = fixedParameters.merging(extraParameters, uniquingKeysWith: { (_, last) in last })
        parameters["idioma_app"] = language
        semaphoreCaller.wait()
        tealium.trackView(withTitle: screenId, dataSources: parameters)
        semaphoreCaller.signal()
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String], language: String) {
        var parameters = fixedParameters.merging(extraParameters, uniquingKeysWith: { (_, last) in last })
        parameters["screen_title"] = screenId
        parameters["idioma_app"] = language
        semaphoreCaller.wait()
        tealium.trackEvent(withTitle: eventId, dataSources: parameters)
        semaphoreCaller.signal()
    }
}

extension TealiumRepositoryImpl: TealiumRepository {
    public func setSegment(comercial: String?, bdp: String?) {
        fixedParameters["segmento_comercial"] = comercial
        fixedParameters["segmento_estructural"] = bdp
    }
}
