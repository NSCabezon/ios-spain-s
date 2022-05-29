//
//  FintechTPPConfirmationViewController.swift
//  Ecommerce
//
//  Created by alvola on 15/04/2021.
//

import UIKit
import UI
import CoreFoundationLib

protocol FintechTPPConfirmationViewProtocol: class {
    var presenter: FintechTPPConfirmationPresenterProtocol { get }
    func setViewState(_ state: FintechTPPConfirmationState)
}

enum FintechTPPConfirmationState {
    case loading
    case home(authType: EcommerceAuthType, authStatus: EcommerceAuthStatus, paymentStatus: EcommercePaymentStatus?, userName: String?)
    case identifyRemembered
    case identifyUnremembered
    case success
    case error(reason: String?)
    
    func headerHeight() -> EcommerceHeaderHeight {
        guard !Screen.isBiggerThanIphone6 else { return .big }
        switch self {
        case .identifyUnremembered:
            return .small
        case .loading, .home(authType: _, authStatus: _, paymentStatus: _, userName: _), .identifyRemembered, .success, .error(reason: _):
            return .big
        }
    }
    
    func footerMode() -> EcommerceFooterType {
        switch self {
        case .loading, .success, .error:
            return EcommerceFooterType.emptyView
        case .home(let type, let status, let paymentStatus, _):
            if case .notConfirmed = status, (type == .fingerPrint || type == .faceId ) {
                return EcommerceFooterType.confirmBy(.code)
            }
            guard status == .confirmed else { return .useCodeAccess }
            guard paymentStatus == nil else { return .processingPayment }
            return EcommerceFooterType.confirmBy(type)
        case .identifyRemembered, .identifyUnremembered:
            return EcommerceFooterType.useCodeAccess
        }
    }
}

public final class FintechTPPConfirmationViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var headerView: EcommerceHeaderView!
    @IBOutlet private weak var containerView: EcommerceContainerView!
    @IBOutlet private weak var footerView: EcommerceFooterView!
    @IBOutlet private weak var footerMarginView: UIView!
    @IBOutlet private weak var containerScrollView: UIScrollView!
    @IBOutlet weak var topStackViewToTopScrollViewConstraint: NSLayoutConstraint!
    
    private var currentState: FintechTPPConfirmationState?
    private let dependenciesResolver: DependenciesResolver
    private var scrollContentSizeObservation: NSKeyValueObservation?
    
    internal lazy var presenter: FintechTPPConfirmationPresenterProtocol = {
        var presenter = dependenciesResolver.resolve(for: FintechTPPConfirmationPresenterProtocol.self)
        presenter.view = self
        return presenter
    }()
    
    private var topSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.top
        } else {
            return self.topLayoutGuide.length
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "FintechTPPConfirmationViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        self.presenter.viewDidLoad()
        self.setupNavigationBar()
        self.setDelegates()
        self.setColors()
        self.addKVOObserverToContainerScroll()
        self.containerScrollView.scrollRectToVisible(.zero, animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.containerScrollView.delegate = self
        self.containerScrollView.bounces = false
        self.containerScrollView.scrollRectToVisible(.zero, animated: true)
        setPopGestureEnabled(false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.footerView.handleShadow((containerScrollView.contentOffset.y + 1) < (containerScrollView.contentSize.height - containerScrollView.frame.size.height))
    }
    
    func addKVOObserverToContainerScroll() {
        scrollContentSizeObservation = self.containerScrollView.observe(\UIScrollView.contentSize, options: [.new]) { [weak self] (_, change) in
            if let contentSize = change.newValue {
                self?.footerView.handleShadow(contentSize.height > self?.containerScrollView.bounds.size.height ?? 0)
            }
        }
    }
}

extension FintechTPPConfirmationViewController {
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setDelegates() {
        self.headerView.delegate = self
        self.containerView.delegate = self
        self.containerView.fintechDelegate = self
        self.footerView.delegate = self
    }
    
    func setContraintsToContainer(of view: UIView) {
        self.containerView.subviews.forEach { $0.removeFromSuperview() }
        self.containerView.addSubview(view)
        view.fullFit()
    }
    
    func setColors() {
        self.view.backgroundColor = .silverDark
        self.footerMarginView.backgroundColor = .skyGray
    }
    
    func configureTopStackViewConstraint(_ state: FintechTPPConfirmationState) {
        switch state {
        case .identifyUnremembered:
            self.topStackViewToTopScrollViewConstraint.constant = 5
        case .error(reason: _),
             .home(authType: _, authStatus: _, paymentStatus: _, userName: _),
             .identifyRemembered,
             .loading,
             .success:
            self.topStackViewToTopScrollViewConstraint.constant = 25
        }
    }
    
    func configureViewForState(_ state: FintechTPPConfirmationState) {
        self.configureTopStackViewConstraint(state)
        self.headerView.hideMoreInfoButton(true)
        self.headerView.configView(state.headerHeight())
        self.footerView.configView(state.footerMode())
        containerView.configView(state)
        self.containerScrollView.setContentOffset(CGPoint(x: 0, y: -self.containerScrollView.contentInset.top), animated: false)
    }
}

extension FintechTPPConfirmationViewController: DidTapInHeaderButtonsDelegate {
    public func didTapInMoreInfo() {
    }
    
    public func didTapInDismiss() {
        presenter.dismiss()
    }
}

extension FintechTPPConfirmationViewController: EcommerceContainerViewProtocol {
    
    public func didPressChangeUser() {
        configureViewForState(.identifyUnremembered)
    }
    
    public func didPressUseAccessCode() {
        guard let state = currentState else { return configureViewForState(.identifyUnremembered) }
        switch state {
        case .home(_, _, _, let username):
            configureViewForState(username != nil ? .identifyRemembered : .identifyUnremembered)
        default:
            break
        }
    }
    
    public func didFinishTimerInProgressView() {}
    
    public func didTapInUseKeyAccessView() {
        self.setViewState(.identifyRemembered)
    }
    
    public func didTapBiometryIcon() {
        if case .home(_, let authStatus, _, _) = currentState {
            switch authStatus {
            case .notConfirmed:
                break
            case .confirmed:
                presenter.confirm(withType: .fingerPrint)
            }
        }
    }
    
    public func didTapOpinator(_ opinatorPath: String) {}
}

extension FintechTPPConfirmationViewController: DidTapInFooterButtons {
    func didTapInRightButton(_ type: EcommerceFooterType) {
        switch type {
        case .confirmBy(let type):
            presenter.confirm(withType: type)
        case .restorePassword, .useCodeAccess:
            presenter.restorePassword()
        case .processingPayment, .tryAgainInShop, .emptyView:
            break
        }
    }
    
    func didTapInCancel() {
        presenter.dismiss()
    }
    
    func didTapInBack() {
        guard let state = currentState else { return presenter.dismiss() }
        configureViewForState(state)
    }
    
    func didTapInTryAgainInShop() { }
}

extension FintechTPPConfirmationViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle shadow when scroll moves
        let minY = scrollView.contentOffset.y + topSafeAreaHeight
        self.footerView.handleShadow(minY >= .zero)
        // Handle shadow when scrolls to bottom
        let scrollHeight = scrollView.contentSize.height - scrollView.frame.size.height
        if scrollView.contentOffset.y >= scrollHeight {
            self.footerView.removeShadow()
        }
    }
}

extension FintechTPPConfirmationViewController: FintechTPPConfirmationViewProtocol {
    func setViewState(_ state: FintechTPPConfirmationState) {
        switch state {
        case .identifyRemembered, .identifyUnremembered:
            break
        default:
            currentState = state
        }
        configureViewForState(state)
    }
}

extension FintechTPPConfirmationViewController: FintechNumberPadConfirmationProtocol {
    public func confirmed(withAccesskey key: String) {
        presenter.confirm(withAccessKey: key)
    }

    public func confirmed(withType type: String, documentNumber: String, accessKey: String) {
        presenter.confirm(withDocumentType: type, documentNumber: documentNumber, accessKey: accessKey)
    }
}
