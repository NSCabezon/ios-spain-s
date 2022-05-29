import Foundation
import CoreFoundationLib

protocol AccountSelectionNavigatorProtocol: OperativesNavigatorProtocol {
    func close()
}

protocol AccountSelectionDelegate: AnyObject {
    func didSelect(account: Account)
}

class AccountSelectionPresenter: ProductSelectionPresenter<Account, AccountSelectionNavigatorProtocol>, PresenterProgressBarCapable {
    
    weak var delegate: AccountSelectionDelegate?
    init(accounts: [Account], dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: AccountSelectionNavigatorProtocol) {
        super.init(
            products: accounts,
            titleKey: "toolbar_title_accountSearch",
            sectionTitleKey: "",
            dependencies: dependencies,
            sessionManager: sessionManager,
            navigator: navigator
        )
        self.barButtons = [.close]
    }
    
    var shouldShowProgress: Bool {
        return false
    }
    
    // MARK: - Overrided methods
    
    override func selected(index: Int) {
        delegate?.didSelect(account: products[index])
        navigator.close()
    }
    
    override func loadViewData() {
        super.loadViewData()
        let progress = Progress(totalUnitCount: 2)
        progress.completedUnitCount = 1
        view.setProgressBar(progress: progress)
    }
}

extension AccountSelectionPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        navigator.close()
    }
}
