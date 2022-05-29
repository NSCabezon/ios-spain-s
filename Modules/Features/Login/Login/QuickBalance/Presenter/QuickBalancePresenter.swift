import Foundation
import CoreFoundationLib
import LoginCommon

protocol QuickBalancePresenterProtocol: class {
    var view: QuickBalanceViewProtocol? { get set }
    func viewDidLoad()
    func didTapCloseButton()
    func didTapBackLoginButton()
    func didTapActivateButton()
    func didTapVideo()
    func didTapErrorViewButton()
    func didTapReloadButton()
    func didTapDeeplinkButton(_ action: QuickBalanceAction)
}

private enum QuickBalanceError {
    case scaTemporaryLock, scaRequestOtp, scaRequestOtpFirstTime, connection
}

final class QuickBalancePresenter {
    
    weak var view: QuickBalanceViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var coordinator: QuickBalanceCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: QuickBalanceCoordinatorProtocol.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var quickBalanceLoginUseCase: QuickBalanceLoginUseCase {
        return self.dependenciesResolver.resolve(for: QuickBalanceLoginUseCase.self)
    }
    private var quickBalanceAccountUseCase: QuickBalanceAccountUseCase {
        return self.dependenciesResolver.resolve(for: QuickBalanceAccountUseCase.self)
    }
    lazy private var quickBalanceTransactionsSuperUseCase: QuickBalanceTransactionsSuperUseCaseProtocol = {
        return QuickBalanceTransactionsSuperUseCase(delegate: self, useCaseHandler: self.useCaseHandler, dependenciesResolver: self.dependenciesResolver)
    }()
    private var pullOfferTutorialCandidatesUseCase: PullOfferTutorialCandidatesUseCase {
        return self.dependenciesResolver.resolve(for: PullOfferTutorialCandidatesUseCase.self)
    }
    private var amount: AmountEntity = AmountEntity.empty
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    private let numberOfDaysBack = -89
    private let maxTransactions = 10
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().quickBalanceVideo
    private let videoLocationKey = QuickBalancePullOffers.quickBalanceTutorialVideo
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private enum ButtonStatus {
        case enter
        case update
    }
    private var bottomButtonStatus = ButtonStatus.enter
    private enum ReloadType {
        case manual
        case automatic
    }
    private var reloadType: ReloadType = .automatic
}

private extension QuickBalancePresenter {
    func doLogin() {
        view?.showLoading()
        UseCaseWrapper(with: quickBalanceLoginUseCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] response in
            switch response {
            case .login(let data):
                self?.doPg(isPB: data.isPb)
            case .notTokenForLogin:
                self?.loadOffers()
            }
        }, onError: { [weak self] _ in
            self?.errorMessage(.connection)
        })
    }
    
    func doPg(isPB: Bool) {
        let input = QuickBalanceAccountUseCaseInput(isPb: isPB)
        let useCase = quickBalanceAccountUseCase.setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] response in
            switch response {
            case .globalPosition(let data):
                self?.amount = data.amount
                self?.doAccounts(accounts: data.accounts)
            case .scaTemporaryLock:
                self?.errorMessage(.scaTemporaryLock)
            case .scaRequestOtp:
                self?.errorMessage(.scaRequestOtp)
            case .scaRequestOtpFirstTime:
                self?.errorMessage(.scaRequestOtpFirstTime)
            }
        }, onError: { [weak self] _ in
            self?.errorMessage(.connection)
        })
    }
    
    func doAccounts(accounts: [AccountEntity]) {
        quickBalanceTransactionsSuperUseCase.getAccounts(accounts: accounts)
    }
    
    func errorMessage(_ type: QuickBalanceError) {
        self.view?.hideLoading()
        var viewModel: QuickBalanceErrorViewModel!
        switch type {
        case .connection:
            viewModel = QuickBalanceErrorViewModel(errorTitle: "", stylableErrorTitle: localized("product_title_emptyError"), errorDescription: localized("widget_label_errorConexion"), titleButton: localized("quickBalance_button_update"))
            bottomButtonStatus = .update
        case .scaRequestOtp:
            viewModel = QuickBalanceErrorViewModel(errorTitle: "", errorDescription: localized("widget_text_viewBalance90"), titleButton: localized("login_button_enter"))
            bottomButtonStatus = .enter
        case .scaRequestOtpFirstTime:
            viewModel = QuickBalanceErrorViewModel(errorTitle: "", errorDescription: localized("quickBalance_text_displayBalance"), titleButton: localized("login_button_enter"))
            bottomButtonStatus = .enter
        case .scaTemporaryLock:
            viewModel = QuickBalanceErrorViewModel(errorTitle: "", stylableErrorTitle: localized("otpSCA_alert_title_blocked"), errorDescription: localized("widget_text_blocked"), titleButton: localized("login_button_enter"))
            bottomButtonStatus = .enter
        default:
            viewModel = QuickBalanceErrorViewModel(errorTitle: "", stylableErrorTitle: localized("product_title_emptyError"), errorDescription: localized("widget_label_errorConexion"), titleButton: localized("quickBalance_button_update"))
            bottomButtonStatus = .update
        }
        let event: QuickBalancePage.Action = reloadType == .automatic ? .errorAuto : .errorManual
        trackEvent(event, parameters: [:])
        view?.showError(viewModel)
    }
    
    func lastUpdate() -> String {
        let time = timeManager.toString(date: Date(), outputFormat: .dd_MMMM_yyyy_comma_HHmm, timeZone: .local) ?? ""
        return localized("quickBalance_label_update", [StringPlaceholder(.date, time)]).text
    }
    
    func formattedMovementDate(_ date: Date) -> String {
        timeManager.toString(date: date, outputFormat: .dd_7_MM, timeZone: .local) ?? ""
    }
    
    func formattedAccountAlias(_ account: AccountEntity) -> String {
        let alias = account.alias ?? ""
        let shortIBAN = account.getIBANShort
        return alias + " | " + shortIBAN
    }
    
    func loadOffers() {
        let input = PullOfferTutorialCandidatesUseCaseInput(locations: locations)
        let useCase = pullOfferTutorialCandidatesUseCase.setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] result in
            self?.pullOfferCandidates = result.candidates
            self?.showLocation()
        })
    }
    
    func showLocation() {
        view?.hideLoading()
        trackEvent(.notActivated, parameters: [:])
        if self.pullOfferCandidates?.contains(location: self.videoLocationKey) == true {
            self.view?.showNotActivatedViewWithVideoEnabled(true)
        } else {
            self.view?.showNotActivatedViewWithVideoEnabled(false)
        }
    }
    
    private func finishActions(_ accountTransactions: [AccountTransactionWithAccountEntity]) {
        let header = QuickBalanceHeaderViewModel(title: localized("widget_label_balance").text, balance: self.amount, updatedDate: lastUpdate())
        let movements = accountTransactions.map {
            QuickBalanceMovementViewModel(date: formattedMovementDate($0.accountTransactionEntity.operationDate ?? Date()), movement: $0.accountTransactionEntity.alias ?? "", amount: $0.accountTransactionEntity.amount ?? AmountEntity.empty, account: formattedAccountAlias($0.accountEntity))
        }
        if movements.isEmpty {
            bottomButtonStatus = .enter
        }
        let event: QuickBalancePage.Action = reloadType == .automatic ? .okAuto : .okManual
        trackEvent(event, parameters: [:])
        self.view?.showMovements(headerViewModel: header, movementViewModels: movements)
    }
}

// MARK: - QuickBalancePresenterProtocol
extension QuickBalancePresenter: QuickBalancePresenterProtocol {
    func viewDidLoad() {
        doLogin()
        trackScreen()
        trackEvent(.autoReload, parameters: [:])
    }
    
    func didTapCloseButton() {
        self.coordinator.didSelectDismiss()
    }
    
    func didTapBackLoginButton() {
        self.coordinator.didSelectDismiss()
    }

    func didTapActivateButton() {
        trackEvent(.enable, parameters: [:])
        self.view?.showTopAlert(text: localized("login_alert_activateQuickBalance"))
        self.didSelectDeeplink(QuickBalanceAction.securitySettings.rawValue)
    }
    
    func didTapVideo() {
        trackEvent(.video, parameters: [:])
        let videoLocation = self.locations.first { $0.stringTag == self.videoLocationKey }
        guard let location = videoLocation else { return }
        guard let offer = self.pullOfferCandidates?[location] else { return }
        coordinator.didSelectOffer(offer, location: location)
    }
    
    func didTapErrorViewButton() {
        switch bottomButtonStatus {
        case .enter:
            coordinator.didSelectDismiss()
        case .update:
            doLogin()
        default:
            break
        }
    }
    
    func didTapReloadButton() {
        trackEvent(.manualReload, parameters: [:])
        reloadType = .manual
        doLogin()
    }
    
    func didTapDeeplinkButton(_ action: QuickBalanceAction) {
        trackEvent(.deeplink, parameters: [.deeplinkLogin: action.rawValue])
        switch action {
        case .bizum: trackEvent(.bizum, parameters: [:])
        case .cardPin: trackEvent(.pin, parameters: [:])
        case .cardTurnOff: trackEvent(.cardOff, parameters: [:])
        case .sendMoney: trackEvent(.sendMoney, parameters: [:])
        case .securitySettings: trackEvent(.security, parameters: [:])
        }
        self.view?.showTopAlert(text: localized("login_alert_operationalAccess"))
        self.didSelectDeeplink(action.rawValue)
    }
}

extension QuickBalancePresenter: QuickBalanceTransactionsSuperUseCaseDelegate {
    func finish(accountTransactions: [AccountTransactionWithAccountEntity]) {
        self.view?.hideLoading()
        guard !accountTransactions.isEmpty,
              accountTransactions.count > maxTransactions else {
            finishActions(accountTransactions)
            return
        }
        let accountTransactionsFiltered: [AccountTransactionWithAccountEntity] = accountTransactions.prefix(upTo: maxTransactions).filter({ ($0.accountTransactionEntity.operationDate ?? Date()) > Date().getDateByAdding(days: numberOfDaysBack) })
        finishActions(accountTransactionsFiltered)
    }
}

extension QuickBalancePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: QuickBalancePage {
        return QuickBalancePage()
    }
}

private extension QuickBalancePresenter {
    func didSelectDeeplink(_ identifier: String) {
        self.coordinator.didSelectDeeplink(identifier)
    }
}
