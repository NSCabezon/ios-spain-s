//
//  EditFavouriteHolderAndAccountViewController.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 26/07/2021.
//

import Operative
import UI
import CoreFoundationLib

protocol EditFavouriteHolderAndAccountViewProtocol: ValidatableFormViewProtocol, OperativeView {
    var ibanText: String { get }
    func showError(_ description: LocalizedStylableText, isIBANerror: Bool)
    func addViewItem(_ viewModel: EditFavouriteItemViewModel)
    func addViewFieldItem(_ viewModel: EditFavouriteItemViewModel)
    func addViewFieldIBANItem(_ bankUtils: BankingUtilsProtocol, viewModel: EditFavouriteItemViewModel)
}

final class EditFavouriteHolderAndAccountViewController: UIViewController {
    let presenter: EditFavouriteHolderAndAccountPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    private let itemIBANView = EditFavouriteItemIBANView()
    var ibanText = ""
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    @IBOutlet private weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.setIsEnabled(false)
            self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
            self.continueButton.accessibilityIdentifier = AccessibilityTransfers.btnContinue
            self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        }
    }
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    init(nibName nibNameOrNil: String?, presenter: EditFavouriteHolderAndAccountPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardManager.update()
    }
}

private extension EditFavouriteHolderAndAccountViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "pt_toolbar_title_favoriteEdit",
                                    header: .title(key: "share_title_transfers",
                                                   style: .default))
        )
        builder.build(on: self, with: nil)
    }
    
    func createTextFieldWithId(_ viewModel: NewFavouriteTextFieldViewModel) -> UIView? {
        let lisboaTextFieldErrorView = LisboaTextFieldWithErrorView()
        guard let holderNameTextField = lisboaTextFieldErrorView.textField else { return nil }
        let formattedText = UIFormattedCustomTextField()
        if let maxLength = viewModel.maxLength {
            formattedText.setMaxLength(maxLength: maxLength)
        }
        lisboaTextFieldErrorView.textField.accessibilityIdentifier = viewModel.identifier
        lisboaTextFieldErrorView.setHeight(48.0)
        holderNameTextField.setEditingStyle(
            .writable(configuration: LisboaTextField.WritableTextField(
                        type: .simple,
                        formatter: UIFormattedCustomTextField(),
                        disabledActions: [],
                        keyboardReturnAction: nil,
                        textfieldCustomizationBlock: self.setupTextField(_:))))
        holderNameTextField.setText(viewModel.placeHolder)
        holderNameTextField.updatableDelegate = self
        self.presenter.fields.append(holderNameTextField)
        return lisboaTextFieldErrorView
    }
    
    func setupTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.autocorrectionType = .no
        component.textField.spellCheckingType = .no
    }
    
    @objc func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    private func didSelectContinueTextfield(_ textfield: EditText) {
        self.didSelectContinue()
    }
}

extension EditFavouriteHolderAndAccountViewController: EditFavouriteHolderAndAccountViewProtocol {
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    func showError(_ description: LocalizedStylableText, isIBANerror: Bool) {
        guard isIBANerror else {
            let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
            self.showOldDialog(title: localized("generic_alert_title_errorData"), description: description, acceptAction: acceptComponents, cancelAction: nil, isCloseOptionAvailable: false)
            return
        }
        self.itemIBANView.showError(localized("sendMoney_label_errorIban"))
        self.stackView.layoutIfNeeded()
    }
    
    func addViewItem(_ viewModel: EditFavouriteItemViewModel) {
        let itemView = EditFavouriteItemView()
        itemView.setViewModel(viewModel)
        self.stackView.addArrangedSubview(itemView)
        itemView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    func addViewFieldItem(_ viewModel: EditFavouriteItemViewModel) {
        let itemFieldView = EditFavouriteItemFieldView()
        itemFieldView.titleLabel.text = viewModel.title
        guard let fieldView =  self.createTextFieldWithId(NewFavouriteTextFieldViewModel(identifier: "", placeHolder: viewModel.description ?? "", maxLength: 50)) else { return  }
        itemFieldView.fieldContentView.addSubview(fieldView)
        self.stackView.addArrangedSubview(itemFieldView)
        NSLayoutConstraint.activate([
            itemFieldView.fieldContentView.topAnchor.constraint(equalTo: itemFieldView.titleLabel.bottomAnchor, constant: 12),
            itemFieldView.fieldContentView.heightAnchor.constraint(equalToConstant: 40),
            itemFieldView.titleLabel.topAnchor.constraint(equalTo: itemFieldView.topAnchor, constant: 14)
        ])
        fieldView.fullFit()
        itemFieldView.fieldContentView.layoutSubviews()
        itemFieldView.layoutIfNeeded()
    }
    
    func addViewFieldIBANItem(_ bankUtils: BankingUtilsProtocol, viewModel: EditFavouriteItemViewModel) {
        self.stackView.addArrangedSubview(itemIBANView)
        self.itemIBANView.configureIBANTextfieldAppearance(showFloatingTitle: false)
        self.itemIBANView.setDelegates(delegate: self, updatableDelegate: self)
        self.itemIBANView.setInfo(viewModel, bankUtils: bankUtils)
        self.presenter.fields.append(itemIBANView.validatableTextField)
        self.itemIBANView.layoutSubviews()
        self.ibanText = itemIBANView.text ?? ""
    }
}

extension EditFavouriteHolderAndAccountViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.ibanText = self.itemIBANView.text ?? ""
        self.presenter.validatableFieldChanged()
    }
}

extension EditFavouriteHolderAndAccountViewController: EditFavouriteItemIBANViewDelegate {
    func ibanDidBeginEditing() {
        self.updatableTextFieldDidUpdate()
    }
}

extension EditFavouriteHolderAndAccountViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"),
                                             accessibilityIdentifier: "generic_button_continue",
                                             action: self.didSelectContinueTextfield,
                                             actionType: .continueAction)
    }

    var associatedView: UIView {
        return self.scrollView
    }
}
