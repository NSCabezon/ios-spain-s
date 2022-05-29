import UIKit
import UI
import CoreFoundationLib

protocol ChangePaymentMethodViewProtocol: CardBoardingStepView, LoadingViewPresentationCapable {
    func setHeaderView(_ viewModel: PaymentMethodHeaderViewModel)
    func setMonthlyView(_ viewModel: PaymentMethodViewModel)
    func setDeferredView(_ viewModel: PaymentMethodExpandableViewModel)
    func setFixedFeeView(_ viewModel: PaymentMethodExpandableViewModel)
    func setPaymentMethod(_ paymentMethod: PaymentMethodCategory)
    func presentSummary(_ paymentMethod: PaymentMethodCategory)
    func showError(_ key: String)
}

class ChangePaymentMethodViewController: UIViewController {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var topShadow: UIView!
    private let presenter: ChangePaymentMethodPresenterProtocol
    var isFirstStep: Bool = false
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.containerView)
        view.backgroundColor = .clear
        return view
    }()
    private var headerView = ChangePaymentMethodHeaderView()
    private var paymentMethodsContainerView = PaymentMethodContainerView()
    private let cardBoardingFooter = CardBoardingTabBar(frame: .zero)
    let keyboardManager = KeyboardManager()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ChangePaymentMethodPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.keyboardManager.setKeyboardButtonEnabled(true)
        self.scrollableStackView.addArrangedSubview(self.headerView)
        self.scrollableStackView.addArrangedSubview(self.paymentMethodsContainerView)
        self.scrollableStackView.scrollView.delegate = self
        self.addCardBoardingFooter()
        self.paymentMethodsContainerView.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
        self.setAppareance()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

private extension ChangePaymentMethodViewController {
    func setAppareance() {
        self.view.applyGradientBackground(colors: [.white, .skyGray, .white], locations: [0.0, 0.9, 0.2])
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
    
    func setNavigationBar() {
        let builder = NavigationBarBuilder(style: .white, title: .none)
        builder.build(on: self, with: nil)
    }
    
    func addCardBoardingFooter() {
        self.view.addSubview(self.cardBoardingFooter)
        self.cardBoardingFooter.backButton.isHidden = self.isFirstStep
        self.cardBoardingFooter.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.cardBoardingFooter.addBackAction(target: self, selector: #selector(didSelectBack))
        self.cardBoardingFooter.addNextAction(target: self, selector: #selector(didSelectNext))
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.didSelectNext()
    }
    
    private func didSelectNextTextfield(_ textField: EditText) {
        self.didSelectNext()
    }
}

extension ChangePaymentMethodViewController: ChangePaymentMethodViewProtocol {
    func setHeaderView(_ viewModel: PaymentMethodHeaderViewModel) {
        self.headerView.setViewModel(viewModel)
    }
    
    func setMonthlyView(_ viewModel: PaymentMethodViewModel) {
        self.paymentMethodsContainerView.setMonthlyView(viewModel)
    }
    
    func setDeferredView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.paymentMethodsContainerView.setDeferredView(viewModel)
    }
    
    func setFixedFeeView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.paymentMethodsContainerView.setFixedFeeView(viewModel)
    }
    
    func setPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.paymentMethodsContainerView.setSelectedPaymentMethod(paymentMethod)
    }
    
    func presentSummary(_ paymentMethod: PaymentMethodCategory) {
        let view = ChangePaymentMethodSummaryView(delegate: self, paymentMethod: paymentMethod)
        self.navigationController?.view.addSubview(view)
        view.fullFit()
    }
    
    func showError(_ key: String) {
        let skipStepAction = DialogButtonComponents(titled: localized("generic_button_skipStep"), does: { self.presenter.didSelectSkipStep() })
        let retryAction = DialogButtonComponents(titled: localized("generic_button_retry"), does: { self.presenter.didSelectRetry() })
        self.showOldDialog(
            title: nil,
            description: localized(key),
            acceptAction: skipStepAction,
            cancelAction: retryAction,
            isCloseOptionAvailable: true
        )
    }
}

extension ChangePaymentMethodViewController: PaymentMethodContainerDelegate {
    func didUpdatedNewPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.presenter.didPaymentMethodUpdated(paymentMethod)
        self.view?.endEditing(true)
    }
}

extension ChangePaymentMethodViewController: ChangePaymentMethodSummaryViewDelegate {
    func didSelectNextStep() {
        self.view.endEditing(true)
        self.presenter.didSelectNextSummaryView()
    }
    
    func didSelectClose() {
        
    }
}

extension ChangePaymentMethodViewController: KeyboardManagerDelegate {
    var associatedScrollView: UIScrollView? {
        return self.scrollableStackView.scrollView
    }
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("cardBoarding_button_next"), accessibilityIdentifier: "", action: self.didSelectNextTextfield)
    }
}

extension ChangePaymentMethodViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}

extension ChangePaymentMethodViewController: OldDialogViewPresentationCapable {}
