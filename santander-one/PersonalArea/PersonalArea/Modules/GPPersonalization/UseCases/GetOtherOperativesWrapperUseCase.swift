import CoreFoundationLib
import SANLegacyLibrary

private extension GetOtherOperativesWrapperUseCase {
    enum Constants {
        static let enabledAnalysisZone = "enabledAnalysisZone"
        static let enableMarketplace = "enableMarketplace"
        static let enabledEnvioDineroPGClasica = "enabledEnvioDineroPGClasica"
        static let enabledEnvioDineroPGSmart = "enabledEnvioDineroPGSmart"
        static let enabledApplyBySanflix = "enableApplyBySanflix"
        static let enabledPublicProducts = "enablePublicProducts"
        static let enabledFinancingZone = "enableFinancingZone"
        static let enableStockholders = "enableStockholders"
        static let shortcutsPG1 = "shortcutsPG1"
        static let shortcutsPG2 = "shortcutsPG2"
        static let shortcutsPG3 = "shortcutsPG3"
    }
}

final class GetOtherOperativesWrapperUseCase: UseCase<GetOtherOperativesWrapperUseCaseInput, GetOtherOperativesWrapperUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let appRepository: AppRepositoryProtocol
    private let pullOffersInterpreter: PullOffersInterpreter
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: GetOtherOperativesWrapperUseCaseInput) throws -> UseCaseResponse<GetOtherOperativesWrapperUseCaseOkOutput, StringErrorOutput> {
        let isAnalysisAreaEnabled = appConfigRepository.getBool(Constants.enabledAnalysisZone) ?? false
        let isFinancingZoneEnabled = appConfigRepository.getBool(Constants.enabledFinancingZone) ?? false
        let enableMarketplace = appConfigRepository.getBool(Constants.enableMarketplace) ?? false
        let isSanflixEnabled = appConfigRepository.getBool(Constants.enabledApplyBySanflix) ?? false
        let isPublicProductEnable = appConfigRepository.getBool(Constants.enabledPublicProducts) ?? false
        let enableStockholders = appConfigRepository.getBool(Constants.enableStockholders) ?? false
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve()
        let visibleAccountsEmpty = globalPosition.accounts.visibles().isEmpty
        let allAccountsEmpty = globalPosition.accounts.all().isEmpty
        let cardsEmpty = globalPosition.cards.visibles().isEmpty
        let loansEmpty = globalPosition.loans.visibles().isEmpty
        let isAnalysisZoneEnabled = isAnalysisAreaEnabled && (!visibleAccountsEmpty || !cardsEmpty || !loansEmpty)
        let hasTwoOrMoreAccounts = globalPosition.accounts.all().count >= 2
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        let userPref = globalPosition.userPref
        let frequentOperatives = try getFrequentOperatives(userPrefDTO: userPref?.userPrefDTOEntity)
        if let userPrefDTO = userPref?.userPrefDTOEntity {
            self.appRepository.setUserPreferences(userPref: userPrefDTO)
        }
        return .ok(
            GetOtherOperativesWrapperUseCaseOkOutput(
                isSmartGP: userPref?.globalPositionOnboardingSelected() == .smart,
                isAnalysisDisabledVariable: !isAnalysisZoneEnabled,
                isFinancingZoneDisabledVariable: !isFinancingZoneEnabled,
                isConsultPinEnabledVariable: cardsEmpty,
                isVisibleAccountsEmptyVariable: visibleAccountsEmpty,
                isAllAccountsEmptyVariable: allAccountsEmpty,
                isCardsMenuEmptyVariable: cardsEmpty,
                isSmartUserVariable: userPref?.isSmartUser() == true,
                isEnableMarketplaceVariable: enableMarketplace,
                isSanflixEnabledVariable: isSanflixEnabled,
                isPublicProductEnableVariable: isPublicProductEnable,
                frequentOperatives: frequentOperatives,
                offers: outputCandidates,
                enableStockholders: enableStockholders,
                hasTwoOrMoreAccountsVariable: hasTwoOrMoreAccounts
            )
        )
    }
}

private extension GetOtherOperativesWrapperUseCase {
    func getFrequentOperatives(userPrefDTO: UserPrefDTOEntity?) throws -> [PGFrequentOperativeOptionProtocol]? {
        guard let userPrefDTO = userPrefDTO else { return nil }
        let userPref = UserPrefEntity.from(dto: userPrefDTO)
        var frequentOperatives: [PGFrequentOperativeOptionProtocol]
        if let getPGFrequentOperative: GetPGFrequentOperativeOptionProtocol = self.dependenciesResolver.resolve(forOptionalType: GetPGFrequentOperativeOptionProtocol.self) {
            frequentOperatives = getPGFrequentOperative.get(globalPositionType: userPref.globalPositionOnboardingSelected())
        } else {
            frequentOperatives = try self.getDefaultFrequentOperatives()
        }
        if var savedFrequentOperativesKeys = userPref.getFrequentOperativesKeys() {
            frequentOperatives.lazy
                .filter { !savedFrequentOperativesKeys.contains($0.rawValue) }
                .forEach { savedFrequentOperativesKeys.append($0.rawValue) }
            userPref.setFrequentOperativesKeys(savedFrequentOperativesKeys)
            let operatives: [PGFrequentOperativeOptionProtocol] = savedFrequentOperativesKeys.compactMap { key in
                return frequentOperatives.first(where: { return key == $0.rawValue })
            }
            frequentOperatives = operatives
        }
        return frequentOperatives
    }
    
    func getDefaultFrequentOperatives() throws -> [PGFrequentOperativeOptionProtocol] {
        var frequentOperatives: [PGFrequentOperativeOption]
        let listShortcutsPG1 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG1) ?? []
        let listShortcutsPG2 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG2) ?? []
        let listShortcutsPG3 = appConfigRepository.getAppConfigListNode(Constants.shortcutsPG3) ?? []
        let userCampaigns = try (provider.getBsanPullOffersManager().getCampaigns().getResponseData()) ?? []
        let shortcuts = [
            listShortcutsPG1,
            listShortcutsPG2,
            listShortcutsPG3
        ].enumerated().first {
            $0.element.first { userCampaigns?.contains($0) == true } != nil
        }
        switch shortcuts?.offset {
        case 0?:
            frequentOperatives = PGFrequentOperativeOption.operativesForConfigurationOne
        case 1?:
            frequentOperatives = PGFrequentOperativeOption.operativesForConfigurationTwo
        case 2?:
            frequentOperatives = PGFrequentOperativeOption.operativesForConfigurationThree
        default:
            frequentOperatives = PGFrequentOperativeOption.defaultOperatives
        }
        return frequentOperatives
    }
}

struct GetOtherOperativesWrapperUseCaseInput {
    let locations: [PullOfferLocation]
}

struct GetOtherOperativesWrapperUseCaseOkOutput: OtherOperativesEvaluator {
    var isSmartGP: Bool?
    var isAnalysisDisabledVariable: Bool
    var isFinancingZoneDisabledVariable: Bool
    var isConsultPinEnabledVariable: Bool
    var isVisibleAccountsEmptyVariable: Bool
    var isAllAccountsEmptyVariable: Bool
    var isCardsMenuEmptyVariable: Bool
    var isSmartUserVariable: Bool
    var isEnableMarketplaceVariable: Bool
    var isSanflixEnabledVariable: Bool
    var isPublicProductEnableVariable: Bool
    var frequentOperatives: [PGFrequentOperativeOptionProtocol]?
    var offers: [PullOfferLocation: OfferEntity]
    var enableStockholders: Bool
    var hasTwoOrMoreAccountsVariable: Bool
    
    func isAnalysisDisabled() -> Bool { isAnalysisDisabledVariable }
    func isFinancingZoneDisabled() -> Bool { isFinancingZoneDisabledVariable }
    func isConsultPinEnabled() -> Bool { isConsultPinEnabledVariable }
    func isAllAccountsEmpty() -> Bool { isAllAccountsEmptyVariable }
    func isVisibleAccountsEmpty() -> Bool { isVisibleAccountsEmptyVariable }
    func isCardsMenuEmpty() -> Bool { isCardsMenuEmptyVariable }
    func isSmartUser() -> Bool { isSmartUserVariable }
    func isEnableMarketplace() -> Bool { isEnableMarketplaceVariable }
    func isSanflixEnabled() -> Bool { isSanflixEnabledVariable }
    func isPublicProductEnable() -> Bool { isPublicProductEnableVariable }
    func getFrequentOperatives() -> [PGFrequentOperativeOptionProtocol]? { frequentOperatives }
    func isLocationEnabled(_ location: String) -> Bool {
        return offers.contains(location: location)
    }
    func getOffer(forLocation location: String) -> PullOfferCompleteInfo? {
        guard let (realLocation, offer) = offers.location(key: location) else { return nil }
        return PullOfferCompleteInfo(location: realLocation, entity: offer)
    }
    func isStockholdersEnable() -> Bool { enableStockholders }
    func hasTwoOrMoreAccounts() -> Bool { hasTwoOrMoreAccountsVariable }
    func isCarbonFootprintDisable() -> Bool { true }
}
