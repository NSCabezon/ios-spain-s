import UIKit
import UI
import CoreFoundationLib
import Operative

public protocol TransferConfirmViewProtocol: LoadingViewPresentationCapable, DialogViewPresentationCapable, OldDialogViewPresentationCapable {
    var email: String? { get }
    func add(_ confirmationItems: [ConfirmationItemViewModel])
    func add(_ confirmationItem: ConfirmationItemViewModel)
    func setContinueTitle(_ text: String)
    func addTotalOperationAmount(_ amount: AmountEntity)
    func addText(_ text: String)
    func addEmail()
    func showInvalidEmail(_ error: String)
    func addBiometricValidationButton()
}

open class TransferConfirmViewController: UIViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var mainView: UIView!
    @IBOutlet weak private var additionalView: UIView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var buttonStackView: UIStackView!
    private var checkTextFieldView: CheckTextFieldView?
    private let presenter: TransferConfirmPresenterProtocol
    @IBOutlet weak var topSeparatorView: UIView!
    private var ibanUtils: BankingUtilsProtocol
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private var emailTextFieldProtocol: CheckTextFieldViewProtocol?
    private let widthMargin: CGFloat = 16.0
    public let keyboardManager = KeyboardManager()
    
    public init(presenter: TransferConfirmPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.ibanUtils = dependenciesResolver.resolve()
        super.init(nibName: "TransferConfirmViewController", bundle: .module)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.keyboardManager.setDelegate(self)
        self.keyboardManager.setKeyboardButtonEnabled(true)
    }
    
    open func addConfirmationItemView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    @objc private func continueButtonSelected() {
        self.presenter.didSelectContinue()
    }
    
    private func continueButtonSelectedTextfield(_ textfield: EditText) {
        self.continueButtonSelected()
    }
}

private extension TransferConfirmViewController {

    func setupView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.drawBorder(cornerRadius: 0, color: .mediumSkyGray)
        view.backgroundColor = .white
        view.addSubview(self.stackView)
        self.mainView.addSubview(view)
        view.fullFit()
        self.stackView.fullFit()
        self.view.backgroundColor = .skyGray
        self.separator.backgroundColor = .mediumSkyGray
        self.continueButton.addSelectorAction(target: self, #selector(continueButtonSelected))
        self.continueButton.accessibilityIdentifier = AccessibilityTransferConfirmation.button.rawValue
        self.mainView.accessibilityIdentifier = AccessibilityTransferConfirmation.areaCard.rawValue
        self.topSeparatorView.backgroundColor = .skyGray
    }
    
    func addAdditionalItemView(_ view: UIView) {
        self.additionalView.addSubview(view)
        view.fullFit()
    }
}

extension TransferConfirmViewController: TransferConfirmViewProtocol {
    public var email: String? {
        return self.emailTextFieldProtocol?.email
    }
    public var associatedDialogView: UIViewController {
        return self
    }
    
    public func setContinueTitle(_ text: String) {
        self.continueButton.setTitle(text, for: .normal)
    }
    
    public func add(_ confirmationItem: ConfirmationItemViewModel) {
        if self.ibanUtils.isValidIban(ibanString: confirmationItem.info?.string.replacingOccurrences(of: " ", with: "") ?? "") {
            let confirmationIbanItemView = ConfirmationIbanItemView(frame: .zero)
            confirmationIbanItemView.translatesAutoresizingMaskIntoConstraints = false
            confirmationIbanItemView.delegate = self
            confirmationIbanItemView.setup(with: confirmationItem)
            self.addConfirmationItemView(confirmationIbanItemView)
        } else {
            let confirmationItemView = ConfirmationItemView(frame: .zero)
            confirmationItemView.translatesAutoresizingMaskIntoConstraints = false
            confirmationItemView.setup(with: confirmationItem)
            self.addConfirmationItemView(confirmationItemView)
        }
    }
    
    public func add(_ confirmationItems: [ConfirmationItemViewModel]) {
        confirmationItems.forEach(add)
    }
    
    public func addTotalOperationAmount(_ amount: AmountEntity) {
        let view = ConfirmationTotalOperationItemView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = ConfirmationTotalOperationItemViewModel(amountEntity: amount)
        view.setup(with: viewModel)
        view.accessibilityIdentifier = AccessibilityTransferConfirmation.areaPrice.rawValue
        self.addConfirmationItemView(view)
    }
    
    public func addText(_ text: String) {
        let view = LisboaLabelView(text: text)
        self.view.accessibilityIdentifier = AccessibilityTransferConfirmation.textComision.rawValue
        self.addAdditionalItemView(view)
    }
    
    public func addEmail() {
        let checkTextFieldView = CheckTextFieldView()
        checkTextFieldView.configure(title: localized("sendMoney_label_notifyShipment").text,
                                     subtitle: localized("sendMoney_label_enterEmail").text)
        checkTextFieldView.delegate = self
        self.addAdditionalItemView(checkTextFieldView)
        self.emailTextFieldProtocol = checkTextFieldView
        self.checkTextFieldView = checkTextFieldView
        self.view.accessibilityIdentifier = AccessibilityTransferConfirmation.areaNotification.rawValue
    }

    public func showInvalidEmail(_ error: String) {
        self.checkTextFieldView?.showError(error)
    }
        
    public func addBiometricValidationButton() {
        let viewModel = LeftIconLisboaViewModel(
            image: "icnSantanderKeyLock",
            title: "ecommerce_button_confirmSanKey")
        let customFooterView = LeftIconLisboaButton(viewModel)
        customFooterView.addAction { [weak self] in
            self?.presenter.didSelectConfirmWithBiometrics()
        }
        self.addFooterView(customFooterView)
    }
}

extension TransferConfirmViewController: CheckTextFieldViewDelegate {
    public func didShowEmail() {
        self.keyboardManager.update()
    }
    public func didHideEmail() {
        self.keyboardManager.update()
    }
}

extension TransferConfirmViewController: KeyboardManagerDelegate {
    public var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_confirm"), accessibilityIdentifier: "transferConfirmationBtnConfirm", action: self.continueButtonSelectedTextfield)
    }
}

extension TransferConfirmViewController: ConfirmationIbanItemViewDelegate {
    public func didTapOnShare(_ iban: String) {
        self.presenter.didSelectShare(iban)
    }
}

extension TransferConfirmViewController {
    func addFooterView(_ view: UIView) {
        self.continueButton.isHidden = true
        self.buttonStackView.addArrangedSubview(view)
    }
}
