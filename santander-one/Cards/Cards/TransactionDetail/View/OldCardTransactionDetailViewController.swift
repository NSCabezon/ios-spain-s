import UIKit
import CoreFoundationLib
import UI

protocol CardTransactionDetailViewProtocol: AnyObject {
    func showTransactions(_ viewModels: [OldCardTransactionDetailViewModel], withSelected selected: OldCardTransactionDetailViewModel)
    func updateTransaction(_ viewModel: OldCardTransactionDetailViewModel)
    func showActions(_ viewModels: [CardActionViewModel])
    func showFractionatePaymentWithViewModel(_ viewModel: FractionatePaymentItem)
    func showNotAvailable()
    func addNoLocalizableMovementView()
    func addTemporallyNotLocalizableMovementView()
    func addLocationView(_ viewModel: CardTransactionDetailLocationItem)
    func removeFractionatePaymentView()
    func removeMapViews()
}

final class OldCardTransactionDetailViewController: UIViewController {
    let presenter: CardTransactionDetailPresenterProtocol
    let scrollableStackView = ScrollableStackView(frame: .zero)
    let actionButtons = OldCardTransactionDetailActions()
    let fractionatePaymentView = OldFractionatePaymentView()
    let transactionCollectionView = OldCardTransactionCollectoinView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var noLocationMapView = {
        OldCardTransactionDetailWithoutLocationView()
    }()
    private lazy var mapView: OldCardTransactionDetailLocationView = {
        let view = OldCardTransactionDetailLocationView()
        view.delegate = self
        return view
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardTransactionDetailPresenterProtocol) {
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
        fractionatePaymentView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.skyGray
        self.transactionCollectionView.transactionDelegate = self
        self.scrollableStackView.setup(with: self.view)
        self.scrollableStackView.addArrangedSubview(transactionCollectionView)
        self.scrollableStackView.addArrangedSubview(actionButtons)
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
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    private func removePreviousMapViews() {
        mapView.removeFromSuperview()
        noLocationMapView.removeFromSuperview()
    }
}

extension OldCardTransactionDetailViewController: CardTransactionDetailViewProtocol {
    func showFractionatePaymentWithViewModel(_ viewModel: FractionatePaymentItem) {
        self.scrollableStackView.addArrangedSubview(fractionatePaymentView)
        self.fractionatePaymentView.setViewModel(viewModel)
    }
    
    func showNotAvailable() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func showTransactions(_ viewModels: [OldCardTransactionDetailViewModel], withSelected selected: OldCardTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(viewModels, selecteViewModel: selected)
    }
    
    func showActions(_ viewModels: [CardActionViewModel]) {
        self.actionButtons.removeSubviews()
        self.actionButtons.setViewModels(viewModels)
    }
    
    func updateTransaction(_ viewModel: OldCardTransactionDetailViewModel) {
        self.transactionCollectionView.updateTransactionViewModel(viewModel)
    }
    
    func addNoLocalizableMovementView() {
        noLocationMapView.setTitle(localized("transaction_text_geolocationNotAllowed"))
        removePreviousMapViews()
        scrollableStackView.insetArrangedSubview(noLocationMapView, at: 1)
    }
    
    func addTemporallyNotLocalizableMovementView() {
        noLocationMapView.setTitle(localized("transaction_text_geolocationPending"))
        removePreviousMapViews()
        scrollableStackView.insetArrangedSubview(noLocationMapView, at: 1)
    }
    
    func addLocationView(_ viewModel: CardTransactionDetailLocationItem) {
        mapView.delegate = self
        mapView.setViewModel(viewModel)
        removePreviousMapViews()
        scrollableStackView.insetArrangedSubview(mapView, at: 1)
    }
    
    func removeFractionatePaymentView() {
        self.fractionatePaymentView.removeFromSuperview()
    }
    
    func removeMapViews() {
        removePreviousMapViews()
    }
}

extension OldCardTransactionDetailViewController: CardTransactionCollectoinViewCellDelegate {
    
    func didSelectTransactionViewModel(_ viewModel: OldCardTransactionDetailViewModel) {
        self.presenter.didSelectTransaction(viewModel)
    }
    
    func didSelectFractionate() {
        self.presenter.didSelectFractionate()
    }
    
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel) {
        self.presenter.didSelectOffer(viewModel)
    }
}

extension OldCardTransactionDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension OldCardTransactionDetailViewController: FractionatePaymentViewConformable {
    func didSelectMonthlyFee(_ montlyFee: MontlyPaymentFeeItem) {
        self.presenter.didSelectEasyPayWithMontlyFee(montlyFee)
    }
}

extension OldCardTransactionDetailViewController: CardTransactionDetailLocationViewDelegate {
    func mapButtonPressed() {
        presenter.didSelectMap()
    }
}
