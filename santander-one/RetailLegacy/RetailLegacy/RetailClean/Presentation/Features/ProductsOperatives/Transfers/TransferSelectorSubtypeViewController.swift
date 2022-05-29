import UIKit
import Transfer
import UI
import CoreFoundationLib

protocol TransferSelectorSubtypePresenterProtocol: Presenter, TransferSubTypeSelectorPresenterProtocol {
    func didTapClose()
    func didTapFaqs()
    func didTapBack()
    func trackFaqEvent(_ question: String, url: URL?)
}

class TransferSelectorSubtypeViewController: BaseViewController<TransferSelectorSubtypePresenterProtocol> {
    
    weak var transferSubTypeViewController: TransferSubTypeSelectorViewController!
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    override var progressBarBackgroundColor: UIColor? {
        return .uiBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_sendType",
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
    
    override func prepareView() {
        super.prepareView()
        let transferSubTypeViewController = TransferSubTypeSelectorViewController(presenter: presenter)
        presenter.subTypeView = transferSubTypeViewController
        self.view.addSubview(transferSubTypeViewController.view)
        transferSubTypeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        transferSubTypeViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        transferSubTypeViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        transferSubTypeViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        transferSubTypeViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(transferSubTypeViewController)
        transferSubTypeViewController.didMove(toParent: self)
        self.transferSubTypeViewController = transferSubTypeViewController
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

extension TransferSelectorSubtypeViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension TransferSelectorSubtypeViewController: TransferSubTypeSelectorViewProtocol {
    func addPackageTransfer(transferPackage: TransferPackageViewModel) {
        return self.transferSubTypeViewController.addPackageTransfer(transferPackage: transferPackage)
    }
    
    func addHireTransferPackage() {
        return self.transferSubTypeViewController.addHireTransferPackage()
    }
    
    var associatedLoadingView: UIViewController {
        return self.transferSubTypeViewController
    }
    
    func showCommissions() {
        self.transferSubTypeViewController.showCommissions()
    }
    
    func hideCommissions() {
        self.transferSubTypeViewController.hideCommissions()
    }
    
    func showTransferSubTypes(types: [TransferSubTypeItemViewModel], addDisclaimerView: Bool) {
        self.transferSubTypeViewController.showTransferSubTypes(types: types, addDisclaimerView: addDisclaimerView)
    }
    
    func update(_ viewModel: TransferSubTypeItemViewModel) {
        self.transferSubTypeViewController.update(viewModel)
    }
}
