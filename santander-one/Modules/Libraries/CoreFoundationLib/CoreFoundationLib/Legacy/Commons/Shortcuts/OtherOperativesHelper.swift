
public enum GlobalSearchActionViewType {
    case offer
    case deepLink
}

public protocol OtherOperativesHelper: AnyObject {
    var availableActions: [GpOperativesViewModel] { get set }
    var otherOperativesDelegate: OtherOperativesActionDelegate? { get }
    var wrapper: OtherOperativesEvaluator? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func getOtherOperatives(_ persistedFrequentOperatives: [PGFrequentOperativeOptionProtocol]?)
    func getOtherOperatives(_ persistedFrequentOperatives: [PGFrequentOperativeOptionProtocol]?, _ valuesProvider: PGFrequentOperativeOptionValueProviderProtocol?)
    func didSelectAction(_ action: PGFrequentOperativeOptionProtocol, _ entity: Void)
    func navigateTo(operative: PGFrequentOperativeOption)
    func goToMoreOperateOptions()
}

public extension OtherOperativesHelper {
    func getOtherOperatives(_ persistedFrequentOperatives: [PGFrequentOperativeOptionProtocol]?) {
        getOtherOperatives(persistedFrequentOperatives, nil)
    }
    
    func getOtherOperatives(_ persistedFrequentOperatives: [PGFrequentOperativeOptionProtocol]?, _ valuesProvider: PGFrequentOperativeOptionValueProviderProtocol? = nil) {
        guard let wrapper = wrapper else { return }
        let frequentOperatives = persistedFrequentOperatives ?? wrapper.getFrequentOperatives()
        let disabledOptions = self.validateDisabledOption()
        var offerImageUrls: [String: String] = [:]
        var highlightedInfo: [String: HighlightedInfo] = [:]
        if !disabledOptions.contains(where: { $0.rawValue == PGFrequentOperativeOption.shortcut.rawValue }),
           let bannerUrl = bannerUrlForLocation(ClassicShortcutPullOffers.quickAccess) {
            offerImageUrls[PGFrequentOperativeOption.shortcut.rawValue] = bannerUrl
        }
        if !disabledOptions.contains(where: { $0.rawValue == PGFrequentOperativeOption.correosCash.rawValue }),
           let bannerUrl = bannerUrlForLocation(ClassicShortcutPullOffers.correosCash) {
            offerImageUrls[PGFrequentOperativeOption.correosCash.rawValue] = bannerUrl
        }
        if let offer = wrapper.getOffer(forLocation: ClassicShortcutPullOffers.gpOperate),
           let url = offer.entity.banner?.url {
            offerImageUrls[PGFrequentOperativeOption.contract.rawValue] = url
            let description = offer.entity.productDescription
            if !description.isEmpty {
                highlightedInfo[PGFrequentOperativeOption.contract.rawValue] = HighlightedInfo(text: description,
                                                                                               isDragDisabled: false,
                                                                                               style: .skyGray)
            }
        }
        availableActions = GpOperativesActionFactory().getOtherOperativesButtons(
            frequentOperatives: frequentOperatives ?? PGFrequentOperativeOption.defaultOperatives,
            disabledOptions: disabledOptions,
            offerImageUrls: offerImageUrls,
            highlightedInfo: highlightedInfo,
            isSmartGP: wrapper.isSmartGP ?? false,
            valuesProvider: valuesProvider,
            action: { [weak self] (action, entity) in
                self?.didSelectAction(action, entity)
            })
    }
    
    func navigateTo(operative: PGFrequentOperativeOption) {
        actions[operative]??()
    }
    
    var actions: [PGFrequentOperativeOption: (() -> Void)?] {
        [
            .contract: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: "OPERAR_PG") {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                } else {
                    self?.otherOperativesDelegate?.didSelectContract()
                }
            },
            .billTax: otherOperativesDelegate?.didSelectReceipt,
            .sendMoney: otherOperativesDelegate?.didSelectSendMoney,
            .marketplace: otherOperativesDelegate?.didSelectMarketplace,
            .analysisArea: otherOperativesDelegate?.didSelectAnalysisArea,
            .financialAgenda: otherOperativesDelegate?.didSelectTimeLine,
            .customerCare: otherOperativesDelegate?.didSelectCustomerService,
            .investmentPosition: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.sofiaPosition) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .impruve: otherOperativesDelegate?.didSelectImpruve,
            .stockholders: otherOperativesDelegate?.didSelectStockholders,
            .atm: otherOperativesDelegate?.didSelectATM,
            .financing: otherOperativesDelegate?.didSelectFinancing,
            .consultPin: otherOperativesDelegate?.didSelectConsultPin,
            .personalArea: otherOperativesDelegate?.didSelectPersonalArea,
            .myManage: otherOperativesDelegate?.didSelectManager,
            .operate: goToMoreOperateOptions,
            .addBanks: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.addBanks) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .financialAnalysis: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.financeAnalysis) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .financialTips: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.financeTips) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .suscription: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.suscriptionCardPG) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .onePlan: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.onePlan) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .shortcut: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.quickAccess) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                } else {
                    self?.otherOperativesDelegate?.didSelectContract()
                }
            },
            .correosCash: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.correosCash) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            } ,
            .officeAppointment: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.officeAppointment) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .investmentsProposals: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.investmentsProposals) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .automaticOperations: { [weak self] in
                if let offer = self?.wrapper?.getOffer(forLocation: ClassicShortcutPullOffers.accountsAutomaticOperations) {
                    self?.otherOperativesDelegate?.didSelectOffer(offer.entity)
                }
            },
            .carbonFootprint: {
                self.otherOperativesDelegate?.didSelectInCarbonFootprint()
            }
        ]
    }
}

private extension OtherOperativesHelper {
    func bannerUrlForLocation(_ pullOfferLocation: String) -> String? {
        guard let wrapper = wrapper,
              let offer = wrapper.getOffer(forLocation: pullOfferLocation),
              let url = offer.entity.banner?.url
        else { return nil }
        return url
    }
    
    func validateDisabledOption(_ option: PGFrequentOperativeOption, wrapper: OtherOperativesEvaluator) -> Bool {
        switch option {
        case .addBanks, .investmentPosition, .financialAnalysis, .financialTips, .onePlan, .shortcut, .correosCash, .officeAppointment, .investmentsProposals:
            return !wrapper.isLocationEnabled(option.pullOfferTag)
        case .stockholders:
            return !wrapper.isStockholdersEnable()
        case .marketplace:
            return !wrapper.isEnableMarketplace()
        case .sendMoney:
            return wrapper.isAllAccountsEmpty()
        case .billTax:
            return wrapper.isVisibleAccountsEmpty()
        case .consultPin:
            return wrapper.isConsultPinEnabled()
        case .financing:
            return wrapper.isFinancingZoneDisabled()
        case .analysisArea:
            return wrapper.isAnalysisDisabled()
        case .suscription:
            return wrapper.isCardsMenuEmpty() || !wrapper.isLocationEnabled(option.pullOfferTag)
        case .contract:
            return wrapper.getOffer(forLocation: ClassicShortcutPullOffers.gpOperate) == nil
                && wrapper.isSanflixEnabled()
                && !wrapper.isLocationEnabled(ClassicShortcutPullOffers.sanflixContract)
        case .automaticOperations:
            return !wrapper.isLocationEnabled(option.pullOfferTag) || !wrapper.hasTwoOrMoreAccounts()
        case .operate, .financialAgenda, .customerCare, .impruve, .atm, .personalArea, .myManage:
            return false
        case .carbonFootprint:
            return wrapper.isCarbonFootprintDisable()
        }
    }
    
    func validateDisabledOption() -> [PGFrequentOperativeOptionProtocol] {
        guard let wrapper = wrapper else { return [] }
        let options: [PGFrequentOperativeOptionProtocol]
        if let getPGFrequentOperativeOption: GetPGFrequentOperativeOptionProtocol = self.dependenciesResolver.resolve(forOptionalType: GetPGFrequentOperativeOptionProtocol.self) {
            options = getPGFrequentOperativeOption.getDefault()
        } else {
            options = PGFrequentOperativeOption.allCases
        }
        var disabledOptions: [PGFrequentOperativeOptionProtocol] = []
        for option in options {
            switch option.getEnabled() {
            case .core(option: let coreOption):
                if self.validateDisabledOption(coreOption, wrapper: wrapper) {
                    disabledOptions.append(option)
                }
            case .custom(enabled: let enabled):
                if let location = option.getLocation(),
                   !location.isEmpty,
                   !wrapper.isLocationEnabled(location) && 
                    enabled() {
                    disabledOptions.append(option)
                } else if !enabled() {
                    disabledOptions.append(option)
                }
            }
        }
        return disabledOptions
    }
}

extension PGFrequentOperativeOption {
    var pullOfferTag: String {
        switch self {
        case .contract: return ClassicShortcutPullOffers.gpOperate
        case .investmentPosition: return ClassicShortcutPullOffers.sofiaPosition
        case .addBanks: return ClassicShortcutPullOffers.addBanks
        case .financialAnalysis: return ClassicShortcutPullOffers.financeAnalysis
        case .financialTips: return ClassicShortcutPullOffers.financeTips
        case .onePlan: return ClassicShortcutPullOffers.onePlan
        case .suscription: return ClassicShortcutPullOffers.suscriptionCardPG
        case .shortcut: return ClassicShortcutPullOffers.quickAccess
        case .correosCash: return ClassicShortcutPullOffers.correosCash
        case .officeAppointment: return ClassicShortcutPullOffers.officeAppointment
        case .investmentsProposals: return ClassicShortcutPullOffers.investmentsProposals
        case .automaticOperations: return ClassicShortcutPullOffers.accountsAutomaticOperations
        default: return ""
        }
    }
}
