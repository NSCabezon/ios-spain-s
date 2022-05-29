import Foundation
import CoreFoundationLib

public protocol CheckTextFieldViewProtocol {
    var title: String? { get }
    var subtitle: String? { get }
    var selected: Bool? { get }
    var email: String? { get }
}

public protocol CheckTextFieldViewDelegate: AnyObject {
    func didShowEmail()
    func didHideEmail()
}

public class CheckTextFieldView: XibView {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak private var containerLisboaTextField: UIView!
    @IBOutlet weak private var lisboaTextFieldView: LisboaTextFieldWithErrorView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    public var emailTextField: LisboaTextField { lisboaTextFieldView.textField }
    public weak var delegate: CheckTextFieldViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    public func configure(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }

    public func showError(_ error: String) {
        self.lisboaTextFieldView.showError(error)
    }
}

private extension CheckTextFieldView {
    func setupViews() {
        self.containerLisboaTextField.isHidden = true
        self.checkButton.isSelected = false
        self.checkButton.setImage(Assets.image(named: "checkboxSelected"), for: UIControl.State.selected)
        self.checkButton.setImage(Assets.image(named: "checkboxDefault"), for: UIControl.State.normal)
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 14.0)
        self.titleLabel.textColor = .mediumSanGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 12.0)
        self.subtitleLabel.textColor = .mediumSanGray
        self.applyGradient()
        self.configureEmailTextFieldWithError()
        self.setAccessibility()
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        self.checkButton.isSelected = !self.checkButton.isSelected
        if self.checkButton.isSelected {
            self.showEmail()
            self.checkButton.accessibilityIdentifier = AccessibilityTransferConfirmation.icnCheckBoxSelectedGreen.rawValue
        } else {
            self.hideEmail()
            self.checkButton.accessibilityIdentifier = AccessibilityTransferConfirmation.icnCheckBoxUnSelected.rawValue
        }
    }
    
    func hideEmail() {
        self.containerLisboaTextField.isHidden = true
        self.emailTextField.setText(nil)
        self.delegate?.didHideEmail()
    }
    
    func showEmail() {
        self.containerLisboaTextField.isHidden = false
        self.lisboaTextFieldView.hideError()
        self.delegate?.didShowEmail()
    }

    func automatization() {
        self.checkButton.accessibilityIdentifier = ""
    }
    
    func applyGradient() {
        self.topGradient.applyGradientBackground(colors: [.mediumSkyGray, .white])
        self.bottomGradient.applyGradientBackground(colors: [.white, .mediumSkyGray])
    }

    func configureEmailTextFieldWithError() {
        self.emailTextField.accessibilityIdentifier = AccessibilityTransferConfirmation.areaInputText.rawValue
        let textFormatter = UIFormattedCustomTextField()
        textFormatter.setAllowOnlyCharacters(.email)
        self.emailTextField.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                       formatter: textFormatter,
                                                                                                       disabledActions: [],
                                                                                                       keyboardReturnAction: nil,
                                                                                                       textfieldCustomizationBlock: self.setupTextField(_:))))
        self.emailTextField.placeholder = localized("generic_label_email")
        self.emailTextField.setRightAccessory(.image("icnPlainInputGreen", action: {}))
    }

    func setupTextField(_ components: LisboaTextField.CustomizableComponents) {
        components.textField.addTarget(self, action: #selector(hideError), for: .editingChanged)
    }
    
    func setAccessibility() {
        self.lisboaTextFieldView.textField.accessibilityIdentifier = AccessibilityOthers.areaInputText.rawValue
    }

    @objc func hideError() {
        self.lisboaTextFieldView.hideError()
    }
}

extension CheckTextFieldView: CheckTextFieldViewProtocol {
    public var title: String? {
        self.titleLabel.text
    }
    public var subtitle: String? {
        self.subtitleLabel.text
    }
    public var selected: Bool? {
        self.checkButton.isSelected
    }
    public var email: String? {
        self.emailTextField.text
    }
}
