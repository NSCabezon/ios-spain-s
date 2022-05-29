import UIKit
import Transfer
import UI
import CoreFoundationLib

protocol OnePayAccountSelectorPresenterProtocol: Presenter, TransferAccountSelectorPresenterProtocol {
    var dependenciesResolver: DependenciesResolver { get }
    func didTapBack()
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

class OnePayAccountSelectorViewController: BaseViewController<OnePayAccountSelectorPresenterProtocol> {
    
    weak var accountSelectorViewController: TransferAccountSelectorViewController!
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .skyGray
    }
    
    override func prepareView() {
        super.prepareView()
        let accountSelectorViewController = TransferAccountSelectorViewController(presenter: presenter)
        presenter.selectorView = accountSelectorViewController
        self.view.addSubview(accountSelectorViewController.view)
        accountSelectorViewController.view.translatesAutoresizingMaskIntoConstraints = false
        accountSelectorViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        accountSelectorViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        accountSelectorViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        accountSelectorViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(accountSelectorViewController)
        accountSelectorViewController.didMove(toParent: self)
        self.accountSelectorViewController = accountSelectorViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_originAccount",
                                    header: .title(key: "toolbar_title_moneyTransfers", style: .default))
        )
        builder.setLeftAction(
            .back(action: #selector(didTapBack))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapBack() {
        presenter.didTapBack()
    }
    
    @objc func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension OnePayAccountSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension OnePayAccountSelectorViewController: TransferAccountSelectorViewProtocol {
    var associatedLoadingView: UIViewController {
        return self.accountSelectorViewController
    }
    
    func showAccounts(accountVisibles: [TransferAccountItemViewModel], accountNotVisibles: [TransferAccountItemViewModel]) {
        self.accountSelectorViewController.showAccounts(accountVisibles: accountVisibles, accountNotVisibles: accountNotVisibles)
    }
}

private extension OnePayTransferSelectorViewController {
    var dependenciesResolver: DependenciesResolver {
        return self.presenter.dependenciesResolver
    }
}
