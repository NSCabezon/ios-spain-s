import Foundation
import UIKit
import CoreFoundationLib
import UI

protocol OldLoanDetailViewProtocol: LoadingViewPresentationCapable, OldDialogViewPresentationCapable {
    func setupViews(viewModel: OldLoanDetailDataViewModel)
    func setUpLoanName(_ loanName: String)
    func showError()
}

protocol OldLoanProductDetailIconViewDelegate: AnyObject {
    func didTapOnShare()
}

protocol OldLoanDetailDataViewDelegate: AnyObject {
    func didTapOnCopyDisplayNumber(_ completion: @escaping () -> Void)
}

final class OldLoanDetailViewController: UIViewController {
    
    @IBOutlet private weak var loanDetailAnimationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var loanContainerView: UIView!
    @IBOutlet private weak var loanDetailAnimationView: OldLoanDetailAnimationView!
    @IBOutlet private weak var loanDetailDataView: OldLoanDetailDataView!
    private var loanDetailDataViewModel: OldLoanDetailDataViewModel?
    private var copySuccessBottomConstraint: NSLayoutConstraint?
    private let presenter: OldLoanDetailPresenterProtocol
    private let dependenciesResolver: DependenciesResolver
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: OldLoanDetailPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loanDetailAnimationView.isHidden = true
        self.loanDetailDataView.isHidden = true
        self.containerView.isHidden = true
        self.separatorView.backgroundColor = .skyGray
        self.view.backgroundColor = .skyGray
        self.loanContainerView.backgroundColor = .skyGray
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

private extension OldLoanDetailViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_loansDetail")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setLoanDetailAnimationView(title: String?, subtitle: String?) {
        self.loanDetailAnimationView.isHidden = true
        if let subtitle = subtitle {
            self.loanDetailAnimationView.setSuccessAnimationView(subtitle: subtitle)
        } else {
            self.loanDetailAnimationView.setErrorAnimationView(title: title ?? "")
        }
    }
    
    func showAnimatedView(_ completion: (() -> Void)?) {
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
                completion?()
            })
        })
    }
    
    func addProductViews(viewModel: OldLoanDetailDataViewModel) {
        for field in viewModel.products {
            switch field.type {
            case .basic:
                let loanProductDetailBasicView = OldLoanProductDetailBasicView(frame: .zero)
                loanProductDetailBasicView.setupViewModel(title: field.title,
                                                          value: field.value,
                                                          titleIdentifier: field.titleIdentifier ?? field.title,
                                                          valueIdentifier: field.valueIdentifier ?? field.value)
                loanProductDetailBasicView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(loanProductDetailBasicView)
            case .icon:
                let loanProductDetailIconView = OldLoanProductDetailIconView(frame: .zero)
                loanProductDetailIconView.delegate = self
                loanProductDetailIconView.setupViewModel(title: field.title,
                                                         value: field.value,
                                                         titleIdentifier: field.titleIdentifier ?? field.title,
                                                         valueIdentifier: field.valueIdentifier ?? field.value,
                                                         iconIdentifier: field.iconIdentifier ?? "")
                loanProductDetailIconView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(loanProductDetailIconView)
            }
        }
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissViewController() {
        self.presenter.dismiss()
    }
}

extension OldLoanDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension OldLoanDetailViewController: OldLoanProductDetailIconViewDelegate {
    func didTapOnShare() {
        guard let viewModel = self.loanDetailDataViewModel else { return }
        self.presenter.didTapOnShareViewModel(viewModel)
    }
}

extension OldLoanDetailViewController: OldLoanDetailViewProtocol {
    func showError() {
        self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
    }
            
    func setupViews(viewModel: OldLoanDetailDataViewModel) {
        self.loanDetailDataViewModel = viewModel
        self.loanDetailDataView.setupLoanDetailDataView(viewModel: viewModel)
        self.loanDetailDataView.isHidden = false
        self.containerView.isHidden = false
        self.separatorView.isHidden = false
        self.loanDetailDataView.delegate = self
        self.addProductViews(viewModel: viewModel)
    }
    
    func setUpLoanName(_ loanName: String) {
        self.loanDetailDataView.setUpLoanName(loanName)
    }
}

extension OldLoanDetailViewController: OldLoanDetailDataViewDelegate {
    func didTapOnCopyDisplayNumber(_ completion: @escaping () -> Void) {
        self.setLoanDetailAnimationView(title: nil, subtitle: "generic_label_copy")
        self.showAnimatedView(completion)
    }
}
