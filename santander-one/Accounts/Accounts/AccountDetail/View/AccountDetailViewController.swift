//
//  AccountDetailViewController.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 05/02/2021.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

protocol AccountDetailViewProtocol: LoadingViewPresentationCapable, OldDialogViewPresentationCapable {
    func setupViews(viewModel: AccountDetailDataViewModel)
    func setUpAccountName(_ accountName: String)
    func showActivatedMainView(_ subtitle: String?)
    func showAliasChangedView(isError: Bool, subtitle: String?)
    func showError()
    func showMainAccountDialog()
    func showAliasDialog()
}

protocol AccountProductDetailIconViewDelegate: AnyObject {
    func didTapOnShare()
}

protocol AccountProductDetailEditableViewDelegate: AnyObject {
    func didTapOnEdit(account: AccountDetailDataViewModel, alias: String)
}

protocol AccountDetailDataViewDelegate: AnyObject {
    func didTapOnCopyIban(_ completion: @escaping () -> Void)
}

protocol AccountDetailMainAccountViewDelegate: AnyObject {
    func didTapSwitch()
}

final class AccountDetailViewController: UIViewController {
    
    @IBOutlet private weak var accountDetailAnimationViewbottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var accountContainerView: UIView!
    @IBOutlet private weak var accountDetailAnimationView: AccountDetailAnimationView!
    @IBOutlet private weak var accountDetailDataView: AccountDetailDataView!
    @IBOutlet private weak var accountDetailMainAccountView: AccountDetailMainAccountView!
    private var accountDetailDataViewModel: AccountDetailDataViewModel?
    private var copySuccessBottomConstraint: NSLayoutConstraint?
    private let presenter: AccountDetailPresenterProtocol
    private let dependenciesResolver: DependenciesResolver
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: AccountDetailPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountDetailAnimationView.isHidden = true
        self.accountDetailDataView.isHidden = true
        self.accountDetailMainAccountView.isHidden = true
        self.containerView.isHidden = true
        self.separatorView.backgroundColor = .skyGray
        self.view.backgroundColor = .skyGray
        self.accountContainerView.backgroundColor = .skyGray
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

private extension AccountDetailViewController {
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_accountDetail")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setAccountDetailAnimationView(title: String?, subtitle: String?) {
        self.accountDetailAnimationView.isHidden = true
        if let subtitle = subtitle {
            self.accountDetailAnimationView.setSuccessAnimationView(subtitle: subtitle)
        } else {
            self.accountDetailAnimationView.setErrorAnimationView(title: title ?? "")
        }
    }
    
    func showAnimatedView(_ completion: (() -> Void)?) {
        self.accountDetailAnimationView.isHidden = false
        self.accountDetailAnimationViewbottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { [weak self] completed in
            guard completed else { return }
            self?.accountDetailAnimationViewbottomConstraint?.constant = -72
            UIView.animate(withDuration: 0.2, delay: 2) {
                self?.view.layoutIfNeeded()
            } completion: { [weak self] completed in
                guard completed else { return }
                self?.accountDetailAnimationView.isHidden = true
                completion?()
            }
        }

    }
    
    func addProductViews(viewModel: AccountDetailDataViewModel) {
        for field in viewModel.products {
            switch field.type {
            case .basic:
                let accountProductDetailBasicView = AccountProductDetailBasicView(frame: .zero)
                accountProductDetailBasicView.setupViewModel(title: field.title, value: field.value, titleAccessibilityID: field.titleAccessibilityID, valueAccessibilityID: field.valueAccessibilityID)
                accountProductDetailBasicView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(accountProductDetailBasicView)
            case .icon:
                let accountProductDetailIconView = AccountProductDetailIconView(frame: .zero)
                accountProductDetailIconView.delegate = self
                accountProductDetailIconView.setupViewModel(title: field.title, value: field.value, titleAccessibilityID: field.titleAccessibilityID, valueAccessibilityID: field.valueAccessibilityID)
                accountProductDetailIconView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(accountProductDetailIconView)
            case .editable:
                let accountProductDetailEditableView = AccountProductDetailEditableView(frame: .zero)
                accountProductDetailEditableView.delegate = self
                accountProductDetailEditableView.setupViewModel(account: viewModel, title: field.title, value: field.value, titleAccessibilityID: field.titleAccessibilityID, valueAccessibilityID: field.valueAccessibilityID, maxLengthString: field.maxAliasLength, regExValidatorString: field.regExValidatorString)
                accountProductDetailEditableView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(accountProductDetailEditableView)
            case .tooltip:
                let accountProductDetailTooltipView = AccountProductDetailTooltipView(frame: .zero)
                accountProductDetailTooltipView.setupView(title: field.title, value: field.value, tooltipText: field.tooltipText ?? "", titleAccessibilityID: field.titleAccessibilityID, valueAccessibilityID: field.valueAccessibilityID, tooltipAccesibilityID: field.tooltipAccesibilityID)
                accountProductDetailTooltipView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(accountProductDetailTooltipView)
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

extension AccountDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension AccountDetailViewController: AccountDetailViewProtocol {
    
    func showError() {
        self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
    }
    
    func showMainAccountDialog() {
        let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: { [weak self] in
                self?.showActivatedMainView(nil)
        })
        self.showOldDialog(
            title: nil,
            description: localized("generic_error_connection"),
            acceptAction: acceptAction,
            cancelAction: nil,
            isCloseOptionAvailable: true
        )
    }
    
    func showAliasDialog() {
        let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: { [weak self] in
                self?.showAliasChangedView(isError: true, subtitle: "accountDetail_label_errorChangeAlias")
        })
        self.showOldDialog(
            title: nil,
            description: localized("generic_error_connection"),
            acceptAction: acceptAction,
            cancelAction: nil,
            isCloseOptionAvailable: true
        )
    }
    
    func setupViews(viewModel: AccountDetailDataViewModel) {
        self.accountDetailDataViewModel = viewModel
        self.accountDetailDataView.setupAccountDetailDataView(viewModel: viewModel)
        self.accountDetailDataView.isHidden = false
        self.containerView.isHidden = false
        self.separatorView.isHidden = viewModel.mainItem != nil
        self.accountDetailMainAccountView.switchButton.isSelected = viewModel.mainItem != false
        self.accountDetailMainAccountView.isEnabledSwitch()
        self.accountDetailMainAccountView.isHidden = viewModel.mainItem == nil
        self.accountDetailMainAccountView.delegate = self
        self.accountDetailDataView.delegate = self
        self.addProductViews(viewModel: viewModel)
    }
    
    func setUpAccountName(_ accountName: String) {
        self.accountDetailDataView.setUpAccountName(accountName)
    }
    
    func showActivatedMainView(_ subtitle: String?) {
        if let subtitle = subtitle {
            self.accountDetailDataView.isMainAccount()
            self.accountDetailMainAccountView.switchButton.isSelected = true
            self.accountDetailMainAccountView.isEnabledSwitch()
            self.setAccountDetailAnimationView(title: nil, subtitle: subtitle)
        } else {
            self.accountDetailMainAccountView.switchButton.isSelected = false
            self.setAccountDetailAnimationView(title: "pt_accountDetail_text_mainAccount", subtitle: nil)
        }
        self.showAnimatedView(nil)
    }
    
    func showAliasChangedView(isError: Bool, subtitle: String?) {
        if !isError {
            self.setAccountDetailAnimationView(title: nil, subtitle: subtitle)
        } else {
            self.setAccountDetailAnimationView(title: "accountDetail_label_errorChangeAlias", subtitle: nil)
        }
        self.showAnimatedView(nil)
    }
}

extension AccountDetailViewController: AccountProductDetailIconViewDelegate {
    func didTapOnShare() {
        guard let viewModel = self.accountDetailDataViewModel else { return }
        self.presenter.didTapOnShareViewModel(viewModel)
    }
}

extension AccountDetailViewController: AccountProductDetailEditableViewDelegate {
    func didTapOnEdit(account: AccountDetailDataViewModel, alias: String) {
        self.presenter.didTapOnEditViewModel(accountViewModel: account, alias: alias)
    }
}

extension AccountDetailViewController: AccountDetailDataViewDelegate {
    func didTapOnCopyIban(_ completion: @escaping () -> Void) {
        self.setAccountDetailAnimationView(title: nil, subtitle: "generic_label_copyIban")
        self.showAnimatedView(completion)
    }
}

extension AccountDetailViewController: AccountDetailMainAccountViewDelegate {
    func didTapSwitch() {
        self.presenter.didTapOnSwitch()
    }
}
