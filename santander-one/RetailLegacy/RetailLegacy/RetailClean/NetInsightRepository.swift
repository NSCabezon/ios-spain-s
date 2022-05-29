import Foundation
import CoreFoundationLib

public class NetInsightRepositoryImpl {
    private let netInsightApp = "SantanderNativeApp"
    private let page = "http://www.santander.com/nativas/netInsight/"
    private var fixedParameters: [String: String] = [:]
    private lazy var userAgent: String = {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let deviceHelper = DeviceHelper()
        let model = deviceHelper.model()
        let OS = deviceHelper.systemVersion()
        let language = Locale.preferredLanguages.first ?? ""
        return "\(netInsightApp)/iPhone (\(model); iOS \(OS); \(language); Portrait) (Retail iPhone v\(appVersion))"
    }()
    private let networkService: NetworkService
    private let semaphoreCaller = DispatchSemaphore(value: 1)
    public var baseUrl: String?
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
        fixedParameters["js"] = "1" // Hardcoded
        let deviceHelper = DeviceHelper()
        fixedParameters["rs"] = deviceHelper.screenResolution()
        fixedParameters["inch"] = deviceHelper.screenInches()
        fixedParameters["cd"] = "1" // Color depth
        fixedParameters["rf"] = "" // NADA
        fixedParameters["ln"] = Locale.preferredLanguages.first
        fixedParameters["tz"] = TimeZone.current.localizedName(for: NSTimeZone.NameStyle.shortGeneric, locale: Locale.current)
    }
    
    private func track(screenId: String, eventId: String?, parameters: [String: String], language: String) {
        var copyParameters = fixedParameters.merging(parameters, uniquingKeysWith: { (_, last) in last })
        copyParameters["screen_title"] = screenId
        copyParameters["idioma_app"] = language
        copyParameters["call_type"] = "view"
        var prepareScreenId = screenId
        if screenId.first == "/" {
            prepareScreenId.remove(at: prepareScreenId.startIndex)
        }
        var netinstightTrack = prepareScreenId
        if let eventIdUnwrapped = eventId {
            netinstightTrack += "_" + eventIdUnwrapped
        }
        copyParameters["lc"] = page + netinstightTrack
        copyParameters["ts"] = String(format: "%.f", Date().timeIntervalSince1970)
        request(parameters: copyParameters)
    }
    
    private func request(parameters: [String: String]) {
        guard let baseUrl = baseUrl else { return }
        var convertedParameters: [String: String] = [:]
        for parameter in parameters {
            let key = parameter.key.replace(" ", "_")
            let value = parameter.value.replace(" ", "_")
            convertedParameters[key] = value
        }
        let fields = ["User-Agent": userAgent]
        let requestComponents = OrdinaryRequestComponents(url: baseUrl, params: convertedParameters, method: .get, fields: fields, cookies: [:])
        let request = NetInsightRequest(components: requestComponents)
        _ = try? networkService.executeCall(request: request) 
    }
}

extension NetInsightRepositoryImpl: MetricsRepository {
    public func setUser(personCode: String, personType: String) {
        fixedParameters["ptTipoUser"] = personType
        fixedParameters["ptUser"] = personCode
    }
    
    public func deleteUser() {
        semaphoreCaller.wait()
        fixedParameters["ptTipoUser"] = nil
        fixedParameters["ptUser"] = nil
        semaphoreCaller.signal()
    }
        
    public func trackScreen(screenId: String, extraParameters: [String: String], language: String) {
        track(screenId: screenId, eventId: nil, parameters: extraParameters, language: language)
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String], language: String) {
        track(screenId: screenId, eventId: eventId, parameters: extraParameters, language: language)
    }
}

extension NetInsightRepositoryImpl: NetInsightRepository {
}

class NetInsightRequest: NetworkRequest<Void, NetInsightResponse> {
}

struct NetInsightResponse {
    let data: Data
}

extension NetInsightResponse: NetworkResponse {
    init(response: Data) {
        self.data = response
    }
}
