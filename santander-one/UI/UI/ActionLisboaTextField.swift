//
//  ActionLisboaTextField.swift
//  UI
//
//  Created by Laura González on 21/05/2020.
//

import CoreFoundationLib

public enum ActionViewStyle {
    case image
    case arrow
}

public struct ActionLisboaTextFieldStyle {
    public static var `default`: ActionLisboaTextFieldStyle {
        ActionLisboaTextFieldStyle()
    }
    
    public var backgroundColor: UIColor = .clear
    public var titleLabelTextColor = UIColor.grafite
    public var titleLabelFont = UIFont.santander(family: .text, type: .regular, size: 17)
    public var visibleTitleLabelFont = UIFont.santander(family: .text, type: .regular, size: 12)
    public var actionLabelTextColor = UIColor.white
    public var imageStyleLabelFont = UIFont.santander(family: .text, type: .regular, size: 10)
    public var infoViewBackgroundColor = UIColor.skyGray
    public var containerViewBorderColor = UIColor.mediumSkyGray.cgColor
    public var containerViewBorderWidth: CGFloat = 1
    public var actionViewBackgroundColor = UIColor.darkTorquoise
    public var verticalSeparatorBackgroundColor = UIColor.darkSky
    
    // field
    public var fieldBackgroundColor = UIColor.clear
    public var fieldTintColor = UIColor.darkTurqLight
    public var fieldTextColor = UIColor.lisboaGray
    public var fieldFont = UIFont.santander(family: .text, type: .regular, size: 17)
}

public class ActionLisboaTextField: UIView, ValidatableField {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var actionView: UIView!
    @IBOutlet private weak var arrowStyleView: UIView!
    @IBOutlet private weak var arrowStyleLabel: UILabel!
    @IBOutlet private weak var arrowStyleImage: UIImageView!
    @IBOutlet public weak var imageStyleView: UIView!
    @IBOutlet private weak var imageStyleImage: UIImageView!
    @IBOutlet private weak var imageStyleLabel: UILabel!
    @IBOutlet public weak var writeButton: UIButton!
    @IBOutlet private weak var verticalSeparator: UIView!
    @IBOutlet private weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet private var centrerConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet public weak var field: ConfigurableActionsTextField!
    private var tapEvent: UITapGestureRecognizer?
    private var extraAction: (() -> Void)?
    private var action: (() -> Void)?
    private var isEditingEnable = true
    private var updatedTextValue: String?
    private let expandedHeight: CGFloat = 24
    public var fieldValue: String?
    public var text: String? {
        return field?.text ?? field?.placeholder
    }
    
    public var fieldDelegate: UITextFieldDelegate? {
        didSet {
            field.delegate = fieldDelegate
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    public weak var updatableDelegate: UpdatableTextFieldDelegate?

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
    public func setText(_ text: String?) {
        self.field.text = text
        self.field.sendActions(for: .editingChanged)
        setAccessibility()
    }

    public func updateData(text: String?) {
        self.setText(text)
        self.changeFieldVisibility(isFieldVisible: text?.isEmpty == false, animated: false)
    }
    
    public func configure(with handler: TextFieldFormatter?,
                          actionViewStyle: ActionViewStyle,
                          title: String,
                          style: ActionLisboaTextFieldStyle = .default,
                          disabledActions: [TextFieldActions]? = nil,
                          badgeAccessibilityIdentifier: String? = nil) {
        configureFieldWith(style: style)
        setAppearanceWith(style: style)
        setActionViewWith(actionViewStyle, style: style)
        self.titleLabel.text = title
        self.field.setDisabledActions(disabledActions)
        self.field.text = nil
        self.setBadgeAccessibility(identifier: badgeAccessibilityIdentifier)
        self.changeFieldVisibility(isFieldVisible: false, animated: false)
        self.fieldDelegate = handler ?? self
        handler?.delegate = self
    }
    
    public func getLabelFont(_ style: ActionViewStyle) -> UIFont {
        switch style {
        case .image:
            return UIFont.santander(family: .text, type: .regular, size: 10)
        case .arrow:
            return UIFont.santander(family: .text, type: .regular, size: 14)
        }
    }
    
    public func configure(extraInfo: (image: UIImage?, action: (() -> Void)?)?) {
        self.actionView.isHidden = extraInfo == nil
        self.extraAction = extraInfo?.action
    }
    
    public func hideArrowStyleImage() {
        self.arrowStyleImage.isHidden = true
    }
    
    public func updateTitle(_ title: String?) {
        self.titleLabel.text = title
        setAccessibility()
    }
    
    public func updateActionLabel(_ title: String?) {
        self.arrowStyleLabel.text = title
    }
    
    public func updateImageLabel(_ localized: LocalizedStylableText) {
        self.imageStyleLabel.configureText(withLocalizedString: localized)
    }
    
    public override var isFirstResponder: Bool {
        return field.isFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        return field.becomeFirstResponder()
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    public func addExtraAction(_ action: (() -> Void)?) {
        self.extraAction = action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchActionButton))
        self.tapEvent = tapGesture
        if let optionalGesture = self.tapEvent {
            self.actionView.addGestureRecognizer(optionalGesture)
        }
    }
    
    public func disableTextFieldEditing() {
        self.isEditingEnable = false
        self.field.isUserInteractionEnabled = self.isEditingEnable
    }

    public func setErrorAppearance() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        self.titleLabel.textColor = .bostonRed
        self.verticalSeparator.backgroundColor = .bostonRed
    }

    public func clearErrorAppearanceWithTitleVisible() {
        guard text?.isEmpty == false else { return }
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.titleLabel.textColor =  UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)
        self.verticalSeparator.backgroundColor = .darkSky
    }

    // MARK: - Actions
    
    @IBAction func editField() {
        guard isEditingEnable else { return }
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
        self.field.becomeFirstResponder()
    }
    
    @objc private func touchActionButton() {
        extraAction?()
    }
    
    @IBAction func didSelectWriteButton() {
        self.action?()
    }
    
    public func setArrowAccessibility(_ label: String?) {
        self.arrowStyleLabel.accessibilityLabel = label
    }
}

// MARK: - UITextFieldDelegate

extension ActionLisboaTextField: UITextFieldDelegate {
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let isEmptyField = self.isEmptyField(with: textField)
        self.changeFieldVisibility(isFieldVisible: !isEmptyField, animated: true)
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
        return true
    }

    @objc
    public func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
        self.updatableDelegate?.updatableTextFieldDidUpdate()
    }
}

private extension ActionLisboaTextField {
    func configureFieldWith(style: ActionLisboaTextFieldStyle) {
        self.field.backgroundColor = style.fieldBackgroundColor
        self.field.tintColor = style.fieldTintColor
        self.field.textColor = style.fieldTextColor
        self.field.font = style.fieldFont
    }
    
    func changeFieldVisibility(isFieldVisible: Bool, animated: Bool) {
        let style = ActionLisboaTextFieldStyle.default
        self.writeButton.isHidden = isFieldVisible
        self.writeButton.addTarget(self, action: #selector(didSelectWriteButton), for: .touchUpInside)
        self.titleLabel.font = isFieldVisible ? style.visibleTitleLabelFont : style.titleLabelFont
        self.field.isHidden = !isFieldVisible
        self.fieldHeight.constant = isFieldVisible ? self.expandedHeight: 0
        self.centrerConstraint.isActive = !isFieldVisible
        self.bottomConstraint.isActive = isFieldVisible
        
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

    func setAppearanceWith(style: ActionLisboaTextFieldStyle) {
        self.backgroundColor = style.backgroundColor
        self.actionView.backgroundColor = style.actionViewBackgroundColor
        self.infoView.backgroundColor = style.infoViewBackgroundColor
        self.verticalSeparator.backgroundColor = style.verticalSeparatorBackgroundColor
        self.titleLabel.font = style.titleLabelFont
        self.titleLabel.textColor = style.titleLabelTextColor
        self.containerView.layer.borderColor = style.containerViewBorderColor
        self.containerView.layer.borderWidth = style.containerViewBorderWidth
        self.writeButton.backgroundColor = .clear
    }
    
    func setActionViewWith(_ actionStyle: ActionViewStyle, style: ActionLisboaTextFieldStyle) {
        switch actionStyle {
        case .arrow:
            arrowStyleView.isHidden = false
            imageStyleView.isHidden = true
            arrowStyleLabel.font = getLabelFont(.arrow)
            arrowStyleLabel.font = getLabelFont(.arrow)
            arrowStyleLabel.textColor = style.actionLabelTextColor
            arrowStyleImage.image = Assets.image(named: "icnArrowDownSlimWhite8Pt")
        case .image:
            arrowStyleView.isHidden = true
            imageStyleView.isHidden = false
            imageStyleLabel.font = getLabelFont(.image)
            imageStyleLabel.textColor = style.actionLabelTextColor
            imageStyleLabel.accessibilityIdentifier = "sendMoneyBtnFavorites"
            self.imageStyleImage.image = Assets.image(named: "icnHintFavourite")
            self.imageStyleLabel.configureText(withKey: "generic_button_favorites")
        }
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
    
    func setAccessibilityIdentifiers() {
        self.field.accessibilityIdentifier = AccessibilityOthers.areaInputText.rawValue
    }
    
    func setAccessibility() {
        self.titleLabel.accessibilityElementsHidden = true
        self.field.accessibilityLabel = titleLabel.text
        self.arrowStyleLabel.isAccessibilityElement = true
        self.setAccessibilityIdentifiers()
    }
    
    func setBadgeAccessibility(identifier: String?) {
        guard let accessibilityIdentifier = identifier else { return }
        self.actionView.accessibilityIdentifier = accessibilityIdentifier
        self.arrowStyleLabel.accessibilityIdentifier = "\(accessibilityIdentifier)_label"
    }
}
