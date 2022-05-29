import UIKit
import UI
import Transfer
import Operative
import CoreFoundationLib

protocol TransferConfirmationPresenterProtocol: Presenter, TransferConfirmPresenterProtocol {
    func didTapBack()
    func didTapClose()
    func didTapFaqs()
    func trackFaqEvent(_ question: String, url: URL?)
}

class TransferConfirmationViewController: BaseViewController<TransferConfirmationPresenterProtocol> {
    weak var transferConfirmViewController: TransferConfirmViewController!
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .clear
    }
    
    
    override func prepareView() {
        super.prepareView()
        let viewController = TransferConfirmViewController(presenter: presenter, dependenciesResolver: self.dependenciesResolver)
        self.presenter.subView = viewController
        self.view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(viewController)
        viewController.didMove(toParent: self)
        self.transferConfirmViewController = viewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "genericToolbar_title_confirmation",
                                    header: .title(key: "toolbar_title_moneyTransfers", style: .default))
        )
        builder.setLeftAction(.back(action: #selector(didTapBack)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapBack() {
        presenter.didTapBack()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension TransferConfirmationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension TransferConfirmationViewController: TransferConfirmViewProtocol {
    func showInvalidEmail(_ error: String) {

    }

    var email: String? {
        self.transferConfirmViewController.email
    }
    
    func add(_ confirmationItems: [ConfirmationItemViewModel]) {
        self.transferConfirmViewController.add(confirmationItems)
    }
    
    func add(_ confirmationItem: ConfirmationItemViewModel) {
        self.transferConfirmViewController.add(confirmationItem)
    }
    
    func setContinueTitle(_ text: String) {
        self.transferConfirmViewController.setContinueTitle(text)
    }
    
    func addTotalOperationAmount(_ amount: AmountEntity) {
        self.transferConfirmViewController.addTotalOperationAmount(amount)
    }
    
    func addText(_ text: String) {
        self.transferConfirmViewController.addText(text)
    }
    
    func addEmail() {
        self.transferConfirmViewController.addEmail()
    }

    func addBiometricValidationButton() {
        self.transferConfirmViewController.addBiometricValidationButton()
    }
    
    var associatedDialogView: UIViewController {
        return self.transferConfirmViewController
    }
}

private extension TransferConfirmationViewController {
    var dependenciesResolver: DependenciesResolver {
        return self.presenter.dependenciesResolver
    }
}
