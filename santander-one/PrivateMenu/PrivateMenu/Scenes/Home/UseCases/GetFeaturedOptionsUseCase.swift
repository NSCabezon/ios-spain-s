import CoreDomain
import CoreFoundationLib
import OpenCombine

public protocol GetFeaturedOptionsUseCase {
    func fetchFeaturedOptions() -> AnyPublisher<[PrivateMenuOptions: String], Never>
}

struct DefaultGetFeaturedOptionsUseCase {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        appConfigRepository = dependencies.resolve()
    }
}

extension DefaultGetFeaturedOptionsUseCase: GetFeaturedOptionsUseCase {
    func fetchFeaturedOptions() -> AnyPublisher<[PrivateMenuOptions: String], Never> {
        return getHighlightMenuAppConfigValue()
    }
}

private extension DefaultGetFeaturedOptionsUseCase {
    func getHighlightMenuAppConfigValue() -> AnyPublisher<[PrivateMenuOptions: String], Never> {
        let highlightMenuAppConfigValue = appConfigRepository.value(for: "highlightMenu", defaultValue: "")
        return highlightMenuAppConfigValue
            .map(serialize)
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func serialize(_ highlightMenuAppConfigValue: String)
    -> AnyPublisher<[PrivateMenuOptions: String], Never> {
        var featuredOptions: [PrivateMenuOptions: String] = [:]
        if let serializedAppConfigValue: [String: String] = CodableParser<[String: String]>().serialize(highlightMenuAppConfigValue) {
            let validKeys: [PrivateMenuOptions] = serializedAppConfigValue.keys.compactMap({PrivateMenuOptions(featuredOptionString: $0)})
            validKeys.forEach { featuredOptions[$0] = serializedAppConfigValue[$0.featuredOptionsId] }
        }
        return Just(featuredOptions).eraseToAnyPublisher()
    }
}
