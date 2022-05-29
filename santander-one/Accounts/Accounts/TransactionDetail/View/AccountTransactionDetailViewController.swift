import UIKit
import CoreFoundationLib
import UI

protocol AccountTransactionDetailViewProtocol: AnyObject {
    func showTransactions(_ viewModels: [AccountTransactionDetailViewModel], withSelected selected: AccountTransactionDetailViewModel)
    func showActions(_ viewModels: [AccountTransactionDetailActionViewModel])
    func showAssociatedTransactions(_ viewModels: [AssociatedTransactionViewModel])
    func update(viewModel: AccountTransactionDetailViewModel)
}

final class AccountTransactionDetailViewController: UIViewController {
    let presenter: AccountTransactionDetailPresenterProtocol
    private var actionButtons = AccountTransactionDetailActions()
    private var transactionCollectionView = AccountTransactionCollectinView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var associatedTransactionsView: AssociatedTransactionsView!
    @IBOutlet private weak var referenceView: UIView!
    @IBOutlet private weak var safeAreaBackground: UIView!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: AccountTransactionDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.skyGray
        self.referenceView.backgroundColor = UIColor.skyGray
        self.safeAreaBackground.backgroundColor = UIColor.skyGray
        self.transactionCollectionView.transactionDelegate = self
        self.associatedTransactionsView.associatedTransactionDelegate = self        
        self.stackView.addArrangedSubview(transactionCollectionView)
        self.stackView.addArrangedSubview(actionButtons)
        self.associatedTransactionsView.isHidden = true
    }

    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_movesDetail")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func mapSelected() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func dismissViewController() {
        self.presenter.dismiss()
    }
}

extension AccountTransactionDetailViewController: AccountTransactionCollectinViewDelegate {
    func didSelectTransaction(_ viewModel: AccountTransactionDetailViewModel) {
        self.presenter.didSelectTransaction(viewModel)
    }
    
    func didSelectEasyPay(_ transaction: AccountTransactionDetailViewModel) {
        self.presenter.didSelectEasyPay()
    }
    
    func didSelectOffer(viewModel: AccountTransactionDetailViewModel) {
        self.presenter.didSelectOffer()
    }
    
    func scrollViewDidEndDecelerating() {
        presenter.scrollViewDidEndDecelerating()
    }
}

extension AccountTransactionDetailViewController: AccountTransactionDetailViewProtocol {
    func showTransactions(_ viewModels: [AccountTransactionDetailViewModel], withSelected selected: AccountTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(viewModels, selecteViewModel: selected)
    }
    
    func showActions(_ viewModels: [AccountTransactionDetailActionViewModel]) {
        self.actionButtons.removeSubviews()
        self.actionButtons.setViewModels(viewModels)
    }
    
    func showAssociatedTransactions(_ viewModels: [AssociatedTransactionViewModel]) {
        self.associatedTransactionsView.isHidden = viewModels.isEmpty
        self.safeAreaBackground.backgroundColor = viewModels.isEmpty ? .skyGray : .blueAnthracita
        self.safeAreaBackground.isHidden = viewModels.isEmpty
        self.associatedTransactionsView.setViewModels(viewModels)
    }
    
    func update(viewModel: AccountTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(viewModel)
    }
}

extension AccountTransactionDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension AccountTransactionDetailViewController: AssociatedTransactionsViewDelegate {
    func didSelectTransaction(_ viewModel: AssociatedTransactionViewModel) {
        self.presenter.didSelectAssociatedTransaction(viewModel)
    }
}
