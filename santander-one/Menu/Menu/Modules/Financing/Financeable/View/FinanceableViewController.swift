import UIKit
import UI
import CoreFoundationLib

protocol FinanceableViewProtocol: AnyObject {
    func setCardCarouselViewState(_ viewState: CardsCarouselViewState)
    func showFinancingTricks(_ viewModels: [TrickViewModel])
    func hideFinancingTricks()
    func showFinancingTricksCurtainView(viewModels: [TrickViewModel], index: Int)
    func setAccountCarouselViewState(_ viewState: AccountCarouselViewState)
    func setFractionalPaymentsView(_ viewModel: FinanceableInfoViewModel)
    func setCardCarouselView()
    func setFinanceableOfferSectionView(_ viewModel: FinanceableInfoViewModel, baseUrl: String?)
    func setBankableCardReceiptsView(_ viewModels: [BankableCardReceiptViewModel])
    func setTitleView()
    func setLoadingView(completion: (() -> Void)?)
    func hideLoadingView(completion: (() -> Void)?)
}

final class FinanceableViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var shadowView: UIView!
    private let presenter: FinanceablePresenterProtocol
    private let titleView = FinanceableTitleView(frame: .zero)
    private let accountsFinanceableTransactionsView = AccountFinanceableTransactionsView(frame: .zero)
    private let cardsFinanceableTransactionsView = CardFinanceableTransactionsView(frame: .zero)
    private let fractionalPaymentsView = FractionalPaymentsView(frame: .zero)
    private lazy var bankableCardReceiptsView: BankableCardReceiptsView = { BankableCardReceiptsView(frame: .zero)}()
    
    private lazy var tricksCarouselView: TricksCarouselView = {
        let tricksView = TricksCarouselView()
        tricksView.setControllerDelegate(self)
        tricksView.setCollectionViewDelegate(self)
        tricksView.setTitle("financing_title_footer")
        tricksView.accessibilityIdentifier = AccessibilityFinanceable.tricksCarousel
        tricksView.heightAnchor.constraint(equalToConstant: 265).isActive = true
        return tricksView
    }()
    
    private lazy var tricksCurtainView: TricksCourtainView = {
        let tricksCurtainView = TricksCourtainView(frame: UIScreen.main.bounds)
        tricksCurtainView.delegate = self
        tricksCurtainView.setTricksCarouselTitle("financing_title_footer")
        tricksCurtainView.setTrickCourtainToolbarTitle("toolbar_title_moreFinancing")
        return tricksCurtainView
    }()
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: containerView)
        view.setScrollDelegate(self)
        return view
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FinanceablePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setupShadowView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
}

extension FinanceableViewController: LoadingViewPresentationCapable { }

private extension FinanceableViewController {
    func setDelegates() {
        cardsFinanceableTransactionsView.delegate = self
        accountsFinanceableTransactionsView.delegate = self
        scrollableStackView.scrollView.delegate = self
    }
    
    func setAccountCarouselView(_ viewModel: FinanceableInfoViewModel) {
        guard let viewModel = viewModel.accountsCarousel, viewModel.accounts.count > 0 else { return }
        accountsFinanceableTransactionsView.setViewModel(AccountsCarouselViewModel(viewModel))
        scrollableStackView.addArrangedSubview(accountsFinanceableTransactionsView)
    }
    
    func setupShadowView() {
        self.shadowView.backgroundColor = .white
    }
}

internal extension FinanceableViewController {
    func setTitleView() {
        scrollableStackView.addArrangedSubview(titleView)
    }
    
    func setFractionalPaymentsView(_ viewModel: FinanceableInfoViewModel) {
        guard let viewModel = viewModel.fractionalPayment else { return }
        fractionalPaymentsView.setViewModel(viewModel)
        fractionalPaymentsView.delegate = self
        scrollableStackView.addArrangedSubview(fractionalPaymentsView)
    }
    
    func setBankableCardReceiptsView(_ viewModels: [BankableCardReceiptViewModel]) {
        bankableCardReceiptsView.configView(viewModels, with: self)
    }
    
    func setCardCarouselView() {
        scrollableStackView.addArrangedSubview(bankableCardReceiptsView)
    }
}

extension FinanceableViewController: FinanceableViewProtocol {
    func setLoadingView(completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
    
    func setCardCarouselViewState(_ viewState: CardsCarouselViewState) {
        cardsFinanceableTransactionsView.setViewState(viewState)
    }
    
    func showFinancingTricks(_ viewModels: [TrickViewModel]) {
        tricksCarouselView.setTipsViewModels(viewModels)
        scrollableStackView.addArrangedSubview(tricksCarouselView)
    }
    
    func hideFinancingTricks() {
        tricksCarouselView.isHidden = true
    }
    
    func showFinancingTricksCurtainView(viewModels: [TrickViewModel], index: Int) {
        guard !(view.window?.subviews.contains { $0 is TricksCourtainView } ?? false) else { return }
        view.window?.addSubview(tricksCurtainView)
        tricksCurtainView.fullFit()
        tricksCurtainView.setViewModels(viewModels)
        tricksCurtainView.setViewModelOfIndex(index)
        if let newIndex = tricksCurtainView.scrollToIndex(index + 1) {
            tricksCarouselView.scrollToIndex(newIndex, animated: false)
        }
    }
    
    func setAccountCarouselViewState(_ viewState: AccountCarouselViewState) {
        accountsFinanceableTransactionsView.setViewState(viewState)
    }
    
    func setFinanceableOfferSectionView(_ viewModel: FinanceableInfoViewModel,
                                        baseUrl: String?) {
        let view = FinanceableOfferSectionView()
        view.configView(
            viewModel,
            delegate: self,
            baseUrl: baseUrl
        )
        scrollableStackView.addArrangedSubview(view)
    }
}

extension FinanceableViewController: CardFinanceableTransactionsViewDelegate {
    func didSelectSeeAllFinanceableTransactions(_ card: CardFinanceableViewModel) {
        presenter.didSelectSeeAllFinanceableTransactions(card)
    }
    
    func didSelectCardBankableTransaction(_ cardBankableTransaction: CardFinanceableTransactionViewModel) { }
    
    func didSelectHireCard(_ location: PullOfferLocation?) {
        presenter.didSelectHireCard(location)
    }
    
    func didSelectCard(_ viewModel: CardFinanceableViewModel) { }
}

extension FinanceableViewController: TricksCollectionViewControllerDelegate {
    func didPressTrick(index: Int) {
        presenter.didPressTrick(index: index)
    }
}

extension FinanceableViewController: TricksCollectionViewDelegate {
    func scrollViewDidEndDecelerating() {}
}

extension FinanceableViewController: TipsCurtainViewDelegate {
    func didScrollToIndex(_ index: Int) {
        tricksCarouselView.scrollToIndex(index, animated: false)
    }
}

extension FinanceableViewController: AccountFinanceableViewDelegate {
    func didSelectSeeAllFinanceableTransactions(from account: AccountFinanceableViewModel) {
        presenter.didSelectSeeAllAccountFinanceableTransacations(account)
    }
    
    func didSelectAccountTransaction(_ accountTransaction: AccountFinanceableTransactionViewModel) {
        presenter.didSelectAccountTransaction(accountTransaction)
    }
    
    func didSelectAccount(_ viewModel: AccountFinanceableViewModel) { }
    
    func selectorDetailDisplayed(_ isDisplayed: Bool) {
        scrollableStackView.enableScroll(isEnabled: !isDisplayed)
    }
}

extension FinanceableViewController: FractionalPaymentViewDelegate {
    func didSelectPaymentView(viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel) {
        presenter.didSelectPaymentBox(viewModel)
    }
}

extension FinanceableViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollEnabled = scrollableStackView.scrollView.contentOffset.y > 0
        let shadowColor: UIColor = isScrollEnabled
        ? .brownishGray.withAlphaComponent(0.44)
        : .clear
        shadowView.drawShadow(
            offset: (x: 0, y: 3),
            color: shadowColor,
            radius: 2
        )
    }
}

extension FinanceableViewController: BankableCardReceiptsViewDelegate {
    func didSelectReceiptCard(_ viewModel: BankableCardReceiptViewModel) {
        presenter.didSelectGoToNextSettlement(viewModel)
    }
}

extension FinanceableViewController: BigOfferFinanceableViewDelegate {
    func didSelectBigBanner(_ viewModel: OfferEntityViewModel) {
        presenter.didSelectOffer(viewModel)
    }
}

extension FinanceableViewController: FinanceableOfferSectionViewDelegate {
    func didSelectInPreconceivedBanner(_ viewModel: OfferEntityViewModel) {
        presenter.didSelectPreconceivedBanner(viewModel)
    }
    
    func didSelectInRobinsonBanner(_ viewModel: OfferEntityViewModel) {
        presenter.didSelectOffer(viewModel)
    }
    
    func didSelectInCommercialOfferBanner(_ viewModel: OfferEntityViewModel) {
        presenter.didSelectOffer(viewModel)
    }
    
    func didSelectInAdobeTargetBanner(_ viewModel: AdobeTargetOfferViewModel) {
        presenter.didSelectAdobeTargetOfferBanner(viewModel)
    }
}
