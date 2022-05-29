import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine

public protocol OneInputAmountViewDelegate: AnyObject {
    func textFieldDidChange()
    func textFielEndEditing()
}

// Reactive
public protocol ReactiveOneInputAmountView {
    var publisher: AnyPublisher<ReactiveOneInputAmountViewState, Never> { get }
}
public enum ReactiveOneInputAmountViewState: State {
    case textFieldDidChange
    case textFieldDidEndEditing
}

public final class OneInputAmountView: XibView {

    // Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneInputAmountViewState, Never>()

    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var rightAmountInitialsLabel: UILabel!
    @IBOutlet private weak var rightImageView: UIImageView!
    private var fieldDelegate: TextFieldFormatter?
    weak public var delegate: OneInputAmountViewDelegate?
    public var fieldValue: String?
    public var status: OneStatus? {
        didSet {
            self.configureViewState(status ?? .activated)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setupTextField(_ viewModel: OneInputAmountViewModel) {
        self.status = viewModel.status
        if let text = viewModel.amount {
            self.inputTextField.text = text
        }
        self.inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.inputTextField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder ?? "0" + String(NumberFormattingHandler.shared.getDecimalSeparator()) + "00",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.oneLisboaGray.withAlphaComponent(0.5)])
        self.configureCurrency(viewModel)
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public func textFieldFirstResponder() {
        self.inputTextField.becomeFirstResponder()
    }

    public func isTextFieldFirstResponder() -> Bool {
        return self.inputTextField.isFirstResponder
    }
    
    public func isTextFieldEmpty() -> Bool {
        return self.inputTextField.text?.isEmpty ?? true
    }
    
    public func getAmount() -> String {
        return self.inputTextField.text ?? ""
    }
    
    public func setAmount(_ amount: String) {
        self.inputTextField.text = amount
    }
}

extension OneInputAmountView: ValidatableField { }

private extension OneInputAmountView {
    func configureView() {
        self.configureViews()
        self.configureTextField()
        self.configureLabel()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        self.setOneCornerRadius(type: .oneShRadius8)
        self.layer.borderWidth = 1
    }
    
    func configureTextField() {
        self.inputTextField.tintColor = .oneLisboaGray
        self.inputTextField.font = .typography(fontName: .oneH500Regular)
        self.inputTextField.keyboardType = .decimalPad
        self.fieldDelegate = UIAmountTextFieldFormatter()
        self.fieldDelegate?.delegate = self
        self.inputTextField.delegate = self.fieldDelegate
        self.fieldValue = self.inputTextField.text
        self.setDoneKeyboardButton()
    }
    
    func configureLabel() {
        self.rightAmountInitialsLabel.font = .typography(fontName: .oneB300Regular)
        self.rightAmountInitialsLabel.textColor = .oneLisboaGray
    }
    
    func configureCurrency(_ viewModel: OneInputAmountViewModel) {
        switch viewModel.type {
        case .icon:
            self.showCurrency(labelHidden: true, imageHidden: false)
        case .text:
            self.showCurrency(labelHidden: false, imageHidden: true)
        case .unowned:
            self.showCurrency(labelHidden: true, imageHidden: true)
        }
        self.rightImageView.image = Assets.image(named: NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn())
        self.rightAmountInitialsLabel.text = viewModel.amountRepresentable?.currencyRepresentable?.currencyName ?? NumberFormattingHandler.shared.getDefaultCurrencyText()
    }
    
    func showCurrency(labelHidden: Bool, imageHidden: Bool) {
        self.rightAmountInitialsLabel.isHidden = labelHidden
        self.rightImageView.isHidden = imageHidden
    }
    
    func configureViewState(_ status: OneStatus) {
        self.setOneShadows(type: status == .disabled ? .none : .oneShadowSmall)
        self.backgroundColor = status == .disabled ? .oneLightGray40 : .white
        self.inputTextField.textColor = status == .disabled ? .oneBrownishGray : .oneLisboaGray
        self.inputTextField.isEnabled = status != .disabled
        switch status {
        case .inactive, .activated:
            self.layer.borderColor = UIColor.oneBrownGray.cgColor
        case .focused:
            self.layer.borderColor = UIColor.oneDarkTurquoise.cgColor
        case .disabled:
            self.layer.borderColor = UIColor.clear.cgColor
        case .error:
            self.layer.borderColor = UIColor.oneBostonRed.cgColor
        }
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputAmountView + (suffix ?? "")
        self.inputTextField.accessibilityIdentifier = AccessibilityOneComponents.oneInputAmountTextField + (suffix ?? "")
        self.rightAmountInitialsLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputAmountLabelRight + (suffix ?? "")
        self.rightImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputAmountIcnRight + (suffix ?? "")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.textFieldDidChange()
        self.stateSubject.send(.textFieldDidChange)
    }
    
    func setDoneKeyboardButton() {
        guard let toolbar = self.inputTextField.setToolbarDoneButton(completion: {
            self.toolbarDoneTapButton()
        }) else { return }
        self.inputTextField.inputAccessoryView = toolbar
    }
    
    func toolbarDoneTapButton() {
        self.endEditing(true)
        self.textFieldDidEndEditing(self.inputTextField)
    }
}

extension OneInputAmountView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.status = .focused
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.status = .activated
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.status = .activated
        self.delegate?.textFielEndEditing()
        self.stateSubject.send(.textFieldDidEndEditing)
        return true
    }
}

extension OneInputAmountView: OneComponentStatusProtocol {
    public func showError(_ error: String?) {
        self.status = .error
    }
    
    public func hideError() {
        self.status = .activated
    }
}

extension OneInputAmountView: ReactiveOneInputAmountView {
    public var publisher: AnyPublisher<ReactiveOneInputAmountViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
