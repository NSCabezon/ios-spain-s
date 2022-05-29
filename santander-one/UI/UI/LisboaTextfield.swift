import CoreFoundationLib

public struct LisboaTextFieldStyle: Equatable {
    
    public static var `default`: LisboaTextFieldStyle {
        LisboaTextFieldStyle()
    }
    
    public var backgroundColor: UIColor = .clear
    public var titleLabelFont = UIFont.santander(family: .text, type: .regular, size: 17)
    public var visibleTitleLabelFont = UIFont.santander(family: .text, type: .regular, size: 12)
    public var titleLabelTextColor = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)
    public var containerViewBackgroundColor = UIColor.skyGray
    public var containerViewBorderColor = UIColor.mediumSkyGray.cgColor
    public var containerViewBorderWidth: CGFloat = 1
    public var extraInfoViewBackgroundColor = UIColor.skyGray
    public var extraInfoHorizontalSeparatorBackgroundColor = UIColor.mediumSkyGray
    public var verticalSeparatorBackgroundColor = UIColor.darkTurqLight
    
    // field
    public var fieldBackgroundColor = UIColor.clear
    public var fieldTintColor = UIColor.darkTurqLight
    public var fieldTextColor = UIColor.lisboaGray
    public var fieldFont = UIFont.santander(family: .text, type: .regular, size: 17)

}

@available(*, deprecated, message: "Use LisboaTextField instead")
public class LisboaTextfield: UIView, ValidatableField {
    // MARK: - IBOutlet
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackview: UIStackView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var writteButton: UIButton!
    @IBOutlet private weak var extraInfoView: UIView!
    @IBOutlet private weak var extraInfoImageView: UIImageView!
    @IBOutlet private weak var extraInfoHorizontalSeparator: UIView!
    @IBOutlet private weak var verticalSeparator: UIView!
    @IBOutlet public weak var field: ConfigurableActionsTextField!
    @IBOutlet private weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet private var centrerConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet private weak var containerStackView: UIStackView!
    // MARK: - Private Var
    private var extraAction: (() -> Void)?
    private var action: (() -> Void)?
    private var hitReturnKeyAction: (() -> Void)?
    private let expandedHeight: CGFloat = 24
    private var isEditingEnable = true
    private var allowOnlyCharacterSet: CharacterSet?
    private var customStyle: LisboaTextFieldStyle?
    private var maxCharacters: Int?
    private var isNeededFloatingTitle = true
    // MARK: - Public Var
    public var fieldValue: String?
    public var fieldDelegate: UITextFieldDelegate? {
        didSet {
            field.delegate = fieldDelegate
        }
    }
    public var text: String? {
        return field?.text ?? field?.placeholder
    }
    public weak var updatableDelegate: UpdatableTextFieldDelegate? {
        didSet {
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    // MARK: - Class Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Public Methods
    
    public func updateData(text: String?) {
        self.field.text = text
        self.field.sendActions(for: .editingChanged)
        self.changeFieldVisibility(isFieldVisible: text?.isEmpty == false, animated: false)
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    public func updateTextFieldColor(separator: UIColor, borders: UIColor) {
        self.backgroundColor = borders
        self.containerView.layer.borderColor = borders.cgColor
        self.verticalSeparator.backgroundColor = separator
    }
    
    public func configure(with handler: TextFieldFormatter?,
                          title: String,
                          style: LisboaTextFieldStyle = .default,
                          extraInfo: (image: UIImage?, action: (() -> Void)?)?,
                          disabledActions: [TextFieldActions]? = nil,
                          imageAccessibilityIdentifier: String? = nil) {
        configureFieldWith(style: style)
        setAppearanceWith(style: style)
        self.titleLabel.text = title
        self.field.setDisabledActions(disabledActions)
        self.field.text = nil
        self.extraInfoView.isHidden = extraInfo == nil
        self.extraInfoImageView?.image = extraInfo?.image
        self.extraAction = extraInfo?.action
        self.changeFieldVisibility(isFieldVisible: false, animated: false)
        self.fieldDelegate = handler ?? self
        handler?.delegate = self
        self.extraInfoImageView.isAccessibilityElement = true
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
        self.setImageAccessibility(identifier: imageAccessibilityIdentifier)
    }
    
    public func configure(extraInfo: (image: UIImage?, action: (() -> Void)?)?) {
        self.extraInfoView.isHidden = extraInfo == nil
        self.extraInfoImageView.image = extraInfo?.image
        self.extraAction = extraInfo?.action
    }
    
    public func updateTitle(_ title: String?) {
        self.titleLabel.text = title
        self.changeFieldVisibility(isFieldVisible: false, animated: false)
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    public override var isFirstResponder: Bool {
        return field.isFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        return field.becomeFirstResponder()
    }

    public func setCustomeExtraInfoView(_ view: UIView) {
        self.extraInfoImageView.removeFromSuperview()
        self.extraInfoView.addSubview(view)
        self.extraInfoView.bringSubviewToFront(actionButton)
        self.actionButton.accessibilityElementsHidden = true
        view.fullFit()
    }
    
    public func setRightViewOffset(_ offset: (x: CGFloat, y: CGFloat)) {
        self.field.rightViewOffset = offset
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    public func addExtraAction(_ action: (() -> Void)?) {
        self.extraAction = action
    }
    
    public func disableTextFieldEditing() {
        self.isEditingEnable = false
        self.field.isUserInteractionEnabled = self.isEditingEnable
    }
    
    public func setAccessibleIdentifiers(titleLabelIdentifier: String? = nil, fieldIdentifier: String? = nil, imageIdentifier: String? = nil) {
        self.extraInfoImageView.isAccessibilityElement = true
        self.setAccessibility { self.extraInfoImageView.isAccessibilityElement = false }
        self.titleLabel.accessibilityIdentifier = titleLabelIdentifier
        self.field.accessibilityIdentifier = fieldIdentifier
        self.extraInfoImageView.accessibilityIdentifier = imageIdentifier
    }
    // MARK: - Actions
    
    @IBAction func editField() {
        guard isEditingEnable else { return }
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
        self.field.becomeFirstResponder()
    }
    
    @IBAction func touchExtraAction() {
        extraAction?()
    }
    
    @IBAction func didSelectWritteButton() {
        self.action?()
    }

    public func setErrorAppearance() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        self.titleLabel.textColor = .bostonRed
        self.verticalSeparator.backgroundColor = .bostonRed
    }

    public func clearErrorAppearanceWithFieldVisible() {
        guard text?.isEmpty == false else { return }
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.titleLabel.textColor =  UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)
        self.verticalSeparator.backgroundColor = .darkSky
    }

    public func configureFieldWith(style: LisboaTextFieldStyle) {
        self.field.backgroundColor = style.fieldBackgroundColor
        self.field.tintColor = style.fieldTintColor
        self.field.textColor = style.fieldTextColor
        self.field.font = style.fieldFont
        self.verticalSeparator.backgroundColor = style.verticalSeparatorBackgroundColor
    }
    
    public func setAllowOnlyCharacters(_ characterSet: CharacterSet) {
        self.allowOnlyCharacterSet = characterSet
    }
    
    public func setRecturnAction(_ action: (() -> Void)?) {
        self.hitReturnKeyAction = action
    }
    
    public func setCustomStyle(_ style: LisboaTextFieldStyle) {
        self.customStyle = style
    }
    
    public func setMaxCharacters(_ maxCharacters: Int) {
        self.maxCharacters = maxCharacters
    }

    public func setIsNeededFloatingTitle(_ isNeeded: Bool) {
        self.isNeededFloatingTitle = isNeeded
    }
    
    func setAccessibility() {
        writteButton.accessibilityElementsHidden = true
        field.accessibilityLabel = "\(titleLabel.text ?? "")."
        extraInfoImageView.isAccessibilityElement = false
        extraInfoView.isAccessibilityElement = true
    }
    
    func setImageAccessibility(identifier: String?) {
        guard let accessibilityIdentifier = identifier else { return }
        self.extraInfoView.accessibilityIdentifier = identifier
    }
    
    public func setAccesibilityExtraInfo(accessibilityLabel: String) {
        extraInfoView.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - UITextFieldDelegate

extension LisboaTextfield: UITextFieldDelegate {
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeFieldVisibility(isFieldVisible: !isEmptyField, animated: true)
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeFieldVisibility(isFieldVisible: !isEmptyField, animated: true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeFieldVisibility(isFieldVisible: !isEmptyField, animated: true)
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.field.resignFirstResponder()
        self.hitReturnKeyAction?()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard characterSetOk(string) else { return false }
        guard let maxCharacters = maxCharacters else { return true }
        if let text = field.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.count > maxCharacters {
                field.text = String(updatedText.prefix(maxCharacters))
                return false
            }
        }
        return true
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
        self.updatableDelegate?.updatableTextFieldDidUpdate()
    }
}

// MARK: - Private Functions

private extension LisboaTextfield {
    
    func characterSetOk(_ string: String) -> Bool {
        guard let characterSet = allowOnlyCharacterSet else { return true }
        let character = CharacterSet(charactersIn: string)
        return characterSet.isSuperset(of: character)
    }
    
    func changeFieldVisibility(isFieldVisible: Bool, animated: Bool) {
        let style = customStyle ?? LisboaTextFieldStyle.default
        self.writteButton.isHidden = isFieldVisible
        self.writteButton.addTarget(self, action: #selector(didSelectWritteButton), for: .touchUpInside)
        self.titleLabel.font = isFieldVisible ? style.visibleTitleLabelFont : style.titleLabelFont
        self.field.isHidden = !isFieldVisible
        self.fieldHeight.constant = isFieldVisible ? self.expandedHeight: 0
        self.centrerConstraint.isActive = !isFieldVisible
        self.bottomConstraint.isActive = isFieldVisible
        self.hideTitleLabelIfNeeded(fieldVisible: isFieldVisible)
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.layoutIfNeeded()
        }
    }

    private func hideTitleLabelIfNeeded(fieldVisible: Bool) {
        if isNeededFloatingTitle {
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = fieldVisible
        }
    }
    
    func setAppearanceWith(style: LisboaTextFieldStyle) {
        self.backgroundColor = style.backgroundColor
        self.titleLabel.font = style.titleLabelFont
        self.titleLabel.textColor = style.titleLabelTextColor
        self.containerView.backgroundColor = style.containerViewBackgroundColor
        self.containerView.layer.borderColor = style.containerViewBorderColor
        self.containerView.layer.borderWidth = style.containerViewBorderWidth
        self.extraInfoView.backgroundColor = style.extraInfoViewBackgroundColor
        self.extraInfoHorizontalSeparator.backgroundColor = style.extraInfoHorizontalSeparatorBackgroundColor
        self.verticalSeparator.backgroundColor = style.verticalSeparatorBackgroundColor
    }
    
    func setupView() {
        self.xibSetup()
        self.setAppearanceWith(style: .default)
    }
    
    func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func isEmptyField(with textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let placeholder = textField.placeholder ?? ""
        return text.isEmpty && placeholder.isEmpty
    }
}

extension LisboaTextfield: AccessibilityCapable { }
