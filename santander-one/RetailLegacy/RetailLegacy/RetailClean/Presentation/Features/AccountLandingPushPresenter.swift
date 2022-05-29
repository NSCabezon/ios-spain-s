import Foundation
import CoreFoundationLib

struct GenericLandingOption: GenericLandingPushOptionType {
    var title: LocalizedStylableText
    var imageKey: String
    var action: (() -> Void)?
    
    func execute() {
        action?()
    }
}

enum GenericLandingInfoLineType {
    case title(LocalizedStylableText)
    case line(String?, String?)
    case itemAndColumnTitle(String, LocalizedStylableText)
    case itemAndAmount(String?, String?)
}

class AccountLandingPushPresenter: PrivatePresenter<GenericLandingPushViewController, GenericLandingPushNavigatorProtocol, GenericLandingPushPresenterProtocol>, Presenter {
    
    private let accountPushInfo: AccountLandingPushData
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }
    
    override var screenId: String? {
        return accountPushInfo.screenId
    }
    
    init(accountPushInfo: AccountLandingPushData, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: GenericLandingPushNavigatorProtocol) {
        self.accountPushInfo = accountPushInfo
        accountPushInfo.navigator = navigator
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        setupHeaderInfo()
        view.setOptions(
            accountPushInfo.createLandingOptions { [weak self] in
                self?.view.dismiss(animated: true)
            }
        )
    }
    
    private func setupHeaderInfo() {
        view.setDetail(accountPushInfo.headerModel())
    }
    
}

extension AccountLandingPushPresenter: GenericLandingPushPresenterProtocol {
    
    var mainOption: LocalizedStylableText {
        return stringLoader.getString("landingPush_buttom_openApp")
    }
    
    func closePressed() {
        view.dismiss(animated: true)
    }
    
    func didPressMainOption() {
        view.dismiss(animated: true)
    }
}
