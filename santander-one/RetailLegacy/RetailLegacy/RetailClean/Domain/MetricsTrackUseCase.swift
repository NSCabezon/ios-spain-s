import CoreFoundationLib

public enum MetricsTrackType {
    case screen
    case event(eventId: String)
}

public class MetricsTrackUseCase: UseCase<MetricsTrackUseCaseInput, Void, StringErrorOutput> {
    private let localAppConfig: LocalAppConfig
    private let tealiumRepository: TealiumRepository
    private let netInsightRepository: NetInsightRepository
    private let languageRepository: LanguageRepository

    public init(localAppConfig: LocalAppConfig,
        tealiumRepository: TealiumRepository,
        netInsightRepository: NetInsightRepository,
        languageRepository: LanguageRepository) {
        self.localAppConfig = localAppConfig
        self.tealiumRepository = tealiumRepository
        self.netInsightRepository = netInsightRepository
        self.languageRepository = languageRepository
    }
    
    public override func executeUseCase(requestValues: MetricsTrackUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let languageType: LanguageType
        if let response = try languageRepository.getLanguage().getResponseData(), let type = response {
            languageType = type
        } else {
            let defaultLanguage = self.localAppConfig.language
            let languageList = self.localAppConfig.languageList
            languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        let languageCode = languageType.trackerId
        switch requestValues.type {
        case .screen:
            tealiumRepository.trackScreen(screenId: requestValues.screenId, extraParameters: requestValues.extraParameters, language: languageCode)
            netInsightRepository.trackScreen(screenId: requestValues.screenId, extraParameters: requestValues.extraParameters, language: languageCode)
        case .event(let eventId):
            tealiumRepository.trackEvent(screenId: requestValues.screenId, eventId: eventId, extraParameters: requestValues.extraParameters, language: languageCode)
            netInsightRepository.trackEvent(screenId: requestValues.screenId, eventId: eventId, extraParameters: requestValues.extraParameters, language: languageCode)
        }
        return UseCaseResponse.ok()
    }
}

public class MetricsTrackUseCaseInput {
    
    let extraParameters: [String: String]
    let screenId: String
    let type: MetricsTrackType
    
    public init(extraParameters: [String : String], screenId: String, type: MetricsTrackType) {
        self.extraParameters = extraParameters
        self.screenId = screenId
        self.type = type
    }
}
