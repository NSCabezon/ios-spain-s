import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI
import OpenCombineFoundation

typealias PrivateSubMenuHeaderData = (title: String?, superTitle: String?)

enum PrivateSubMenuState: State {
    case idle
    case headerData(PrivateSubMenuHeaderData)
    case menuOptions([SubMenuSection])
    case footerOptions([PrivateMenuFooterOptionRepresentable])
    case personalManagerBadge(Bool)
    case footerBanner([OfferBanner?])
    case yourManager(PersonalManagerRepresentable)
}

final class PrivateSubMenuViewModel: DataBindable {
    private enum Constants {
        static let salesforceServiceID: Double = 2.0
    }
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: PrivateSubMenuDependenciesResolver
    private let stateSubject = CurrentValueSubject<PrivateSubMenuState, Never>(.idle)
    private var anySubscriptions: Set<AnyCancellable> = []
    private var insuranceDetailEnabled = false
    var state: AnyPublisher<PrivateSubMenuState, Never>
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: PrivateSubMenuDependenciesResolver) {
        self.dependencies = dependencies
        self.state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeHeaderData()
        subscribeSubMenuData()
        subscribeMenuFooterOptions()
        subscribePersonalManager()
        subscribeGetAllPersonalManagers()
    }
}

private extension PrivateSubMenuViewModel {
    var footerOptionsUseCase: GetPrivateMenuFooterOptionsUseCase {
        dependencies.external.resolve()
    }
    var personalManagerUseCase: GetPersonalManagerUseCase {
        dependencies.external.resolve()
    }
    var myProductsSubMenuUseCase: GetMyProductSubMenuUseCase {
        return dependencies.external.resolve()
    }
    var othersSubMenuUseCase: GetOtherServicesSubMenuUseCase {
        return dependencies.external.resolve()
    }
    var sofiaInvestment: GetSofiaInvestmentSubMenuUseCase {
        return dependencies.external.resolve()
    }
    var world123: GetWorld123SubMenuUseCase {
        return dependencies.external.resolve()
    }
    var insuranceDetailEnabledUseCase: GetInsuranceDetailEnabledUseCase {
        return dependencies.external.resolve()
    }
    var submenuOffersUseCase: GetPrivateSubMenuOptionOffersUseCase {
        return dependencies.resolve()
    }
    var offerImageUseCase: GetImageUseCase {
        return dependencies.resolve()
    }
}

extension PrivateSubMenuViewModel {
    func subscribeMenuFooterOptions() {
        menuFooterOptionPublisher()
            .sink { [unowned self] options in
                self.stateSubject.send(.footerOptions(options))
            }.store(in: &anySubscriptions)
    }
    
    func subscribePersonalManager() {
        personalManagerPublisher()
            .sink { [unowned self] anyUnread in
                self.stateSubject.send(.personalManagerBadge(anyUnread))
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeSubMenuData() {
        insuranceDetailEnabledPublisher()
            .sink(receiveValue: { [unowned self] in self.insuranceDetailEnabled = $0 })
            .store(in: &anySubscriptions)
        submenuDataOption()
            .map { items in
                return items.map(SubMenuSection.init)
            }
            .sink { representable in
                self.stateSubject.send(.menuOptions(representable))
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeHeaderData() {
        headerDataOption()
            .sink { [unowned self] headerData in
                self.stateSubject.send(.headerData(headerData))
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeOptionOffers(option: PrivateSubMenuOptionType) {
        optionOffersPublisher(option: option)
            .map(buildOfferURLPair)
            .flatMap(retrieveOfferImages)
            .receive(on: Schedulers.main)
            .sink(receiveValue: { [unowned self] banners in
                let sortedBanners = banners.sorted { $0.privateSubMenuOptions < $1.privateSubMenuOptions }
                self.stateSubject.send(.footerBanner(sortedBanners))
            })
            .store(in: &anySubscriptions)
    }
    
    func subscribeGetAllPersonalManagers() {
        allPersonalManagersPublishers()
            .sink { _ in
            } receiveValue: { [unowned self] managers in
                guard let yourManager = managers.first else { return }
                self.stateSubject.send(.yourManager(yourManager))
            }
            .store(in: &self.anySubscriptions)
    }
}

// MARK: - Publishers

private extension PrivateSubMenuViewModel {
    func menuFooterOptionPublisher() -> AnyPublisher<[PrivateMenuFooterOptionRepresentable], Never> {
        return footerOptionsUseCase
            .fetchFooterOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func personalManagerPublisher() -> AnyPublisher<Bool, Never> {
        return personalManagerUseCase
            .unreadNotification()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func submenuDataOption() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        guard let type: PrivateSubMenuOptionType = dataBinding.get() else
        { return Empty().eraseToAnyPublisher() }
        subscribeOptionOffers(option: type)
        switch type {
        case .myProducts:
            return myProductsPublisher()
        case .world123:
            return world123Publisher()
        case .sofia:
            return sofiaPublisher()
        case .otherServices:
            return otherServicesPublisher()
        case .smartServices:
            return Empty().eraseToAnyPublisher()
        }
    }
    
    func headerDataOption() -> AnyPublisher<PrivateSubMenuHeaderData, Never> {
        guard let type: PrivateSubMenuOptionType = dataBinding.get() else {
            return Empty().eraseToAnyPublisher()
        }
        return Just(PrivateSubMenuHeaderData(
            title: localized(type.title ?? "").uppercased(),
            superTitle: localized(type.superTitle ?? "").uppercased()))
            .eraseToAnyPublisher()
    }
    
    func myProductsPublisher() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return myProductsSubMenuUseCase
            .fetchSubMenuOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func otherServicesPublisher() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return othersSubMenuUseCase
            .fetchSubMenuOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func sofiaPublisher() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return sofiaInvestment
            .fetchSubMenuOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func world123Publisher() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return world123
            .fetchSubMenuOptions()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func insuranceDetailEnabledPublisher() -> AnyPublisher<Bool, Never> {
        return insuranceDetailEnabledUseCase
            .fetchInsuranceDetailEnabled()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func optionOffersPublisher(option: PrivateSubMenuOptionType) -> AnyPublisher<[PrivateSubMenuOptions: OfferRepresentable], Never> {
        submenuOffersUseCase
            .fetchOffersFor(option)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func allPersonalManagersPublishers() ->  AnyPublisher<[PersonalManagerRepresentable], Error> {
        return personalManagerUseCase
            .fetchPersonalManager()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Footer navigation

extension PrivateSubMenuViewModel {
    var coordinator: PrivateSubMenuCoordinator {
        return dependencies.resolve()
    }
    
    func didSelectSecurity() {
        coordinator.gotoSecurity()
    }
    
    func didSelectATM() {
        coordinator.gotoBranchLocator()
    }
    
    func didSelectHelpCenter() {
        coordinator.gotoHelpCenter()
    }
    
    func didSelectMyManager() {
        coordinator.gotoMyManager()
    }
    
    func didSelectHelpUs() {
        coordinator.gotoOpinator()
    }
}

extension PrivateSubMenuViewModel {
    func didSelectOption(_ option: PrivateSubmenuAction) {
        switch option {
        case .myProductOffer(let type, let offer):
            didSelectOffer(offer) { [weak self] in
                self?.executeMyProductAction(type)
            }
        case .sofiaOffer(let type, let offer):
            didSelectOffer(offer) { [weak self] in
                self?.executeSofiaInvestmentAction(type)
            }
        case .otherOffer(let type, let offer):
            didSelectOffer(offer) { [weak self] in
                self?.executeOtherServicesAction(type)
            }
        case .worldOffer(_, let offer):
            didSelectOffer(offer)
        }
    }
    
    func didSelectOffer(_ offer: OfferRepresentable?, completion: (() -> Void)? = nil) {
        guard let offer = offer else {
            completion?()
            return
        }
        coordinator.goToPrivateOffer(offer: offer)
    }
}

//MARK: - Actions

private extension PrivateSubMenuViewModel {
    var productsToActionsDict: [PrivateMenuMyProductsOption: (() -> Void)] {
        return [.accounts: coordinator.goToAccounts,
                .loans: coordinator.goToLoans,
                .pensions: coordinator.goToPensions,
                .funds: coordinator.goToFunds,
                .deposits: coordinator.goToDeposits,
                .cards: coordinator.goToCards,
                .savingProducts: coordinator.goToSavingProducts,
                .stocks: coordinator.goToStocks,
                .insuranceSavings: coordinator.goToInsuranceSavings,
                .insuranceProtection: coordinator.goToInsuranceProtection]
    }
    
    func executeMyProductAction(_ option: PrivateMenuMyProductsOption) {
        if insuranceDetailEnabled == false &&
            (option == .insuranceSavings || option == .insuranceProtection) {
            coordinator.showOldDialog("insurancesDetail_label_error")
        } else {
            guard let action = productsToActionsDict[option] else { return }
            action()
        }
    }
    
    func executeOtherServicesAction(_ action: PrivateMenuOtherServicesOptionType) {
        switch action {
        case .next:
            coordinator.goToComingSoon()
        case .carbonFingerPrint:
            break  // Offer
        case .smartServices:
            // TODO:
            // navigator.goToServicesForYouHelper(offerDelegate: self)
            break
        }
    }
    
    func executeSofiaInvestmentAction(_ action: SofiaInvestmentOptionType) {
        switch action {
        case .managedPortfolios:
            coordinator.goToManagedPortfolios()
        case .notManagedPortfolios:
            coordinator.goToNotManagedPortfolios()
        case .variableIncome:
            coordinator.goToVariableIncome()
        case .shareholders:
            coordinator.goToStockholders()
        case .titleWantInvest, .titleTools:
            break // Do nothing
        default:
            break  // Offers
        }
    }
}

// MARK: - Footer Offers

private extension PrivateSubMenuViewModel {
    typealias OfferURLPair = (url: String?, offer: OfferRepresentable, submenuOption: PrivateSubMenuOptions)
    
    func retrieveOfferImages(_ param: [OfferURLPair]) -> AnyPublisher<[OfferBanner], Never> {
        let bannersPublisher = param.map { tupleOfferBanner -> AnyPublisher<OfferBanner?, Never> in
            guard let url = tupleOfferBanner.url, let urlImage = URL(string: url) else  {
                return Just(buildOfferBanner(tupleOfferBanner))
                    .eraseToAnyPublisher()
            }
            return offerImageUseCase.fetchImageFromUrl(urlImage)
                .flatMap { data in
                    Just(self.buildOfferBanner(tupleOfferBanner, data: data))
                }
                .catch { _ in
                    return Just(nil)
                }
                .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(bannersPublisher)
            .compactMap { $0 }
            .collect(param.count)
            .eraseToAnyPublisher()
    }
    
    func buildOfferBanner(_ param: OfferURLPair, data: Data? = nil) -> OfferBanner {
        if let data = data, let url = param.url {
            return OfferBanner(url: url, action: param.offer.action, image: UIImage(data: data), identifier: param.offer.identifier, notBannerIcon: nil, notBannerTitle: nil, privateSubMenuOptions: param.submenuOption)
        } else {
            return OfferBanner(url: "",
                               action: param.offer.action,
                               image: nil,
                               identifier: param.offer.identifier,
                               notBannerIcon: param.submenuOption.imageKey,
                               notBannerTitle: param.submenuOption.titleKey,
                               privateSubMenuOptions: param.submenuOption)
        }
    }
    
    func buildOfferURLPair(_ offers: [PrivateSubMenuOptions: OfferRepresentable]) -> [OfferURLPair] {
        var offerURLPair = [OfferURLPair]()
        for (key, value) in offers {
            if value.bannerRepresentable?.url != nil || key.titleKey.isNotEmpty {
                offerURLPair.append(OfferURLPair(value.bannerRepresentable?.url, value, key))
            }
        }
        return offerURLPair
    }
}

struct OfferBanner: OfferRepresentable {
    let url: String
    let action: OfferActionRepresentable?
    let image: UIImage?
    let pullOfferLocation: PullOfferLocationRepresentable? = nil
    let bannerRepresentable: BannerRepresentable? = nil
    let id: String? = nil
    let identifier: String
    let transparentClosure: Bool = false
    let productDescription: String = ""
    let rulesIds: [String] = []
    let startDateUTC: Date? = nil
    let endDateUTC: Date? = nil
    let notBannerIcon: String?
    let notBannerTitle: String?
    let privateSubMenuOptions: PrivateSubMenuOptions
}
