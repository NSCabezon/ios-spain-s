import Operative
import UIKit
import UI
import CoreFoundationLib

protocol NewFavouriteAliasViewProtocol: ValidatableFormViewProtocol, OperativeView {
    var ibanLisboaTextField: String { get }
    func addTextField(viewModels: [NewFavouriteTextFieldViewModel])
    func setBankingUtil(_ bankingUtils: BankingUtilsProtocol, controlDigitDelegate: IbanCccTransferControlDigitDelegate?)
    func showOldErrorData(_ description: LocalizedStylableText)
}

final class NewFavouriteAliasViewController: UIViewController {
    let presenter: NewFavouriteAliasPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    private let ibanView = IbanCccTransferView()
    var ibanLisboaTextField = ""
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
    
    init(nibName nibNameOrNil: String?, presenter: NewFavouriteAliasPresenterProtocol) {
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

private extension NewFavouriteAliasViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "pt_toolbar_title_createFavorite",
                                    header: .title(key: "share_title_transfers", style: .default))
        )
        builder.build(on: self, with: nil)
    }
    
    func createTextFieldWithId(_ viewModel: NewFavouriteTextFieldViewModel) -> UIView? {
        let lisboaTextFieldErrorView = LisboaTextFieldWithErrorView()
        guard let passwordTextField = lisboaTextFieldErrorView.textField else { return nil }
        let formattedText = UIFormattedCustomTextField()
        if let maxLength = viewModel.maxLength {
            formattedText.setMaxLength(maxLength: maxLength)
        }
        lisboaTextFieldErrorView.textField.accessibilityIdentifier = viewModel.identifier
        lisboaTextFieldErrorView.setHeight(48.0)
        passwordTextField.setEditingStyle(
            .writable(configuration: LisboaTextField.WritableTextField(
                        type: .floatingTitle,
                        formatter: UIFormattedCustomTextField(),
                        disabledActions: [],
                        keyboardReturnAction: nil,
                        textfieldCustomizationBlock: self.setupTextField(_:))))
        passwordTextField.placeholder = localized(viewModel.placeHolder)
        passwordTextField.updatableDelegate = self
        self.presenter.fields.append(passwordTextField)
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

extension NewFavouriteAliasViewController: NewFavouriteAliasViewProtocol {
    func setBankingUtil(_ bankingUtils: BankingUtilsProtocol, controlDigitDelegate: IbanCccTransferControlDigitDelegate?) {
        ibanView.setBankingUtil(bankingUtils,
                                controlDigitDelegate: controlDigitDelegate)
        ibanView.hideTooltip()
        ibanView.adjustSideMargins()
        ibanView.delegate = self
        ibanView.updatableDelegate = self
        ibanView.ibanLisboaTextField.fixedControlDigit = bankingUtils.textInputAttributes.checkDigit
        self.presenter.fields.append(ibanView.ibanLisboaTextField)
        self.ibanLisboaTextField = ibanView.text ?? ""
        self.stackView.addArrangedSubview(ibanView)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    
    func addTextField(viewModels: [NewFavouriteTextFieldViewModel]) {
        let views = viewModels.compactMap { self.createTextFieldWithId($0) }
        views.forEach(self.stackView.addArrangedSubview)
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    func showOldErrorData(_ description: LocalizedStylableText) {
        let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
        self.showOldDialog(title: localized("generic_alert_title_errorData"), description: description, acceptAction: acceptComponents, cancelAction: nil, isCloseOptionAvailable: false)
    }
}

extension NewFavouriteAliasViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.ibanLisboaTextField = self.ibanView.text ?? ""
        self.presenter.validatableFieldChanged()
    }
}

extension NewFavouriteAliasViewController: IbanCccTransferViewDelegate {
    func ibanDidBeginEditing() {
        self.updatableTextFieldDidUpdate()
    }
}

extension NewFavouriteAliasViewController: KeyboardManagerDelegate {
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
