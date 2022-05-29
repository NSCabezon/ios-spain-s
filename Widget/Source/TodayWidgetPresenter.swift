import Foundation
import CoreFoundationLib
import Localization
import RetailLegacy

enum WidgetSection {
    case message(WidgetMessageLabelDataProviderProtocol)
    case transactionList(WidgetAccountInfoDataProviderProtocol)
}

struct DataSnapshot: Codable {
    var lastUpdate: Date?
    var totalAmount: String?
    var transactions: [WidgetRow]?
    var username: String?
    var loginType: String?
}

protocol TodayWidgetNavigatorProtocol {
    var context: NSExtensionContext? { get set }
    func openURL(_ url: URL?)
}

final class TodayWidgetPresenter {
    lazy var currentSection: WidgetSection = .message(self)
    var onUpdate: ((WidgetSection) -> Void)?
    private var isWaitingForData = false {
        didSet {
            onUpdate?(currentSection)
        }
    }
    private var isAuto: Bool = true
    private var lastDataSnapshot: DataSnapshot?
    private var requestingDataSnapshot = DataSnapshot()
    private var maxTransactions: Int { 5 }
    private var numberOfDaysBack: Int { -89 }
    private var currentMessageLayout: MessageLayout? = .processingData
    private lazy var navigator: TodayWidgetNavigatorProtocol = {
        return WidgetNavigatorProvider.todayWidgetNavigator
    }()
    private var localeManager: TimeManager & StringLoader {
        return WidgetDependencies.localeManager
    }
    
    private lazy var accountTransactionsSuperUseCase: WidgetAccountsTransactionsSuperUseCaseProtocol = {
        return WidgetDependencies.accountTransactionsUseCase(delegate: self)
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: StringLoaderNotifications.languageDidChange, object: nil)
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: StringLoaderNotifications.languageDidChange, object: nil)
        if isBiometryAvailable {
            loadCacheIfValid()
        }
        NumberFormattingHandler.shared.setup(dependenciesResolver: DependenciesDefault())
    }
    
    @objc func languageDidChange() {
        onUpdate?(currentSection)
    }
    
    private func doLogin(auto: Bool) {
        isAuto = auto
        if auto {
            WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.autoRecharge.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
        } else {
            WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.manualRechare.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
        }
        isWaitingForData = true
        UseCaseWrapper(
            with: WidgetDependencies.loginUseCase,
            useCaseHandler: WidgetDependencies.usecaseHandler,
            errorHandler: nil,
            includeAllExceptions: true
        ) { [weak self] response in
            switch response {
            case .login(let isPb, let username, let loginType):
                self?.requestingDataSnapshot = DataSnapshot()
                self?.requestingDataSnapshot.loginType = loginType
                self?.requestingDataSnapshot.username = username
                self?.doPg(isPb: isPb)
            case .notTokenForLogin:
                guard let strongSelf = self else { return }
                WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.noActivated.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
                strongSelf.currentMessageLayout = .activateWidget
                strongSelf.currentSection = .message(strongSelf)
                self?.isWaitingForData = false
            }
        } onError: { [weak self] _ in
            self?.displayCacheIfAvailable()
        }
    }
    
    private func scaMessage(messageLayout: MessageLayout) {
        lastDataSnapshot = nil
        currentMessageLayout = messageLayout
        currentSection = .message(self)
        isWaitingForData = false
    }
    
    private func doPg(isPb: Bool) {
        let input = WidgetAccountUseCaseInput(isPb: isPb)
        let usecase = WidgetDependencies.accountsUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: WidgetDependencies.usecaseHandler, errorHandler: nil, includeAllExceptions: true, onSuccess: { [weak self] response in
            switch response {
            case .globalPossition(let amount, let accounts):
                self?.requestingDataSnapshot.totalAmount = amount.getFormattedAmountUIWith1M()
                self?.doAccounts(accounts: accounts)
            case .scaTemporaryLock:
                self?.scaMessage(messageLayout: .scaTemporaryLock)
            case .scaRequestOtp:
                self?.scaMessage(messageLayout: .scaRequestOtp)
            case .scaRequestOtpFirstTime:
                self?.scaMessage(messageLayout: .scaRequestOtpFirstTime)
            }
        }, onError: { [weak self] _ in
            self?.displayCacheIfAvailable()
        })
    }
    
    private func doAccounts(accounts: [Account]) {
        accountTransactionsSuperUseCase.getAccounts(accounts: accounts)
    }
    
    private func checkUser(name: String, type: String, completion: @escaping (_ response: WidgetUserUseCaseOkOutput) -> Void) {
        let input = WidgetUserUseCaseInput(username: name, loginType: type)
        let usecase = WidgetDependencies.userUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: WidgetDependencies.usecaseHandler,
            errorHandler: nil,
            includeAllExceptions: true
        ) { response in
            completion(response)
        } onError: { _ in
            completion(.notUserToken)
        }
    }
    
    private func displayCacheIfAvailable() {
        if lastDataSnapshot != nil {
            currentSection = .transactionList(self)
        } else {
            if isAuto {
                WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.autoError.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
            } else {
                WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.manualError.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
            }
            currentMessageLayout = .networkError
            currentSection = .message(self)
        }
        isWaitingForData = false
    }
    
    private func saveDataSnapshot(dataSnapshot: DataSnapshot) {
        let input = WidgetSetDataSnapshotUseCaseInput(dataSnapshot: dataSnapshot)
        let usecase = WidgetDependencies.setDataSnapshotUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: WidgetDependencies.usecaseHandler, errorHandler: nil)
    }
    
    private func getDataSnapshot(completion: @escaping (_ dataSnapshot: DataSnapshot?) -> Void) {
        let usecase = WidgetDependencies.getDataSnapshotUseCase
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: WidgetDependencies.usecaseHandler,
            errorHandler: nil,
            includeAllExceptions: true
        ) { response in
            completion(response.dataSnapshot)
        } onError: { _ in
            completion(nil)
        }
    }
    
    private enum UserState {
        case okUser(data: DataSnapshot)
        case notTokenForLogin
        case notUserToken
    }
    
    private func loadCacheIfValid() {
        getDataSnapshot { [weak self] dataSnapshot in
            if let lastStoredData = dataSnapshot, let user = lastStoredData.username, let loginType = lastStoredData.loginType {
                self?.checkUser(name: user, type: loginType, completion: { [weak self] response in
                    let state: UserState
                    switch response {
                    case .okUser:
                        state = .okUser(data: lastStoredData)
                    case .notTokenForLogin:
                        state = .notTokenForLogin
                    case .notUserToken:
                        state = .notUserToken
                    }
                    self?.processUserResponse(state: state)
                })
            } else {
                self?.processUserResponse(state: .notTokenForLogin)
            }
        }
    }
    
    private func processUserResponse(state: UserState) {
        switch state {
        case .okUser(let data):
            lastDataSnapshot = data
            let now = Date()
            if let date = data.lastUpdate, now.timeIntervalSince(date) < 60*60*24 {
                displayCacheIfAvailable()
            } else {
                displayCacheIfAvailable()
                doLogin(auto: true)
            }
        case .notUserToken:
            lastDataSnapshot = nil
            currentMessageLayout = .activateWidget
            currentSection = .message(self)
            isWaitingForData = false
        case .notTokenForLogin:
            lastDataSnapshot = nil
            currentMessageLayout = .processingData
            currentSection = .message(self)
            doLogin(auto: true)
        }
    }
}

extension TodayWidgetPresenter: WidgetAccountsTransactionsSuperUseCaseDelegate {
    func finish(accountTransactions: [AccountTransaction]) {
        if isAuto {
            WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.autoOK.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
        } else {
            WidgetDependencies.trackerManager.trackEvent(screenId: TrackerPageWidget.Action.manualOk.rawValue, eventId: TrackerPageWidget.page, extraParameters: [:])
        }
        var transactions: [WidgetRow] = [.title("widget_label_lastMovements")]
        guard !accountTransactions.isEmpty else {
            transactions.append(.message("widget_label_notAvailableMoves"))
            finishActions(transactions: transactions)
            return
        }
        let accountTransactions: [AccountTransaction] = accountTransactions.prefix(upTo: maxTransactions).filter({ ($0.operationDate ?? Date()) > Date().getDateByAdding(days: numberOfDaysBack) })
        if !accountTransactions.isEmpty {
            var lastTransactionDate: Date?
            for transaction in accountTransactions {
                var operationDate: Date?
                if transaction.operationDate != lastTransactionDate {
                    operationDate = transaction.operationDate
                }
                lastTransactionDate = transaction.operationDate
                transactions.append(.transaction(date: operationDate, title: transaction.description?.camelCasedString ?? "", amount: transaction.amount.getFormattedAmountUI()))
            }
            transactions.append(.lineMessage("widget_text_accessMoreTransactions"))
        } else {
            transactions.append(.message("widget_label_notAvailableMoves"))
        }
        finishActions(transactions: transactions)
    }
    
    private func finishActions(transactions: [WidgetRow]) {
        requestingDataSnapshot.lastUpdate = Date()
        requestingDataSnapshot.transactions = transactions
        saveDataSnapshot(dataSnapshot: requestingDataSnapshot)
        lastDataSnapshot = requestingDataSnapshot
        currentSection = .transactionList(self)
        isWaitingForData = false
    }
}

extension TodayWidgetPresenter: WidgetAccountInfoDataProviderProtocol {
    
    func updateData() {
        doLogin(auto: false)
        onUpdate?(currentSection)
    }
    
    func rows() -> [WidgetRowInfo] {
        return lastDataSnapshot?.transactions?.map({
            switch $0 {
            case let .message(key):
                let text = localeManager.getString(key).text
                return WidgetRowInfo.message(text)
            case let .title(key):
                let text = localeManager.getString(key).text
                return WidgetRowInfo.title(text)
            case let .transaction(date: date, title: title, amount: amount):
                var day: String?
                var month: String?
                if let date = date {
                    day = localeManager.toString(date: date, outputFormat: .d)?.uppercased()
                    month = localeManager.toString(date: date, outputFormat: .MMM)?.uppercased()
                }
                return WidgetRowInfo.transaction(day: day, month: month, title: title, amount: amount)
            case let .lineMessage(key):
                let text = localeManager.getString(key).text
                return WidgetRowInfo.lineMessage(text)
            }
        }) ?? []
    }
    
    var accountTitle: String? {
        return localeManager.getString("widget_label_balance").text
    }
    
    var amountAvailable: String? {
        return lastDataSnapshot?.totalAmount
    }
    
    var currentState: String? {
        return localeManager.getString("widget_label_update_ios", [StringPlaceholder(.date, lastUpdate ?? "")]).text
    }
    
    private var lastUpdate: String? {
        return localeManager.toString(date: lastDataSnapshot?.lastUpdate, outputFormat: .dd_MMM_yyyy_HHmm, timeZone: .local)
    }
}

extension TodayWidgetPresenter: TodayWidgetPresenterProtocol {
    
    enum DeeplinkOption: CaseIterable {
        case bizum
        case transfers
        case pinQuery
        case turnOffCard
        
        var data: (String, String) {
            switch self {
            case .bizum:
                return ("toolbar_title_bizum", "icnBizum")
            case .pinQuery:
                return ("toolbar_title_seePin", "icnPin")
            case .transfers:
                return ("toolbar_title_onePay", "icnTransfers")
            case .turnOffCard:
                return ("toolbar_button_turnOff", "icnOff")
            }
        }
        
        var url: URL? {
            return URL(string: "santanderretail://action?n=\(deepLink)")
        }
        
        var deepLink: String {
            switch self {
            case .bizum:
                return "bizum"
            case .pinQuery:
                return "tarpin"
            case .transfers:
                return "thab"
            case .turnOffCard:
                return "taroff"
            }
        }
    }
    
    var deeplinkOptions: [WidgetButtonData] {
        return DeeplinkOption.allCases.map({(localeManager.getString($0.data.0).text, $0.data.1)})
    }
    
    var isBiometryAvailable: Bool {
        let appEventsNotifier = AppEventsNotifier()
        let localAuthentication = KeychainAuthentication(appEventsNotifier: appEventsNotifier)
        if case .none = localAuthentication.availableType {
            return false
        } else if case .error(_, let error) = localAuthentication.availableType {
            return error != .biometryNotAvailable
        }
        return true
    }
    
    func didPressDeeplink(_ position: Int) {
        WidgetDependencies.trackerManager.trackEvent(
            screenId: TrackerPageWidget.page,
            eventId: TrackerPageWidget.Action.deeplink.rawValue,
            extraParameters: [
                TrackerDimensions.deeplinkLogin: DeeplinkOption.allCases[position].deepLink
            ]
        )
        navigator.openURL(DeeplinkOption.allCases[position].url)
    }
    
    func didPressOpenApp() {
        navigator.openURL(URL(string: "santanderretail://action?n=open"))
    }
    
    func configure(context: NSExtensionContext?) {
        navigator.context = context
    }
    
}

extension TodayWidgetPresenter: RefreshCapable {
    
    var refresh: RefreshType {
        guard case .transactionList = currentSection else {
            return isWaitingForData ? .loading : .available
        }
        if case RefreshType.available? = currentMessageLayout?.refresh {
            return isWaitingForData ? .loading : .available
        }
        return .notAvailable
    }
}

extension TodayWidgetPresenter: WidgetMessageLabelDataProviderProtocol {
    
    enum MessageLayout {
        case activateWidget
        case noBiometry
        case networkError
        case processingData
        case scaTemporaryLock
        case scaRequestOtp
        case scaRequestOtpFirstTime
        
        var refresh: RefreshType {
            switch self {
            case .activateWidget, .noBiometry, .scaTemporaryLock, .scaRequestOtp, .scaRequestOtpFirstTime:
                return .notAvailable
            case .networkError, .processingData:
                return .available
            }
        }
        
        var actionMessage: String? {
            switch self {
            case .activateWidget, .scaTemporaryLock, .scaRequestOtp, .scaRequestOtpFirstTime:
                return "widget_button_access"
            case .noBiometry, .networkError, .processingData:
                return nil
            }
        }
        
        var message: String {
            switch self {
            case .activateWidget:
                return "widget_label_configPersonalArea"
            case .noBiometry:
                return "widget_label_unsupportable"
            case .networkError:
                return "widget_label_errorConexion"
            case .processingData:
                return "widget_label_errorLoading"
            case .scaTemporaryLock:
                return "widget_text_blocked"
            case .scaRequestOtp:
                return "widget_text_viewBalance90"
            case .scaRequestOtpFirstTime:
                return "widget_text_viewBalance"
            }
        }
        
        var isActionAvailable: Bool {
            switch self {
            case .activateWidget, .scaTemporaryLock, .scaRequestOtp, .scaRequestOtpFirstTime:
                return true
            case .noBiometry, .networkError, .processingData:
                return false
            }
        }
    }
    
    var message: String? {
        guard let key = currentMessageLayout?.message else { return nil }
        return localeManager.getString(key).text
    }
    
    var actionMessage: String? {
        guard let key = currentMessageLayout?.actionMessage else { return nil }
        return localeManager.getString(key).text
    }
    
    var isActionAvailable: Bool {
        return currentMessageLayout?.isActionAvailable ?? false
    }
    
    func actionPressed() {
        navigator.openURL(URL(string: "santanderretail://action?n=secset"))
    }
}

// swiftlint:disable identifier_name
enum WidgetRow: Codable {
    case title(String)
    case transaction(date: Date?, title: String, amount: String)
    case message(String)
    case lineMessage(String)
    
    private enum CodingKeys: String, CodingKey {
        case title
        case transaction_date
        case transaction_title
        case transaction_amount
        case message
        case lineMessage
    }
    
    enum WidgetRowCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .title) {
            self = .title(value)
        } else if let value = try? values.decode(String.self, forKey: .message) {
            self = .message(value)
        } else if let title = try? values.decode(String.self, forKey: .transaction_title), let amount = try? values.decode(String.self, forKey: .transaction_amount) {
            let date = try? values.decode(Date.self, forKey: .transaction_date)
            self = .transaction(date: date, title: title, amount: amount)
        } else {
            throw WidgetRowCodingError.decoding("Error \(dump(values))")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .title(let value):
            try container.encode(value, forKey: .title)
        case .message(let value):
            try container.encode(value, forKey: .message)
        case .transaction(let date, let title, let amount):
            if let date = date {
                try container.encode(date, forKey: .transaction_date)
            }
            try container.encode(title, forKey: .transaction_title)
            try container.encode(amount, forKey: .transaction_amount)
        case .lineMessage(let value):
            try container.encode(value, forKey: .lineMessage)
        }
    }
}
// swiftlint:enable identifier_name
