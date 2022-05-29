import Foundation
import UIKit
import CoreFoundationLib
import UI
import OpenCombine
import CoreDomain

final class LoanDetailViewController: UIViewController {
    
    @IBOutlet private weak var loanDetailAnimationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var loanContainerView: UIView!
    @IBOutlet private weak var loanDetailAnimationView: LoanDetailAnimationView!
    @IBOutlet private weak var loanDetailDataView: LoanDetailDataView!
    private var copySuccessBottomConstraint: NSLayoutConstraint?
    private let viewModel: LoanDetailViewModel
    private let dependencies: LoanDetailDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private let navigationBarItemBuilder: NavigationBarItemBuilder

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(dependencies: LoanDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "LoanDetail", bundle: .module)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.bind()
        self.viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

private extension LoanDetailViewController {
    
    func setupView() {
        self.loanDetailAnimationView.isHidden = true
        self.loanDetailDataView.isHidden = true
        self.containerView.isHidden = true
        self.separatorView.backgroundColor = .skyGray
        self.view.backgroundColor = .skyGray
        self.loanContainerView.backgroundColor = .skyGray
    }
    
    func bind() {
        self.bindDetailInfo()
        self.bindCopyValues()
    }
    
    func bindDetailInfo() {
        viewModel.state
            .case { LoanDetailState.allInfoLoaded }
            .sink { [unowned self] (loan, products) in
                self.setupData(loan: loan)
                self.addProductViews(products: products)
            }.store(in: &anySubscriptions)
    }
    
    func bindCopyValues() {
        self.loanDetailDataView.onTouchCopySubject
            .sink { [unowned self] in
                self.setLoanDetailAnimationView(title: nil, subtitle: "generic_label_copy")
                self.showAnimatedView()
                self.viewModel.copyContractAccount()
            }.store(in: &anySubscriptions)
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_loansDetail"))
            .setLeftAction(.back, associatedAction: .closure { [weak self] in
                self?.viewModel.didSelectBack()
            })
            .addRightAction(.menu, associatedAction: .closure({ [weak self] in
                self?.viewModel.didSelectMenu()
            }))
            .build(on: self)
    }
    
    func setupData(loan: LoanRepresentable) {
        self.loanDetailDataView.configure(loan: loan)
        self.loanDetailDataView.isHidden = false
        self.containerView.isHidden = false
        self.separatorView.isHidden = false
    }
    
    func setLoanDetailAnimationView(title: String?, subtitle: String?) {
        self.loanDetailAnimationView.isHidden = true
        if let subtitle = subtitle {
            self.loanDetailAnimationView.setSuccessAnimationView(subtitle: subtitle)
        } else {
            self.loanDetailAnimationView.setErrorAnimationView(title: title ?? "")
        }
    }
    
    func showAnimatedView() {
        self.loanDetailAnimationView.isHidden = false
        self.loanDetailAnimationViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] completed in
            guard completed else { return }
            self?.loanDetailAnimationViewBottomConstraint?.constant = -72
            UIView.animate(withDuration: 0.2, delay: 2, animations: {
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] completed in
                guard completed else { return }
                self?.loanDetailAnimationView.isHidden = true
                self?.loanDetailDataView.enableCopyTap()
            })
        })
    }
    
    func addProductViews(products: [LoanDetailProduct]) {
        for field in products {
            switch field.type {
            case .basic:
                let loanProductDetailBasicView = LoanDetailProductBasicView(frame: .zero)
                loanProductDetailBasicView.configure(
                    title: field.title,
                    value: field.value,
                    titleIdentifier: field.titleIdentifier ?? field.title,
                    valueIdentifier: field.valueIdentifier ?? field.value
                )
                loanProductDetailBasicView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(loanProductDetailBasicView)
            case .icon:
                let loanProductDetailIconView = LoanDetailProductIconView(frame: .zero)
                loanProductDetailIconView.configure(
                    title: field.title,
                    value: field.value,
                    titleIdentifier: field.titleIdentifier ?? field.title,
                    valueIdentifier: field.valueIdentifier ?? field.value,
                    iconIdentifier: field.iconIdentifier ?? ""
                )
                loanProductDetailIconView.onTouchShareSubject
                    .sink { [weak self] in
                        self?.viewModel.didTapOnShare()
                    }.store(in: &anySubscriptions)
                loanProductDetailIconView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(loanProductDetailIconView)
            }
        }
    }
}

extension LoanDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension LoanDetailViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return .myProducts
    }
}
