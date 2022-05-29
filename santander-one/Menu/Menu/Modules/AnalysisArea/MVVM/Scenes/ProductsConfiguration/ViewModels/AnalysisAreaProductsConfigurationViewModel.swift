//
//  AnalysisAreaProductsConfigurationViewModel.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum AnalysisAreaProductsConfigurationState: State {
    case idle
    case updateErrorReceived
    case networkErrorReceived
    case companiesInfoReceived(products: [ProductListConfigurationRepresentable])
    case updateButtonStatus(Bool)
    case showMinimumProductsBottomSheet
    case updateProductsView
    case showFullScreenLoader
    case hideFullScreenLoader(completion: (() -> Void)?)
    case loadingPreferences(Bool)
    case showGenericError(goToPgWhenClose: Bool)
    case updateFooterAndOtherBanksBottomSheet(showFooter: Bool, showUpdateBank: Bool)
}

private enum Constants {
    static let SantanderId: String = "0049"
    static let accounts: String = "accounts"
    static let creditCards: String = "creditCards"
}

final class AnalysisAreaProductsConfigurationViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaProductsConfigurationDependenciesResolver
    private let stateSubject = CurrentValueSubject<AnalysisAreaProductsConfigurationState, Never>(.idle)
    var state: AnyPublisher<AnalysisAreaProductsConfigurationState, Never>
    private var updateCompaniesAfterDeleteBankOutsider = DefaultUpdateCompaniesOutsider()
    @BindingOptional fileprivate var infoFromHome: FromHomeToProductsConfigurationInfo?
    private var infoForHome = GetUpdateCompaniesOutsiderRepresentable()
    private var products: [ProductListConfigurationRepresentable] = []
    private let deleteBankSubject = PassthroughSubject<String, Never>()
    private let setPreferencesSubject = PassthroughSubject<SetFinancialHealthPreferencesRepresentable, Never>()
    private let getCompaniesProductsStatusAndSummarySubject = PassthroughSubject<(dateFrom: Date, dateTo: Date), Never>()
    private var productsModified: Set<String> = []
    private var orchestationManager: ProductsConfigurationOrchestationManager = .none
    private lazy var getCompaniesProductsStatusAndSummaryUseCase: DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase = {
        return dependencies.external.resolve()
    }()
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: AnalysisAreaProductsConfigurationDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        configureProducts()
        checkInfoFromHome()
        subscribePreferences()
        subscribeCompaniesProductsStatusAndSummary()
        subscribeUpdateCompaniesAfterDeleteBankOutsider()
    }
}

extension AnalysisAreaProductsConfigurationViewModel {
    func didTapBackOrCloseButton() {
        switch orchestationManager {
        case .productsUpdated:
            sendUpdateHomeCompaniesOutsiderInfo()
        default: break
        }
        coordinator.back()
    }
    
    func didTapUpdateProducts() {
        stateSubject.send(.showFullScreenLoader)
        orchestationManager = .productsUpdated
        infoForHome.showUpdateError = false
        getCompaniesProductsStatusAndSummaryUseCase.isAlreadySubscribed = false
        getCompaniesProductsStatusAndSummaryUseCase.productsAreUpdated = true
        getCompaniesProductsStatusAndSummary()
    }
    
    func didTapAddOtherBanks() {
        guard let offer = infoFromHome?.addOtherBanksOffer else { return }
        didSelectOffer(offer)
    }
    
    func didTapContinue() {
        stateSubject.send(.loadingPreferences(true))
        orchestationManager = .preferencesApplied
        infoForHome.showUpdateError = false
        setPreferencesSubject.send(PreferencesInput(products: products))
    }
    
    func didTapUpdatePermissions() {
        guard let offer = infoFromHome?.manageOtherBanksOffer else { return }
        didSelectOffer(offer)
    }
    
    func didTapDeleteBank(_ bank: ProducListConfigurationOtherBanksRepresentable) {
        coordinator.openDeleteOtherBank(bank: bank, updateCompaniesAfterDeleteBankOutsider: updateCompaniesAfterDeleteBankOutsider)
    }
    
    func didModifiedProductState(productId: String) {
        if allProductsUnselected() {
            stateSubject.send(.updateButtonStatus(false))
        } else {
            if productsModified.contains(productId) {
                productsModified.remove(productId)
            } else {
                productsModified.insert(productId)
            }
            checkButtonStatus()
        }
    }
    
    func didTapMinimumProductsPopupAcceptButton() {
        stateSubject.send(.loadingPreferences(true))
        orchestationManager = .preferencesApplied
        products.removeAll()
        configureProducts(companies: infoForHome.companies, statusEntities: infoForHome.productsStatus?.entitiesData)
        setOnProduct(productId: Constants.SantanderId)
        stateSubject.send(.companiesInfoReceived(products: products))
        setPreferencesSubject.send(PreferencesInput(products: products))
    }
    
    func goToPG() {
        coordinator.goToPG()
    }
}

private extension AnalysisAreaProductsConfigurationViewModel {
    var coordinator: AnalysisAreaProductsConfigurationCoordinator {
        return dependencies.resolve()
    }
    
    var getCompaniesUseCase: GetAnalysisAreaCompaniesWithProductsUseCase {
        return dependencies.external.resolve()
    }
    
    var setAnalysisAreaPreferencesUseCase: SetAnalysisAreaPreferencesUseCase {
        return dependencies.resolve()
    }
    
    func checkInfoFromHome() {
        if let infoFromHome = infoFromHome {
            if products.isNotEmpty {
                stateSubject.send(.companiesInfoReceived(products: products))
            }
            infoForHome.showUpdateError = infoFromHome.showUpdateError
            if infoForHome.showUpdateError {
                stateSubject.send(.updateErrorReceived)
            }
            infoForHome.showNetworkError = infoFromHome.showNetworkError
            if infoForHome.showNetworkError {
                stateSubject.send(.networkErrorReceived)
            }
            stateSubject.send(.updateFooterAndOtherBanksBottomSheet(showFooter: infoFromHome.addOtherBanksOffer != nil,
                                                                    showUpdateBank: infoFromHome.manageOtherBanksOffer != nil))
        }
    }
    
    func configureProducts(companies: [FinancialHealthCompanyRepresentable]? = nil, statusEntities: [FinancialHealthEntityRepresentable]? = nil) {
        var santanderCompamy: [FinancialHealthCompanyRepresentable]?
        var otherCompanies: [FinancialHealthCompanyRepresentable]?
        var otherCompaniesProductsStatus: [FinancialHealthEntityRepresentable]?
        if let companies = companies, let statusEntities = statusEntities {
            santanderCompamy = companies.filter { $0.company == Constants.SantanderId }
            otherCompanies = companies.filter { $0.company != Constants.SantanderId }
            otherCompaniesProductsStatus = statusEntities.filter { $0.company != Constants.SantanderId }
        } else {
            santanderCompamy = infoFromHome?.companies.filter { $0.company == Constants.SantanderId }
            otherCompanies = infoFromHome?.companies.filter { $0.company != Constants.SantanderId }
            otherCompaniesProductsStatus = infoFromHome?.productsStatus?.entitiesData?.filter { $0.company != Constants.SantanderId }
        }
        products.removeAll()
        addSantanderAccounts(company: santanderCompamy)
        addSantanderCards(companies: santanderCompamy)
        addOtherAccounts(companies: otherCompanies)
        addOtherCards(companies: otherCompanies)
        addOtherBanks(companies: otherCompanies, productsStatus: otherCompaniesProductsStatus)
    }
    
    func addSantanderAccounts(company: [FinancialHealthCompanyRepresentable]?) {
        var accountsProducts: [DefaultProductConfiguration] = []
        let accounts = company?.first?.companyProducts?.filter { $0.productTypeData == Constants.accounts }.first
        let urlImage = getUrlImage(urlPath: company?.first?.bankImageUrlPath)
        accounts?.productData?.forEach({ account in
            let amountValue = Decimal(string: account.balance ?? "0") ?? 0
            let amount = AmountEntity(value: amountValue, currencyCode: account.currency ?? CoreCurrencyDefault.default.rawValue)
            let iban = getIbanFormatted(ibanString: account.iban)
            accountsProducts.append(DefaultProductConfiguration(productId: account.id,
                                        title: account.productName ?? "",
                                        subTitle: iban,
                                        defatultImageName: "oneIcnBankGenericLogo",
                                        urlImage: urlImage,
                                        amount: AmountEntity(value: amountValue, currencyCode: account.currency ?? CoreCurrencyDefault.default.rawValue),
                                        selected: account.selected))
        })
        if accountsProducts.isNotEmpty {
            products.append(DefaultProductListConfiguration(type: .accounts, products: accountsProducts))
        }
    }
    
    func addSantanderCards(companies: [FinancialHealthCompanyRepresentable]?) {
        var cardsProducts: [DefaultProductConfiguration] = []
        let cards = companies?.first?.companyProducts?.filter { $0.productTypeData ==  Constants.creditCards }.first
        let urlImage = getUrlImage(urlPath: companies?.first?.cardImageUrlPath)
        cards?.productData?.forEach({ card in
            let amountValue = Decimal(string: card.balance ?? "0") ?? 0
            let amount = AmountEntity(value: amountValue, currencyCode: card.currency ?? CoreCurrencyDefault.default.rawValue)
            let pan = localized("pg_label_creditCard", [StringPlaceholder(.value, getPANShort(cardNumber: card.cardNumber))]).text
            cardsProducts.append(DefaultProductConfiguration(productId: card.id,
                                        title: card.productName ?? "",
                                        subTitle: pan,
                                        defatultImageName: "oneDefaultCard",
                                        urlImage: urlImage,
                                        amount: amount,
                                        selected: card.selected))
        })
        if cardsProducts.isNotEmpty {
            products.append(DefaultProductListConfiguration(type: .cards, products: cardsProducts))
        }
    }
    
    func addOtherAccounts(companies: [FinancialHealthCompanyRepresentable]?) {
        var otherAccountsProducts: [DefaultProductConfiguration] = []
        var companyId = ""
        companies?.forEach {
            let urlImage = getUrlImage(urlPath: $0.bankImageUrlPath)
            $0.companyProducts?.forEach {
                if $0.productTypeData == Constants.accounts {
                    $0.productData?.forEach { account in
                        let amountValue = Decimal(string: account.balance ?? "0") ?? 0
                        let amount = AmountEntity(value: amountValue, currencyCode: account.currency ?? CoreCurrencyDefault.default.rawValue)
                        let iban = getIbanFormatted(ibanString: account.iban)
                        otherAccountsProducts.append(DefaultProductConfiguration(productId: account.id,
                                                                                 title: account.productName ?? "",
                                                                                 subTitle: iban,
                                                                                 defatultImageName: "oneIcnBankGenericLogo",
                                                                                 urlImage: urlImage,
                                                                                 amount: AmountEntity(value: amountValue, currencyCode: account.currency ?? CoreCurrencyDefault.default.rawValue),
                                                                                 selected: account.selected))
                    }
                }
            }
        }
        if otherAccountsProducts.isNotEmpty {
            products.append(DefaultProductListConfiguration(type: .otherAccounts, products: otherAccountsProducts))
        }
    }
    
    func addOtherCards(companies: [FinancialHealthCompanyRepresentable]?) {
        var otherCardsProducts: [DefaultProductConfiguration] = []
        var companyId = ""
        companies?.forEach {
            let urlImage = getUrlImage(urlPath: $0.cardImageUrlPath)
            $0.companyProducts?.forEach {
                if $0.productTypeData == Constants.creditCards {
                    $0.productData?.forEach { card in
                        let amountValue = Decimal(string: card.balance ?? "0") ?? 0
                        let amount = AmountEntity(value: amountValue, currencyCode: card.currency ?? CoreCurrencyDefault.default.rawValue)
                        let pan = localized("pg_label_creditCard", [StringPlaceholder(.value, getPANShort(cardNumber: card.cardNumber))]).text
                        otherCardsProducts.append(DefaultProductConfiguration(productId: card.id,
                                                                              title: card.productName ?? "",
                                                                              subTitle: pan,
                                                                              defatultImageName: "oneIcnBankGenericCard",
                                                                              urlImage: urlImage,
                                                                              amount: AmountEntity(value: amountValue, currencyCode: card.currency ?? CoreCurrencyDefault.default.rawValue),
                                                                              selected: card.selected))
                    }
                }
            }
        }
        if otherCardsProducts.isNotEmpty {
            products.append(DefaultProductListConfiguration(type: .otherCards, products: otherCardsProducts))
        }
    }
    
    func addOtherBanks(companies: [FinancialHealthCompanyRepresentable]?, productsStatus: [FinancialHealthEntityRepresentable]?) {
        var otherBanks: [DefaultProducListConfigurationOtherBanks] = []
        guard let companies = companies, let statusEntities = productsStatus else { return }
        statusEntities.forEach { statusEntity in
            let companyWithStatusEntityID = companies.first { $0.company == statusEntity.company }
            let companyName = companyWithStatusEntityID?.companyName
            let urlImage = getUrlImage(urlPath: companyWithStatusEntityID?.bankImageUrlPath)
            otherBanks.append(DefaultProducListConfigurationOtherBanks(companyId: statusEntity.company,
                                                                       companyName: companyName,
                                                                       bankImageUrl: urlImage,
                                                                       lastUpdate: getLastUpdatedOfProductsStatus(statusEntity.company),
                                                                       notificationTitle: getNotificationTitle(statusEntity.company),
                                                                       notificationTitleAccessibilityLabel: getLastUpdateOfProductsStatusAccessibilityLabel(statusEntity.company),
                                                                       notificationLinkTitle: getNotificationLinkTitle(statusEntity.company)))
        }
        if otherBanks.isNotEmpty {
            products.append(DefaultProductListConfiguration(type: .otherBanks, otherBanksInfo: otherBanks))
        }
    }
    
    func getUrlImage(urlPath: String?) -> String {
        let baseUrlProvider: BaseURLProvider = dependencies.external.resolve()
        let baseUrl = baseUrlProvider.baseURL ?? ""
        return baseUrl + (urlPath ?? "")
    }
    
    func getPANShort(cardNumber: String?) -> String {
        guard let pan = cardNumber else { return "****" }
        return "*" + (pan.substring(pan.count - 4) ?? "*")
    }
    
    func getIbanFormatted(ibanString: String?) -> String {
        guard let ibanString = ibanString else { return "" }
        let ibanRepresented = IBANRepresented(ibanString: ibanString)
        return ibanRepresented.ibanPapel
    }
    
    func getLastUpdatedOfProductsStatus(_ bankCode: String?) -> LocalizedStylableText? {
        guard let code = bankCode,
              let bank = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode}) else { return nil }
        
        if let lastUpdate = bank.lastUpdateDate {
            let shortDate = lastUpdate.toString(TimeFormat.HHmm.rawValue)
            let longDate = lastUpdate.toString(TimeFormat.dd_MM_yy.rawValue)
            if lastUpdate.isDayInToday() {
                return localized("analysis_label_updatedToday", [StringPlaceholder(.value, shortDate)])
            } else if lastUpdate.isDayInYesterday() {
                return localized("analysis_label_updatedYesterday", [StringPlaceholder(.value, shortDate)])
            }
            return localized("analysis_label_updated", [StringPlaceholder(.value, longDate)])
        }
        return nil
    }
    
    func getLastUpdateOfProductsStatusAccessibilityLabel(_ bankCode: String?) -> String? {
        guard let code = bankCode,
              let bank = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode}) else { return nil }
        
        if let lastUpdate = bank.lastUpdateDate {
            let shortDate = lastUpdate.toString(TimeFormat.HHmm.rawValue)
            let longDate = lastUpdate.toString(TimeFormat.d_MMMM_YYYY.rawValue)
            if lastUpdate.isDayInToday() {
                return localized("analysis_label_updatedToday", [StringPlaceholder(.value, ",\(shortDate)")]).text
            } else if lastUpdate.isDayInYesterday() {
                return localized("analysis_label_updatedYesterday", [StringPlaceholder(.value, ",\(shortDate)")]).text
            }
            return localized("analysis_label_updated", [StringPlaceholder(.value, longDate)]).text
        }
        return nil
    }
    
    func getNotificationTitle(_ bankCode: String?) -> LocalizedStylableText? {
        guard let code = bankCode,
              let message = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode})?.message,
              let status = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode})?.status else { return nil }
        if status == "KO", message == "unexpected" || message == "timeout" {
            return localized("analysis_label_alertSyncError")
        } else if status == "KO", message == "credentials" {
            return localized("analysis_label_alertCheckCredentials")
        }
        return nil
    }
    
    func getNotificationLinkTitle(_ bankCode: String?) -> String? {
        guard let code = bankCode,
              let message = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode})?.message,
              let status = infoFromHome?.productsStatus?.entitiesData?.first(where: {$0.company == bankCode})?.status else { return nil }
        if status == "KO", message == "credentials", infoFromHome?.manageOtherBanksOffer != nil {
            return localized("generic_button_review")
        }
        return nil
    }
    
    func checkButtonStatus() {
        self.stateSubject.send(.updateButtonStatus(productsModified.isNotEmpty))
    }
    
    func allProductsUnselected() -> Bool {
        let selectedProducts = self.products.compactMap {
            $0.products?.filter { $0.selected == true }
        }.flatMap { $0 }
        return selectedProducts.isEmpty
    }
    
    func setOnProduct(productId: String) {
        var productIdsToSelect: [String] = []
        infoForHome.companies.forEach { companyForHome in
            if companyForHome.company == productId {
                companyForHome.companyProducts?.forEach({ companyProduct in
                    companyProduct.productData?.forEach({ companyProductData in
                        productIdsToSelect.append(companyProductData.id ?? "")
                    })
                })
            }
        }
        products.forEach { product in
            product.products?.forEach({ productData in
                if productIdsToSelect.contains(productData.productId ?? "") {
                    productData.setSelected(isOn: true)
                }
            })
        }
    }
    
    func didSelectOffer(_ offer: OfferRepresentable) {
        coordinator.executeOffer(offer)
    }
    
    func sendUpdateHomeCompaniesOutsiderInfo() -> Bool {
        if infoForHome.productsStatus != nil && infoForHome.companies.isNotEmpty ?? false {
            infoFromHome?.updateCompaniesOutsider.send(.data(infoForHome))
            return true
        } else {
            return false
        }
    }
    
    func getCompaniesProductsStatusAndSummary() {
        if let summaryInputFromHome = infoFromHome?.summaryInput {
            self.getCompaniesProductsStatusAndSummarySubject.send((dateFrom: summaryInputFromHome.dateFrom,
                                                                   dateTo: summaryInputFromHome.dateTo))
        }
    }
    
    func setOrchestationManager() {
        if infoForHome.productsStatus != nil {
            switch orchestationManager {
            case .productsUpdated:
                products.removeAll()
                configureProducts(companies: infoForHome.companies, statusEntities: infoForHome.productsStatus?.entitiesData)
                stateSubject.send(.companiesInfoReceived(products: products))
                stateSubject.send(.hideFullScreenLoader(completion: {
                    self.stateSubject.send(.hideFullScreenLoader(completion: nil))
                }))
                
            case .preferencesApplied:
                stateSubject.send(.loadingPreferences(false))
                if sendUpdateHomeCompaniesOutsiderInfo() {
                    coordinator.back()
                } else {
                    stateSubject.send(.loadingPreferences(false))
                    stateSubject.send(.showGenericError(goToPgWhenClose: false))
                }
                
            case .otherBankConnectionDeleted:
                stateSubject.send(.hideFullScreenLoader(completion: {
                    if self.sendUpdateHomeCompaniesOutsiderInfo() {
                        self.coordinator.back()
                    } else {
                        self.stateSubject.send(.hideFullScreenLoader(completion: {
                            self.stateSubject.send(.showGenericError(goToPgWhenClose: false))
                        }))
                    }
                }))
                
            default: return
            }
        }
    }
}

// MARK: Subscriptions
private extension AnalysisAreaProductsConfigurationViewModel {
    func subscribePreferences() {
        preferencesPublisher()
            .sink(receiveCompletion: { [unowned self] completion in
                guard case .failure = completion else { return }
                stateSubject.send(.loadingPreferences(false))
                stateSubject.send(.showGenericError(goToPgWhenClose: false))
            }, receiveValue: { [unowned self] _ in
                getCompaniesProductsStatusAndSummary()
            }).store(in: &anySubscriptions)
    }
    
    func subscribeUpdateCompaniesAfterDeleteBankOutsider() {
        updateCompaniesAfterDeleteBankOutsider.publisher
            .sink { [unowned self] output in
                guard case .void = output else { return }
                stateSubject.send(.showFullScreenLoader)
                orchestationManager = .otherBankConnectionDeleted
                getCompaniesProductsStatusAndSummary()
            }.store(in: &anySubscriptions)
    }
    
    func subscribeCompaniesProductsStatusAndSummary() {
        companiesProductsStatusAndSummaryPublisher()
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else { return }
                self.stateSubject.send(.showGenericError(goToPgWhenClose: true))
            }, receiveValue: { [unowned self] state in
                switch state {
                case .finishedCompanies(let selectedProducts,
                                        let companies,
                                        let companiesWithProductsSelected,
                                        let accountsSelected,
                                        let cardsSelected):
                    infoForHome.selectedProducts = selectedProducts
                    infoForHome.companies = companies
                    infoForHome.companiesWithProductsSelected = companiesWithProductsSelected
                    infoForHome.accountsSelected = accountsSelected
                    infoForHome.cardsSelected = cardsSelected
                    
                case .finishedCompaniesWithUnselectedProducts:
                    stateSubject.send(.loadingPreferences(false))
                    stateSubject.send(.hideFullScreenLoader(completion: {
                        self.stateSubject.send(.showMinimumProductsBottomSheet)
                    }))
                    
                case .finishedCompaniesWithError:
                    stateSubject.send(.loadingPreferences(false))
                    stateSubject.send(.hideFullScreenLoader(completion: {
                        stateSubject.send(.showGenericError(goToPgWhenClose: true))
                    }))
                    
                case .finishedProductsStatusOK(let productsStatus):
                    infoForHome.showNetworkError = false
                    infoForHome.productsStatus = productsStatus
                    setOrchestationManager()
                    
                case .finishedProductsStatusWithError:
                    infoForHome.showNetworkError = true
                    stateSubject.send(.loadingPreferences(false))
                    stateSubject.send(.hideFullScreenLoader(completion: {
                        stateSubject.send(.networkErrorReceived)
                    }))
                    
                case .finishedProductsStatusWithOutdatedAlert:
                    infoForHome.showNetworkError = false
                    infoForHome.showUpdateError = true
                    stateSubject.send(.updateErrorReceived)
                    
                case .finishedSummary(let summary):
                    infoForHome.summary = summary
                    setOrchestationManager()
                    
                case .finishedSummaryWithError:
                    stateSubject.send(.showGenericError(goToPgWhenClose: true))
                    
                default: break
                }
            }).store(in: &anySubscriptions)
    }
}

// MARK: Publishers
private extension AnalysisAreaProductsConfigurationViewModel {
    func preferencesPublisher() -> AnyPublisher<Void, Error> {
        return setPreferencesSubject
            .map { [unowned self] preferences in
                setAnalysisAreaPreferencesUseCase
                    .fetchSetFinancialPreferencesPublisher(preferences: preferences)
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func companiesProductsStatusAndSummaryPublisher() -> AnyPublisher<CompaniesProductsStatusAndSummaryUseCaseState, Error> {
        return getCompaniesProductsStatusAndSummarySubject
            .map { [unowned self] (dateFrom, dateTo) in
                getCompaniesProductsStatusAndSummaryUseCase
                    .fetchFinancialCompaniesProductsStatusAndSummaryPublisher(dateFromSummaryInput: dateFrom,
                                                                              dateToSummaryInput: dateTo)
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

private enum ProductsConfigurationOrchestationManager {
    case none
    case productsUpdated
    case preferencesApplied
    case otherBankConnectionDeleted
}
