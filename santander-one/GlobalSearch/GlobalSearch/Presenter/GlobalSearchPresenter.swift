import CoreFoundationLib
import UI

protocol GlobalSearchPresenterProtocol {
    var view: GlobalSearchViewProtocol? { get set }
    var isMainOperativesViewEnabled: Bool { get }
    var isSegmentedControlViewEnabled: Bool { get }
    func viewDidLoad()
    func closeButtonAction()
    func goBackAction()
    func textFieldDidSet(text: String)
    func reportDuplicateMovementAction()
    func returnBillAction()
    func reuseTransferAction()
    func switchOffCardAction()
    func didSelectMovement(at index: Int, groupedBy productId: String?, of type: GlobalSearchMovementType)
    func didSelectAction(identifier: String?)
    func didSelectAction(identifier: String?, type: GlobalSearchActionViewType)
    func trackFaqEvent(_ question: String, url: URL?)
    func didSetEmptyView()
}

final class GlobalSearchPresenter {
    
    weak var view: GlobalSearchViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var timer: Timer?
    private var searchedTerm: String = ""
    private var reportNumber: String? {
        didSet {
            view?.setReportNumber(reportNumber ?? "")
        }
    }
    private var useCaseOutput: GlobalSearchUseCaseOkOutput?
    private var resultMovements: [GlobalSearchResultMovementViewModel]?
    
    private var globalSearchCoordinator: GlobalSearchMainModuleCoordinatorDelegate {
        return dependenciesResolver.resolve(for: GlobalSearchMainModuleCoordinatorDelegate.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var keywords: [SearchKeywordEntity] = []
    private var globalAppKeywords: [GlobalAppKeywordsEntity] = []
    private lazy var globalSearchConfiguration: GlobalSearchConfigurationModifierProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: GlobalSearchConfigurationModifierProtocol.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension GlobalSearchPresenter: GlobalSearchPresenterProtocol {
    var isMainOperativesViewEnabled: Bool {
        guard let configuration = self.globalSearchConfiguration else { return true }
        return configuration.isMainOperativesSectionEnabled
    }
    
    var isSegmentedControlViewEnabled: Bool {
        guard let configuration = self.globalSearchConfiguration else { return true }
        return configuration.isSegmentedControlEnabled
    }
    
    func viewDidLoad() {
        getGlobalSearchKeywords()
        getReportNumber()
        getGlobalSearchFAQS()
        getInterestsAndHomeTips()
        trackScreen()
    }
    
    func closeButtonAction() { globalSearchCoordinator.didSelectDismiss() }
    func goBackAction() { globalSearchCoordinator.didSelectDismiss() }
    
    func textFieldDidSet(text: String) {
        timer?.invalidate()
        searchedTerm = text.trim()
        if !searchedTerm.isEmpty && !searchedTerm.isBlank {
            startTimer()
        }
    }
    
    // MARK: - Deeplink buttons screen actions
    
    func reportDuplicateMovementAction() {
        let telf = "tel://\((reportNumber ?? "").replacingOccurrences(of: " ", with: ""))"
        trackEvent(.reportDuplicatedMovement, parameters: [.tfno: telf])
        globalSearchCoordinator.open(url: telf)
    }
    
    func returnBillAction() {
        checkUserAccounts { [weak self] isUserWithAccounts in
            self?.trackEvent(.returnBill, parameters: [:])
            isUserWithAccounts ? self?.globalSearchCoordinator.goToBills() : self?.showAlertDialog(for: .bills)
        }
    }
    
    func reuseTransferAction() {
        checkUserAccounts { [weak self] isUserWithAccounts in
            self?.trackEvent(.reuseTransfer, parameters: [:])
            isUserWithAccounts ? self?.globalSearchCoordinator.goToTransfers() : self?.showAlertDialog(for: .transferts)
        }
    }
    
    func switchOffCardAction() {
        trackEvent(.offCard, parameters: [:])
        globalSearchCoordinator.goToSwitchOffCard()
    }
    
    // MARK: - Result view actions
    
    func didSelectMovement(at index: Int, groupedBy productId: String?, of type: GlobalSearchMovementType) {
        switch type {
        case .account:
            handleAccountSelection(at: index, groupedBy: productId)
        case .card:
            handleCardSelection(at: index, groupedBy: productId)
        }
    }
    
    func didSelectAction(identifier: String?) {
        guard let identifier = identifier else { return }
        processOffer(withIdentifier: identifier)
    }
    
    func didSelectAction(identifier: String?, type: GlobalSearchActionViewType) {
        guard let identifier = identifier else { return }
        switch type {
        case .offer:
            processOffer(withIdentifier: identifier)
        case .deepLink:
            let dict = [TrackerDimension.tipName.key: identifier,
                        TrackerDimension.searchedTerm.key: searchedTerm]
            trackerManager.trackEvent(screenId: "global_finder",
                                      eventId: GlobalSearchPage.Action.action.rawValue,
                                      extraParameters: dict)
            globalSearchCoordinator.executeDeepLink(identifier)
        }
    }
    
    func processOffer(withIdentifier identifier: String) {
        if let offer = (self.useCaseOutput?.actionTipsOffers?[identifier]) {
            self.globalSearchCoordinator.executeOffer(offer)
        } else if let offer = self.useCaseOutput?.homeTipsOffers?[identifier] {
            self.globalSearchCoordinator.executeOffer(offer)
        } else if let offer = self.useCaseOutput?.interestTipsOffers?[identifier] {
            self.globalSearchCoordinator.executeOffer(offer)
        }
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = [TrackerDimension.faqQuestion.key: question]
        if let link = url?.absoluteString {
            dic[TrackerDimension.faqLink.key] = link
        }
        trackerManager.trackEvent(screenId: "global_finder",
                                  eventId: eventId,
                                  extraParameters: dic)
    }
    
    func didSetEmptyView() {
        self.getInterestsAndHomeTips()
    }
}

extension GlobalSearchPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GlobalSearchPage {
        return GlobalSearchPage()
    }
}

// MARK: - Private Methods

private extension GlobalSearchPresenter {
    
    private var globalSearchUseCase: GlobalSearchUseCase {
         return self.dependenciesResolver.resolve(for: GlobalSearchUseCase.self)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.performSearch()
        }
    }
    
    func performSearch() {
        let input: GlobalSearchUseCaseInput = GlobalSearchUseCaseInput(dependenciesResolver: dependenciesResolver,
                                                                       substring: searchedTerm,
                                                                       withMovements: self.globalSearchConfiguration?.isTransactionSearchEnabled ?? true,
                                                                       withInterestTips: self.globalSearchConfiguration?.isInterestsTipsSearchEnabled ?? true,
                                                                       withActions: self.globalSearchConfiguration?.isActionsSearchEnabled ?? true)
        trackEvent(.search, parameters: [:])
        Scenario(useCase: globalSearchUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.showResult(from: response)
            }
    }
    
    func getInterestsAndHomeTips() {
        let input: GlobalSearchUseCaseInput = GlobalSearchUseCaseInput(dependenciesResolver: self.dependenciesResolver, substring: "", tipsSearchType: .homeAndInterestsTips)
        let baseURL = (self.baseURLProvider.baseURL ?? "").dropLast(1)
        Scenario(useCase: globalSearchUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.useCaseOutput = response
                let homeTips = response.homeTips?.compactMap({HelpCenterTipViewModel($0, baseUrl: String(baseURL))}) ?? []
                let interestsTips = response.interestTips?.compactMap({HelpCenterTipViewModel($0, baseUrl: String(baseURL))}) ?? []
                self?.view?.showInitialHomeTips(homeTips)
                self?.view?.showInitialInterestsTips(interestsTips)
            }
    }
    
    func getReportNumber() {
        let input: GetReportMovementsPhoneNumberUseCaseInput = GetReportMovementsPhoneNumberUseCaseInput(dependenciesResolver: dependenciesResolver)
        let usecase: GetReportMovementsPhoneNumberUseCase = self.dependenciesResolver.resolve(for: GetReportMovementsPhoneNumberUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: { [weak self] (resp) in
            self?.reportNumber = resp.phone
        })
    }
    
    func getGlobalSearchFAQS() {
        let usecase: GetGlobalSearchFAQsUseCase = self.dependenciesResolver.resolve(for: GetGlobalSearchFAQsUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, onSuccess: { [weak self] (resp) in
            guard let entities = resp.faqs, entities.count > 0 else { return }
            let baseURL = (self?.baseURLProvider.baseURL ?? "").dropLast(1)
            let vms = entities.map({ TripFaqViewModel(dto: $0.dto, baseURL: String(baseURL))})
            
            self?.view?.showNeedHelpForFAQs(vms)
        })
    }
}

private extension GlobalSearchPresenter {
    
    func getGlobalSearchKeywords() {
        let usecase: GetSearchKeywordsUseCase = self.dependenciesResolver.resolve(for: GetSearchKeywordsUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, onSuccess: { [weak self] resp in
            self?.keywords = resp.keywords
            self?.globalAppKeywords = resp.globalAppKeywords
        })
    }
    
    func setupMisspelledWords() {
        var suggestedSearchTerm: String?
        for entity in keywords {
            let errorWords = entity.errorWords.compactMap { $0.lowercased() }
            if errorWords.contains(searchedTerm.lowercased()) || entity.lexeme.lowercased() == searchedTerm.lowercased() {
                suggestedSearchTerm = entity.word
                break
            }
        }
        view?.showEmptyView(term: searchedTerm, suggestedTerm: suggestedSearchTerm)
    }
    
    func showResult(from useCaseOutput: GlobalSearchUseCaseOkOutput) {
        guard !searchedTerm.isEmpty else { return }
        self.useCaseOutput = useCaseOutput
        
        var resultMovements = [GlobalSearchResultMovementViewModel]()
        
        if let accountMovements = getAccountMovements(from: useCaseOutput.accountsMovements) {
            resultMovements.append(contentsOf: accountMovements.map { GlobalSearchResultMovementViewModel(resultType: .account,
                                                                                                          movement: $0) })
        }
        if let cardMovements = getCardMovements(from: useCaseOutput.cardsMovements) {
            resultMovements.append(contentsOf: cardMovements.map { GlobalSearchResultMovementViewModel(resultType: .card,
                                                                                                       movement: $0) })
        }
        
        let baseURL = (self.baseURLProvider.baseURL ?? "").dropLast(1)
        let helpFAQs = useCaseOutput.faqs.map { TripFaqViewModel(iconName: ($0.icon ?? ""),
                                                                 titleKey: $0.question,
                                                                 descriptionKey: $0.answer,
                                                                 highlightedDescriptionKey: searchedTerm,
                                                                 baseURL: String(baseURL))
        }
        
        let needHelpFAQs = useCaseOutput.globalFAQs.map { TripFaqViewModel(iconName: ($0.icon ?? ""),
                                                                           titleKey: $0.question,
                                                                           descriptionKey: $0.answer,
                                                                           highlightedDescriptionKey: searchedTerm,
                                                                           baseURL: String(baseURL))
        }
        var actions = useCaseOutput.actionTips?.map { GlobalSearchActionViewModel(iconName: ($0.icon ?? ""),
                                                                                  titleKey: $0.title ?? "",
                                                                                  descriptionKey: $0.description ?? "",
                                                                                  highlightedDescriptionKey: searchedTerm,
                                                                                  baseURL: String(baseURL),
                                                                                  identifier: $0.offerId ?? "",
                                                                                  type: .offer)
        } ?? []
        
        let deepLinks = globalAppKeywords
            .filter({ keyword in
                for key in keyword.keywords {
                    if key.lowercased().contains(searchedTerm.lowercased()) {
                        return true
                    }
                }
                return false
            })
            .map({ GlobalSearchActionViewModel(iconName: $0.icon,
                                               titleKey: $0.title,
                                               descriptionKey: "",
                                               highlightedDescriptionKey: searchedTerm,
                                               baseURL: String(baseURL),
                                               identifier: $0.deepLinkIdentifier,
                                               type: .deepLink)
            })
        actions.append(contentsOf: deepLinks)
        
        let homeTips = useCaseOutput.homeTips?.compactMap({
            HelpCenterTipViewModel($0,
                                   baseUrl: String(baseURL),
                                   highlightedDescriptionKey: searchedTerm)
        }) ?? []
        let interestTips = useCaseOutput.interestTips?.compactMap({
            HelpCenterTipViewModel($0,
                                   baseUrl: String(baseURL),
                                   highlightedDescriptionKey: searchedTerm)
        }) ?? []
        
        self.resultMovements = sortMovements(resultMovements)
        if resultMovements.count > 0 ||
            helpFAQs.count > 0 ||
            needHelpFAQs.count > 0 ||
            actions.count > 0 ||
            homeTips.count > 0 ||
            interestTips.count > 0 {
            view?.setSearchResultModel(from: GlobalSearchViewModel(movements: self.resultMovements ?? [],
                                                                   actions: actions,
                                                                   homeTips: homeTips,
                                                                   interestTips: interestTips,
                                                                   help: helpFAQs,
                                                                   needHelpFor: needHelpFAQs,
                                                                   searchTerm: self.searchedTerm))
        } else {
            setupMisspelledWords()
        }
    }
    
    func sortMovements(_ movements: [GlobalSearchResultMovementViewModel]) -> [GlobalSearchResultMovementViewModel] {
        movements.sorted {
            guard let first = createSimplifiedMovement($0.movement.entity) else { return false }
            guard let second = createSimplifiedMovement($1.movement.entity) else { return false }
            return compare(first, second)
        }
    }
    
    func createSimplifiedMovement(_ entity: Any) -> SimplifiedMovement? {
        if let card = entity as? CardTransactionWithCardEntity {
            return simplifiedCardMovement(card)
        } else if let account = entity as? AccountTransactionWithAccountEntity {
            return simplifiedAccountMovement(account)
        }
        return nil
    }
    
    func simplifiedCardMovement(_ card: CardTransactionWithCardEntity) -> SimplifiedMovement {
        return SimplifiedMovement(date: card.cardTransactionEntity.operationDate,
                                  identifier: card.cardEntity.pan,
                                  value: card.cardTransactionEntity.amount?.value)
    }
    
    func simplifiedAccountMovement(_ account: AccountTransactionWithAccountEntity) -> SimplifiedMovement {
        return SimplifiedMovement(date: account.accountTransactionEntity.operationDate,
                                  identifier: account.accountEntity.getIban()?.ibanString ?? account.accountEntity.getIBANShort,
                                  value: account.accountTransactionEntity.amount?.value)
    }
    
    func compare(_ movementA: SimplifiedMovement, _ movementB: SimplifiedMovement) -> Bool {
        if SortingCriteria.datesAreDifferent(dateA: movementA.date,
                                             dateB: movementB.date) {
            return SortingCriteria.sortByDate(dateA: movementA.date,
                                              dateB: movementB.date,
                                              order: .orderedDescending)
        } else if movementA.identifier != movementB.identifier {
            return movementA.identifier < movementB.identifier
        } else {
            return SortingCriteria.sortByAmount(firstAmount: movementA.value,
                                                secondAmount: movementB.value)
        }
    }
    
    func getAccountMovements(from output: [AccountTransactionWithAccountEntity]) -> [GlobalSearchMovementViewModel]? {
        guard output.count > 0 else { return nil }
        return output.map {
            GlobalSearchMovementViewModel(amount: $0.accountTransactionEntity.amount,
                                          date: $0.accountTransactionEntity.operationDate,
                                          concept: $0.accountTransactionEntity.alias,
                                          alias: ("\($0.accountEntity.alias ?? "") | \($0.accountEntity.getIBANShort)"),
                                          productImageUrl: nil,
                                          dependenciesResolver: dependenciesResolver,
                                          searchedTerm: searchedTerm,
                                          entity: $0)
        }
    }
    
    func getCardMovements(from output: [CardTransactionWithCardEntity]) -> [GlobalSearchMovementViewModel]? {
        guard output.count > 0 else { return nil }
        return output.map {
            GlobalSearchMovementViewModel(amount: $0.cardTransactionEntity.amount,
                                          date: $0.cardTransactionEntity.operationDate,
                                          concept: $0.cardTransactionEntity.description,
                                          alias: $0.cardEntity.getAliasAndInfo(),
                                          productImageUrl: (useCaseOutput?.baseURL ?? "") + $0.cardEntity.buildImageRelativeUrl(miniature: true),
                                          dependenciesResolver: dependenciesResolver,
                                          searchedTerm: searchedTerm,
                                          entity: $0)
        }
    }
    
    func checkUserAccounts(isUserWithAccounts: @escaping (Bool) -> Void) {
        let input: GlobalSearchCheckProductsUseCaseInput = GlobalSearchCheckProductsUseCaseInput(dependenciesResolver: dependenciesResolver)
        let usecase: GlobalSearchCheckProductsUseCase = self.dependenciesResolver.resolve(for: GlobalSearchCheckProductsUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler,
                       onSuccess: { (resp) in
                        isUserWithAccounts(resp.userAccounts.visibles().count > 0)
        })
    }
    
    func showAlertDialog(for alertType: GlobalSearchErrorAlerType) {
        globalSearchCoordinator.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: nil,
            body: localized(alertType.rawValue),
            acceptAction: nil,
            cancelAction: nil)
    }
    
    func handleAccountSelection(at index: Int, groupedBy productId: String?) {
        
        var filteredAccountMovements: [AccountTransactionWithAccountEntity]?
        var selectedAccountMovement: AccountTransactionWithAccountEntity?
            
        if let valueToCompare = productId {
            // Get only movements with the same productIdentifier and select the position from all the filtered movements
            filteredAccountMovements = useCaseOutput?.accountsMovements.filter({ (model) -> Bool in
                model.accountEntity.productIdentifier == valueToCompare
            })
            selectedAccountMovement = (index < filteredAccountMovements?.count ?? 0) ? filteredAccountMovements?[index] : nil
            
        } else {
            // Get all movements and select the position from all the searched movements
            filteredAccountMovements = useCaseOutput?.accountsMovements
            selectedAccountMovement = (index < self.resultMovements?.count ?? 0) ? self.resultMovements?[index].movement.entity as? AccountTransactionWithAccountEntity : nil
        }
            
        guard let accountMovements = filteredAccountMovements,
            let accountMovement = selectedAccountMovement
            else { return }
        globalSearchCoordinator.didSelectAccountMovement(accountMovement.accountTransactionEntity,
                                                      in: accountMovements,
                                                      for: accountMovement.accountEntity)
    }
    
    func handleCardSelection(at index: Int, groupedBy productId: String?) {
        
        var filteredCardMovements: [CardTransactionWithCardEntity]?
        var selectedCardMovement: CardTransactionWithCardEntity?
            
        if let valueToCompare = productId {
            // Get only movements with the same productIdentifier and select the position from all the filtered movements
            filteredCardMovements = useCaseOutput?.cardsMovements.filter({ (model) -> Bool in
                model.cardEntity.productIdentifier == valueToCompare
            })
            selectedCardMovement = (index < filteredCardMovements?.count ?? 0) ? filteredCardMovements?[index] : nil
            
        } else {
            // Get all movements and select the position from all the searched movements
            filteredCardMovements = useCaseOutput?.cardsMovements
            selectedCardMovement = (index < self.resultMovements?.count ?? 0) ? self.resultMovements?[index].movement.entity as? CardTransactionWithCardEntity : nil
        }
            
        guard let cardMovements = filteredCardMovements,
            let cardMovement = selectedCardMovement
            else { return }
        globalSearchCoordinator.didSelectCardMovement(cardMovement.cardTransactionEntity,
                                                      in: cardMovements,
                                                      for: cardMovement.cardEntity)
    }
}

private enum GlobalSearchErrorAlerType: String {
    case bills = "deeplink_alert_errorBillTax"
    case transferts = "deeplink_alert_errorSend"
}

private struct SimplifiedMovement {
    let date: Date?
    let identifier: String
    let value: Decimal?
    
    init(date: Date?, identifier: String, value: Decimal?) {
        self.date = date
        self.identifier = identifier
        self.value = value
    }
}
