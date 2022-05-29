import UIKit
import UI
import CoreFoundationLib

protocol QuickBalanceViewProtocol: class {
    func showNotActivatedViewWithVideoEnabled(_ isVideoEnabled: Bool)
    func showMovements(headerViewModel: QuickBalanceHeaderViewModel, movementViewModels: [QuickBalanceMovementViewModel])
    func showError(_ viewModel: QuickBalanceErrorViewModel)
    func showLoading()
    func hideLoading()
    func showTopAlert(text: LocalizedStylableText)
}

final class QuickBalanceViewController: UIViewController {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var backLoginButton: UIButton!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var deeplinksView: QuickBalanceDeeplinksView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    
    let presenter: QuickBalancePresenterProtocol
    private lazy var loadingView = {
        LoadingView()
    }()
    private lazy var headerView: QuickBalanceHeaderView = {
        let view = QuickBalanceHeaderView()
        view.delegate = self
        return view
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: QuickBalancePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enablePopGestureRecognizer(false)
        setupUI()
        setAccessibility()
        setupScrollView()
        self.presenter.viewDidLoad()
        setupDeeplinksView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.enablePopGestureRecognizer(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction private func didTapCloseButton(_ sender: UIButton) {
        presenter.didTapCloseButton()
    }
    
    @IBAction private func didTapBackLoginButton(_ sender: UIButton) {
        presenter.didTapBackLoginButton()
    }
}

private extension QuickBalanceViewController {
    func setupUI() {
        view.backgroundColor = .skyGray
        topSeparatorView.backgroundColor = .mediumSkyGray
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        closeImageView.image = Assets.image(named: "icnClose")
        backLoginButton.setBackgroundImage(Assets.image(named: "icnBackLogin"), for: .normal)
    }
    
    func setAccessibility() {
        closeButton?.accessibilityIdentifier = AccessibilityQuickBalance.btnClose.rawValue
        closeButton?.titleLabel?.accessibilityIdentifier = AccessibilityQuickBalance.btnCloseLabel.rawValue
        closeImageView?.accessibilityIdentifier = AccessibilityQuickBalance.closeImageView.rawValue
        backLoginButton?.accessibilityIdentifier = AccessibilityQuickBalance.btnBackLogin.rawValue
        backLoginButton?.titleLabel?.accessibilityIdentifier = AccessibilityQuickBalance.btnBackLoginLabel.rawValue
        stackView?.accessibilityIdentifier = AccessibilityQuickBalance.stackView.rawValue
        deeplinksView?.accessibilityIdentifier = AccessibilityQuickBalance.deeplinksView.rawValue
        scrollView?.accessibilityIdentifier = AccessibilityQuickBalance.scrollView.rawValue
        topSeparatorView?.accessibilityIdentifier = AccessibilityQuickBalance.topSeparatorView.rawValue
        bottomSeparatorView?.accessibilityIdentifier = AccessibilityQuickBalance.bottomSeparatorView.rawValue
    }
    
    func setupScrollView() {
        scrollView.delegate = self
    }
    
    func setupDeeplinksView() {
        let viewModel = QuickBalanceDeeplinksViewModel(buttons: [
            QuickBalanceDeeplinkButtonModel(action: .bizum),
            QuickBalanceDeeplinkButtonModel(action: .sendMoney),
            QuickBalanceDeeplinkButtonModel(action: .cardPin),
            QuickBalanceDeeplinkButtonModel(action: .cardTurnOff)
        ])
        deeplinksView.delegate = self
        deeplinksView.setViewModel(viewModel)
    }
    
    func removeAllFromStackView() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func addDefaultHeaderView() {
        headerView.setDefaultStatus()
        stackView.addArrangedSubview(headerView)
    }
}

// MARK: - QuickBalanceViewProtocol
extension QuickBalanceViewController: QuickBalanceViewProtocol {
    func showNotActivatedViewWithVideoEnabled(_ isVideoEnabled: Bool) {
        if isVideoEnabled {
            let headerViewModel = QuickBalanceHeaderViewModel(title: localized("quickBalance_title_quickBalance"))
            headerView.setViewModel(headerViewModel)
            stackView.addArrangedSubview(headerView)
        } else {
            addDefaultHeaderView()
        }
        let notActivatedView = QuickBalanceNotActivatedView()
        notActivatedView.delegate = self
        if isVideoEnabled {
            notActivatedView.setImage(Assets.image(named: "imgQuickBalance"))
        }
        stackView.addArrangedSubview(notActivatedView)
    }
    
    func showMovements(headerViewModel: QuickBalanceHeaderViewModel, movementViewModels: [QuickBalanceMovementViewModel]) {
        removeAllFromStackView()
        headerView.setViewModel(headerViewModel)
        stackView.addArrangedSubview(headerView)
        let sectionView = QuickBalanceSectionView()
        sectionView.setTitle(localized("widget_label_lastMovements"))
        stackView.addArrangedSubview(sectionView)
        if movementViewModels.isEmpty {
            let errorViewModel = QuickBalanceErrorViewModel(stylableErrorTitle: localized("generic_label_empty"), errorDescription: localized("widget_label_notAvailableMoves"), titleButton: localized("login_button_enter"))
            let errorView = QuickBalanceErrorView()
            errorView.delegate = self
            errorView.setViewModel(errorViewModel)
            stackView.addArrangedSubview(errorView)
        } else {
            movementViewModels.forEach { (viewModel) in
                let view = QuickBalanceMovementView()
                view.setViewModel(viewModel)
                stackView.addArrangedSubview(view)
            }
        }
        scrollView.layoutIfNeeded()
        bottomSeparatorView.isHidden = scrollView.contentSize.height <= scrollView.frame.height
    }
    
    func showTopAlert(text: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(text, alertType: .message, duration: 4)
    }
    
    func showError(_ viewModel: QuickBalanceErrorViewModel) {
        removeAllFromStackView()
        addDefaultHeaderView()
        let errorView = QuickBalanceErrorView()
        errorView.delegate = self
        errorView.setViewModel(viewModel)
        stackView.addArrangedSubview(errorView)
    }
    
    func showLoading() {
        removeAllFromStackView()
        topSeparatorView.isHidden = true
        bottomSeparatorView.isHidden = true
        addDefaultHeaderView()
        stackView.addArrangedSubview(loadingView)
    }
    
    func hideLoading() {
        loadingView.removeFromSuperview()
    }
}

// MARK: - QuickBalanceNotActivatedViewDelegate
extension QuickBalanceViewController: QuickBalanceNotActivatedViewDelegate {
    func didTapActivateButton() {
        presenter.didTapActivateButton()
    }
    
    func didTapImageView() {
        presenter.didTapVideo()
    }
}

// MARK: - QuickBalanceErrorViewDelegate
extension QuickBalanceViewController: QuickBalanceErrorViewDelegate {
    func didTapButton() {
        presenter.didTapErrorViewButton()
    }
}

// MARK: - QuickBalanceHeaderViewDelegate
extension QuickBalanceViewController: QuickBalanceHeaderViewDelegate {
    func didTapReloadButton() {
        presenter.didTapReloadButton()
    }
}

// MARK: - QuickBalanceDeeplinksViewDelegate
extension QuickBalanceViewController: QuickBalanceDeeplinksViewDelegate {
    func didTapButtonWithAction(_ action: QuickBalanceAction) {
        presenter.didTapDeeplinkButton(action)
    }
}

// MARK: - UIScrollViewDelegate
extension QuickBalanceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topSeparatorView.isHidden = scrollView.contentOffset.y <= 0
    }
}
