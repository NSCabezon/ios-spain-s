import CoreFoundationLib
import Foundation
import UI

protocol FractionablePurchaseDetailViewProtocol: OldDialogViewPresentationCapable {
    func showLoadingView()
    func showEmptyView()
    func setCollapsableCarousel(_ viewModel: FractionablePurchaseDetailCarouselViewModel)
    func updateCollapsableCarousel(_ viewModel: FractionablePurchaseDetailViewModel)
    func addEasyPaymentAmortizations(_ amortizations: [MonthlyFeeViewModel]?)
}

final class FractionablePurchaseDetailViewController: UIViewController {
    private let dependenciesResolver: DependenciesResolver
    private let presenter: FractionablePurchaseDetailPresenterProtocol
    private var fractionableCollectionView = FractionablePurchaseCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    @IBOutlet private weak var containerView: UIView!
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0))
        view.setSpacing(0.0)
        return view
    }()
    
    private var paymentPlanViewContainer: UIView? {
        return paymentPlanView.superview
    }
    
    private lazy var paymentPlanView: EasyPayPaymentPlanView = {
        let view = EasyPayPaymentPlanView(frame: .zero, type: .fractionablePurchaseDetail)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(dependenciesResolver: DependenciesResolver, presenter: FractionablePurchaseDetailPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: "FractionablePurchaseDetailViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        NavigationBarBuilder(style: .custom(background: .color(.skyGray), tintColor: .santanderRed),
                             title: .title(key: "toolbar_title_instalmentsPurchases"))
            .setLeftAction(.back(action: #selector(didSelectBack)))
            .setRightActions(.close(action: #selector(didSelectClose)))
            .build(on: self, with: nil)
    }
}

extension FractionablePurchaseDetailViewController: FractionablePurchaseDetailViewProtocol {
    func setCollapsableCarousel(_ viewModel: FractionablePurchaseDetailCarouselViewModel) {
        fractionableCollectionView.configView(viewModel)
        fractionableCollectionView.fractionableDelegate = self
        scrollableStackView.addArrangedSubview(fractionableCollectionView)
    }
    
    func updateCollapsableCarousel(_ viewModel: FractionablePurchaseDetailViewModel) {
        fractionableCollectionView.updateTransactionViewModel(viewModel)
    }

    func addEasyPaymentAmortizations(_ amortizations: [MonthlyFeeViewModel]?) {
        guard let amortizations = amortizations else { return }
        clearView()
        addSeparatorView()
        scrollableStackView.addArrangedSubview(paymentPlanView.embedIntoView(leftMargin: 0, rightMargin: 0))
        paymentPlanView.setMonthlyFees([amortizations])
        paymentPlanView.hideViewsForFractionablePurchaseDetail()
    }

    func showEmptyView() {
        clearView()
        addSeparatorView()
        let view = SingleEmptyView()
        view.titleFont(UIFont.santander(family: .headline, size: 20.0))
        view.updateTitle(localized("fractionatePurchases_text_error"))
        scrollableStackView.addArrangedSubview(view)
        addSeparatorView()
    }
    
    func showLoadingView() {
        clearView()
        addSeparatorView()
        let animationView = LoadingViewWithTitle()
        animationView.configView(localized("fractionatePurchases_label_loadingInstalments"))
        animationView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        scrollableStackView.addArrangedSubview(animationView)
    }
}

private extension FractionablePurchaseDetailViewController {
    private var timeManager: TimeManager {
        dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }
    
    func setupView() {
        setDelegates()
    }
    
    func setDelegates() {
        fractionableCollectionView.fractionableDelegate = self
    }
    
    func clearView() {
        scrollableStackView.getArrangedSubviews().forEach {
            if !($0 is FractionablePurchaseCollectionView) {
                scrollableStackView.stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
    }
    
    func addSeparatorView() {
        let separatorView = SeparatorView()
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        scrollableStackView.addArrangedSubview(separatorView)
    }
}

extension FractionablePurchaseDetailViewController: FractionablePurchaseCollectionViewDelegate {
    func didSelectTransaction(_ viewModel: FractionablePurchaseDetailViewModel) {
        presenter.didSelectTransaction(viewModel)
    }
    
    func scrollViewDidEndDecelerating() {
        presenter.scrollViewDidEndDecelerating()
    }
    
    func didSelectInExpandableCollapsableButton(_ state: ResizableState) {
        presenter.didSelectInExpandableCollapsableButton(state)
    }
}
