import UIKit
import UI
import CoreFoundationLib
import ESCommons

protocol EcommerceViewProtocol: class, ShowLoginErrorViewCapable {
    func updateTicketView(_ headerType: EcommerceHeaderType, containerType: EcommerceTicketContentType, footerType: EcommerceFooterType)
    func showEmptyView()
    func removeEmptyView()
    func showEmptyViewWithSecureDevice(_ secureDeviceViewModel: EcommerceSecureDeviceViewModel)
}

public final class EcommerceViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var headerView: EcommerceHeaderView!
    @IBOutlet private weak var containerView: EcommerceContainerView!
    @IBOutlet private weak var footerView: EcommerceFooterView!
    @IBOutlet private weak var footerMarginView: UIView!
    @IBOutlet private weak var containerScrollView: UIScrollView!
    private var scrollContentSizeObservation: NSKeyValueObservation?
    
    lazy var emptyView: UIView = {
        let emptyPurchasesViewController = dependenciesResolver.resolve(for: EmptyPurchasesViewController.self)
        addChild(emptyPurchasesViewController)
        return emptyPurchasesViewController.view
    }()
    
    private let dependenciesResolver: DependenciesResolver
    
    private lazy var presenter: EcommercePresenterProtocol = {
        var presenter = dependenciesResolver.resolve(for: EcommercePresenterProtocol.self)
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
        super.init(nibName: "Ecommerce", bundle: Bundle.module)
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
        self.presenter.viewWillAppear()
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

extension EcommerceViewController: EcommerceViewProtocol {
    func updateTicketView(_ headerType: EcommerceHeaderType,
                          containerType: EcommerceTicketContentType,
                          footerType: EcommerceFooterType) {
        self.headerView.hideMoreInfoButton(headerType.rawValue)
        self.containerView.configView(containerType)
        self.footerView.configView(footerType)
    }
    
    func showEmptyView() {
        self.headerView.hideMoreInfoButton(true)
        self.setContraintsToContainer(of: self.emptyView)
        self.footerView.configView(.emptyView)
    }
    
    func showEmptyViewWithSecureDevice(_ secureDeviceViewModel: EcommerceSecureDeviceViewModel) {
        self.headerView.hideMoreInfoButton(true)
        let emptyPurchasesViewController = dependenciesResolver.resolve(for: EmptyPurchasesViewController.self)
        addChild(emptyPurchasesViewController)
        emptyPurchasesViewController.configureWithSecureDevice(secureDeviceViewModel)
        emptyPurchasesViewController.closeDelegate = self
        self.setContraintsToContainer(of: emptyPurchasesViewController.view)
    }
    
    func removeEmptyView() {
        self.emptyView.removeFromSuperview()
    }
}

private extension EcommerceViewController {
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setDelegates() {
        self.headerView.delegate = self
        self.containerView.delegate = self
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
}

extension EcommerceViewController: DidTapInHeaderButtonsDelegate {
    public func didTapInMoreInfo() {
        presenter.didTapInMoreInfo()
    }
    
    public func didTapInDismiss() {
        presenter.didTapInDismiss()
    }
}

extension EcommerceViewController: EcommerceContainerViewProtocol {
    
    public func didFinishTimerInProgressView() {
        presenter.didFinishTimerInProgressView()
    }
    
    public func didTapInUseKeyAccessView() {
        presenter.didTapInUseKeyAccess()
    }
    
    public func didPressChangeUser() { }
    
    public func didPressUseAccessCode() { }
    
    public func didTapBiometryIcon() {
        presenter.confirmEcommerce(.confirmBy(.fingerPrint))
    }
    
    public func didTapOpinator(_ opinatorPath: String) {
        presenter.didTapInOpinator(opinatorPath)
    }
}

extension EcommerceViewController: DidTapInFooterButtons {
    func didTapInTryAgainInShop() {
        presenter.didTapInTryAgainInShop()
    }
    
    func didTapInCancel() {
        presenter.didTapInCancel()
    }
    
    public func didTapInRightButton(_ type: EcommerceFooterType) {
        presenter.confirmEcommerce(type)
    }
    
    func didTapInBack() {}
}

extension EcommerceViewController: UIScrollViewDelegate {
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

extension EcommerceViewController: EmptyPurchaseCloseDelegate {
    public func didTapInDismiss(_ completion: (() -> Void)?) {
        presenter.didTapInDismiss(completion)
    }
}
