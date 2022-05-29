//
//  WhatsNewPresenter.swift
//  GlobalPosition
//
//  Created by Laura González on 24/06/2020.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

protocol WhatsNewPresenterProtocol: AnyObject {
    var view: WhatsNewViewProtocol? { get set }
    var pgDataManager: PGDataManagerProtocol? { get set }
    var viewModel: WhatsNewLastMovementsViewModel? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectOffer(_ viewModel: OfferBannerViewModel?)
    func didSelectPreconceivedBanner(_ viewModel: OfferBannerViewModel?)
    func didPressUpdate()
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel)
    func getBannerDate(_ viewModel: OfferBannerViewModel) -> String?
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel)
    func didSelectTimeLine()
    func didSelectSeeMoreMovements(_ section: LastMovementsConfiguration.FractionableSection)
    func showMovementDetailForItem(_ item: UnreadMovementItem)
    func getLimitsPreconceivedBanner()
    func isPreconceived() -> Bool
    func loadCandidatesOffersForViewModel(_ item: UnreadMovementItem)
    func trackPreconceivedBannerAppearance(offerId: String)
}

final class WhatsNewPresenter {
    weak var viewModel: WhatsNewLastMovementsViewModel?
    weak var view: WhatsNewViewProtocol?
    let dependenciesResolver: DependenciesResolver
    weak var pgDataManager: PGDataManagerProtocol?
    private var welcomeViewModel: WhatsNewWelcomeViewModel?
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var locations: [PullOfferLocation] = []
    private var lastMovementViewModel: WhatsNewLastMovementsViewModel?
    private var lastBillList = LastBillList()
    private var accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]]?
    private var localizedDate: LocalizedDate
    private var lastMovementsViewModels: WhatsNewLastMovementsViewModel?
    private var isUserPreconceived: Bool = false
    private let futureBillsMaxElements: Int = 5
    
    private weak var globalPositionModuleCoordinator: GlobalPositionModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    
    private var loginDateUseCase: GetLastLoginDateUseCase {
        return dependenciesResolver.resolve(for: GetLastLoginDateUseCase.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var appVersionUseCase: GetAppVersionUseCase {
        return dependenciesResolver.resolve(for: GetAppVersionUseCase.self)
    }
    
    private var getPreconceivedBannerUseCase: GetPreconceivedBannerUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var getUserCampaignsUseCase: GetUserCampaignsUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var delegate: GlobalPositionModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    
    private var pendingPresenter: PendingSolicitudesPresenterProtocol? {
        return dependenciesResolver.resolve(for: PendingSolicitudesPresenterProtocol.self)
    }
    
    lazy var getFutureBillSuperUseCase: GetFutureBillSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetFutureBillSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    var whatsNewCoordinator: WhatsNewCoordinator {
        return dependenciesResolver.resolve(for: WhatsNewCoordinator.self)
    }
    
    var whatsNewCoordinatorDelegate: WhatsNewCoordinatorDelegate {
        return dependenciesResolver.resolve(for: WhatsNewCoordinatorDelegate.self)
    }
    
    var globalPositionV2UseCase: GetGlobalPositionV2UseCase {
        return dependenciesResolver.resolve(for: GetGlobalPositionV2UseCase.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var pullOffersInterpreter: PullOffersInterpreter {
        return dependenciesResolver.resolve(for: PullOffersInterpreter.self)
    }
    
    private lazy var dataManager: WhatsNewDataManager = {
        return WhatsNewDataManager(resolver: dependenciesResolver)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.locations = PullOffersLocationsFactoryEntity().whatsNew
        localizedDate = LocalizedDate(dependenciesResolver: dependenciesResolver)
    }
    
    func dateSimpleFormat(_ date: Date) -> String {
        guard let dateString = dependenciesResolver.resolve(for: TimeManager.self)
                .toString(date: date, outputFormat: .HHmm)
        else { return "" }
        return dateString
    }
    
    func dateLongFormat(_ date: Date) -> String {
        guard let dateString = dependenciesResolver.resolve(for: TimeManager.self)
                .toString(date: date, outputFormat: .dd_MM_yyyy_HHmm)
        else { return "" }
        return dateString
    }
    
    func dateShortFormat(_ date: Date) -> String {
        guard let dateString = dependenciesResolver.resolve(for: TimeManager.self)
                .toString(date: date, outputFormat: .dd_MMM_yy)
        else { return "" }
        return dateString
    }
    
    func dateWeekFormat(_ date: Date) -> String {
        guard let dateString = dependenciesResolver.resolve(for: TimeManager.self)
                .toString(date: date, outputFormat: .eeee_HHmm)?.camelCasedString
        else { return "" }
        return dateString
    }
    
    func getLoginDate() {
        Scenario(useCase: loginDateUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                guard let userLoginDate = response.lastLoginInfoEntity?.lastConnection else {
                    self.welcomeViewModel = WhatsNewWelcomeViewModel.emptyModel
                    self.welcomeViewModel?.setUserName(userName: response.alias)
                    self.view?.setNewWelcomeViewModel(self.welcomeViewModel)
                    return
                }
                self.view?.showWelcomeView()
                self.welcomeViewModel = WhatsNewWelcomeViewModel(
                    loginDate: userLoginDate,
                    dateSimpleString: self.dateSimpleFormat(userLoginDate),
                    dateLongString: self.dateLongFormat(userLoginDate),
                    dateWeekString: self.dateWeekFormat(userLoginDate))
                self.welcomeViewModel?.setUserName(userName: response.alias)
                self.view?.setNewWelcomeViewModel(self.welcomeViewModel)
            }
            .finally {
                self.loadUnreadMovements()
            }
    }
    
    func needsUpgrade(_ currentVersion: String, minVersion: String) -> Bool {
        return currentVersion.compare((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""),
                                      options: .numeric) == .orderedDescending
            && UIDevice.current.systemVersion.compare(minVersion, options: .numeric) != .orderedAscending
    }
    
    func setPreconceivedBanner(_ maxAmount: Int) {
        self.view?.showPreconceived(true)
        let amount = Float(maxAmount)
        let viewModel = PreconceivedBannerViewModel(amount: amount)
        self.view?.setPreconceivedBanner(viewModel)
    }
    
    func setNoPreconceivedBanner() {
        self.view?.showPreconceived(false)
    }

    func trackPreconceivedBannerAppearance(offerId: String) {
        self.trackEvent(.viewPromotion, parameters: [.offerId: offerId])
    }
}

private extension WhatsNewPresenter {
    func getAppVersion(_ completion: @escaping (AppVersionsInfoDTO) -> Void) {
        let useCase: GetAppVersionUseCase = self.dependenciesResolver.resolve(for: GetAppVersionUseCase.self)
        Scenario(useCase: useCase)
            .execute(on: useCaseHandler)
            .onSuccess { response in
                completion(response.appInfo)
            }
    }
}

private extension WhatsNewPresenter {
    func loadOffers() {
        let getPregrantedLimitsScenario: Scenario<Void, GetPregrantedLimitsUseCaseOkOutput, StringErrorOutput> = Scenario(useCase: getPreconceivedBannerUseCase)
        let getUserCampaignsScenario: Scenario<Void, GetUserCampaignsUseCaseOutput, StringErrorOutput> = Scenario(useCase: getUserCampaignsUseCase)
        let values: (isPreConceived: Bool, isInRobinsonList: Bool) = (false, false)
        MultiScenario(handledOn: dependenciesResolver.resolve(), initialValue: values)
            .addScenario(getPregrantedLimitsScenario) { (updatedValues, _, _) in
                updatedValues.isPreConceived = true
                self.isUserPreconceived = updatedValues.isPreConceived
            }
            .addScenario(getUserCampaignsScenario) { (updatedValues, output, _) in
                let robinsonUserCode = "2"
                let campaigns = output.campaigns
                let isInRobinsonList = campaigns.filter({ $0 == robinsonUserCode }).first != nil
                updatedValues.isInRobinsonList = isInRobinsonList
            }
            .asScenarioHandler()
            .onSuccess { [weak self] values in
                guard let self = self,
                      (values.isPreConceived && values.isInRobinsonList),
                      let offerDTO = self.pullOffersInterpreter.getOffer(offerId: WhatsNewLocations.preconceivedRobinson.rawValue)
                else {
                    return
                }
                let offerEntity = OfferEntity(offerDTO)
                let viewModel = OfferBannerViewModel(entity: offerEntity)
                self.view?.loadOfferBanners(.preconceivedRobinson, viewModel: viewModel)
            }
            .finally {
                self.setPullOfferCandidates(self.isUserPreconceived)
            }
    }
    
    func showLocation() {
        guard let offersCandidates = self.pullOfferCandidates
        else {
            return
        }
        offersCandidates.forEach { (location, offerEntity) in
            guard locations.first(where: {$0.stringTag == location.stringTag}) != nil,
                  let offerType = WhatsNewLocations(rawValue: location.stringTag)
            else {
                return
            }
            let viewModel = OfferBannerViewModel(entity: offerEntity)
            self.view?.loadOfferBanners(offerType, viewModel: viewModel)
        }
    }
    
    func setPullOfferCandidates(_ isPreConceived: Bool) {
        let updatedLocations = isPreConceived
            ? self.locations.filter({ $0.stringTag != WhatsNewLocations.noPreconceived.rawValue })
            : self.locations.filter({ $0.stringTag != WhatsNewLocations.preconceived.rawValue })
        let input = GetPullOffersUseCaseInput(locations: updatedLocations)
        Scenario(useCase: self.getPullOffersCandidatesUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.pullOfferCandidates = result.pullOfferCandidates
                self.showLocation()
            }
    }
    
    func setPendingViewPresenter() {
        guard let pendingPresenter = pendingPresenter else { return }
        pendingPresenter.setOffersLocations(PullOffersLocationsFactoryEntity().pendingRequestWhatsNew, key: WhatsNewPullOffers.contractsInbox)
        pendingPresenter.setWithRecovery(false)
        self.view?.setPendingRequestViewPresenter(pendingPresenter)
    }
}

extension WhatsNewPresenter: WhatsNewPresenterProtocol {
    func showMovementDetailForItem(_ item: UnreadMovementItem) {
        switch item.type {
        case .account:
            guard let transaction = lastMovementViewModel?.accountTransactionFromItem(item, isFractionable: item.isFractionable),
                  let transactionEntity = transaction.accountTransactionsWithAccountEntity?.accountTransactionEntity,
                  let accountEntity = transaction.accountTransactionsWithAccountEntity?.accountEntity,
                  let transactions = transaction.transactions else {
                return
            }
            globalPositionModuleCoordinator?.gotoAccountTransactionDetail(transactionEntity: transactionEntity,
                                                                          in: transactions,
                                                                          accountEntity: accountEntity)
        case .card:
            guard let transaction = lastMovementViewModel?.cardTransactionFromItem(item, isFractionable: item.isFractionable),
                  let transactionEntity = transaction.cardTransactionsWithAccountEntity?.cardTransactionEntity,
                  let cardEntity = transaction.cardTransactionsWithAccountEntity?.cardEntity,
                  let transactions = transaction.transactions else {
                return
            }
            globalPositionModuleCoordinator?.gotoCardTransactionDetail(transactionEntity: transactionEntity, in: transactions, cardEntity: cardEntity)
            
        }
    }
    
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel) {
        guard let bills = self.accountFutureBills?[futureBillViewModel.account] else { return }
        self.globalPositionModuleCoordinator?.didSelectFutureBill(futureBillViewModel.representable, in: bills, for: futureBillViewModel.account)
    }
    
    func didSelectTimeLine() {
        self.globalPositionModuleCoordinator?.didSelectTimeLine()
    }
    
    func viewDidLoad() {
        self.loadOffers()
        self.getLoginDate()
        self.setPendingViewPresenter()
        self.getAppVersion({ [weak self] (resp) in
            let versionsShorted = resp.versions.sorted {
                $0.key.compare($1.key, options: .numeric) == .orderedDescending
            }
            let currentVersion = versionsShorted.first?.key ?? ""
            let minVersion = versionsShorted.first?.value["minVersion"] ?? ""
            self?.view?.showUpdate(self?.needsUpgrade(currentVersion, minVersion: minVersion) ?? true)
        })
        self.loadBills()
        self.trackScreen()
        self.checkShowLoadingTips()
        self.loadUnreadMovements()
    }
    
    func setView(view: WhatsNewViewProtocol) {
        self.view = view
    }
    
    func didSelectDismiss() {
        self.whatsNewCoordinator.dismiss()
    }
    
    @objc func performDismis() {
        self.whatsNewCoordinator.dismiss()
    }
    
    func didSelectOffer(_ viewModel: OfferBannerViewModel?) {
        self.delegate?.didSelectOffer(viewModel?.offer)
    }

    func didSelectPreconceivedBanner(_ viewModel: OfferBannerViewModel?) {
        self.trackEvent(.selectContent, parameters: [.offerId: viewModel?.offer.id ?? ""])
        self.didSelectOffer(viewModel)
    }
    
    func didPressUpdate() {
        trackEvent(.updateApp, parameters: [:])
        globalPositionModuleCoordinator?.openAppStore()
    }
    
    func didSelectSeeMoreMovements(_ section: LastMovementsConfiguration.FractionableSection) {
        guard let models = lastMovementsViewModels else { return }
        self.whatsNewCoordinator.didSelectPayments(section, lastMovementsViewModel: models)
    }
    
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel) {
        self.pendingPresenter?.pendingRequestSelected(viewModel)
    }
    
    func getBannerDate(_ viewModel: OfferBannerViewModel) -> String? {
        guard let date = viewModel.offer.dto.product.endDateUTC else { return nil }
        return dateShortFormat(date)
    }
    
    func getLimitsPreconceivedBanner() {
        Scenario(useCase: getPreconceivedBannerUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.isUserPreconceived = true
                guard self.view?.isPreconceivedOfferCandidate() == true,
                      let amountLimit = response.loanBanner.amountLimit else {
                    self.setNoPreconceivedBanner()
                    return
                }
                self.setPreconceivedBanner(amountLimit)
            }
            .onError { _ in
                self.setNoPreconceivedBanner()
            }
    }
    
    func isPreconceived() -> Bool {
        return self.isUserPreconceived
    }
    
    func loadCandidatesOffersForViewModel(_ item: UnreadMovementItem) {
        let offerSelected: (OfferEntity?) -> Void = { offer in
            if let offer = offer {
                self.globalPositionModuleCoordinator?.didSelectOffer(offer)
            } else {
                self.showMovementDetailForItem(item)
            }
        }
        switch item.type {
        case .card:
            guard let transaction = self.lastMovementViewModel?.getCardTransaction(item) else { return }
            crossSellingManager.loadCardCandidatesOffersForViewModel(
                item,
                transaction: transaction,
                indexTag: item.crossSelling?.index ?? -1,
                completion: offerSelected
            )
        case .account:
            guard let transaction = lastMovementViewModel?.getAccountTransaction(item) else { return }
            crossSellingManager.loadAccountCandidatesOffersForViewModel(
                item,
                transaction: transaction,
                indexTag: item.crossSelling?.index ?? -1,
                completion: offerSelected
            )
        }
    }
}

extension WhatsNewPresenter: AutomaticScreenActionTrackable {
    var trackerPage: WhatsNewPage {
        WhatsNewPage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

private extension WhatsNewPresenter {
    var crossSellingManager: CrossSellingManager {
        return CrossSellingManager(dependenciesResolver: dependenciesResolver)
    }
    
    var getUnreadMovementsUseCase: GetUnreadMovementsUseCase {
        self.dependenciesResolver.resolve(firstTypeOf: GetUnreadMovementsUseCase.self)
    }
    
    func setReadAllMovement() {
        lastMovementViewModel?.allCardEntities.forEach({ (cardEntity) in
            dataManager.setReadAllForCardEntity(cardEntity)
        })
        lastMovementViewModel?.allAccountEntities.forEach({ (accountEntity) in
            dataManager.setReadAllForAccountEntity(accountEntity)
        })
    }
    
    func loadUnreadMovements() {
        let maxDaysWithoutSCA = Date().getDateByAdding(
            days: -89,
            ignoreHours: true
        )
        let requestValues = GetUnreadMovementsUseCaseInput(
            startDate: maxDaysWithoutSCA,
            limit: nil
        )
        let unreadCardUseCase = getUnreadMovementsUseCase
        Scenario(useCase: unreadCardUseCase, input: requestValues)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                self?.buildLastMovements(results: result)
                self?.setReadAllMovement()
            }
    }
    
    func buildLastMovements(results: GetUnreadMovementsUseCaseOkOutput) {
        guard let baseUrl = baseURLProvider.baseURL else { return }
        lastMovementsViewModels = WhatsNewLastMovementsViewModel(useCaseResponse: results, baseUrl: baseUrl)
        let viewModel = WhatsNewLastMovementsViewModel(useCaseResponse: results, baseUrl: baseUrl)
        viewModel.rebuildModel(firstFourMovements: true, fractionableSection: LastMovementsConfiguration.FractionableSection.lastMovements)
        lastMovementViewModel = viewModel
        self.view?.setLastMovementViewModel(viewModel)
        self.view?.setFractionableAccounts(viewModel)
        self.view?.setFractionableCards(viewModel)
        dataManager.setViewModel(viewModel)
        self.checkHideLoadingTips()
    }
    
    func checkShowLoadingTips() {
        view?.showTipLoading()
    }
    
    func checkHideLoadingTips() {
        self.view?.hideTipLoading()
    }
    
    func loadBills() {
        self.loadGlobalPositionV2 { [weak self] in
            self?.getFutureBillSuperUseCase.execute()
        }
    }
    
    func loadGlobalPositionV2(_ completion: @escaping() -> Void) {
        Scenario(useCase: self.globalPositionV2UseCase)
            .execute(on: dependenciesResolver.resolve())
            .finally(completion)
    }
}

extension WhatsNewPresenter: GetFutureBillSuperUseCaseDelegateDelegate {
    func didFinishFutureBillSuccessfully(with accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]]) {
        self.accountFutureBills = accountFutureBills
        let viewModels = futureBillsViewModels(for: accountFutureBills)
        if viewModels.isEmpty {
            self.view?.showFutureBillsEmpty()
        } else {
            self.view?.showFutureBills(viewModels)
        }
    }
    
    func futureBillsViewModels(for accountBills: [AccountEntity: [AccountFutureBillRepresentable]]) -> [FutureBillViewModel] {
        let viewModels = accountBills.flatMap { element in
            self.futureBillViewModel(for: element.key, bills: element.value)
        }.sorted(by: {$0.date < $1.date})
        return Array(viewModels.prefix(futureBillsMaxElements))
    }
    
    func futureBillViewModel(for account: AccountEntity, bills: [AccountFutureBillRepresentable]) -> [FutureBillViewModel] {
        return bills.map { FutureBillViewModel($0, account: account, localizedDate: localizedDate) }
    }
}
