//
//  LisboaTextField.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 27/05/2020.
//

import UIKit
import CoreFoundationLib

protocol LisboaTextFieldViewProtocol: UIView, UITextFieldDelegate, ValidatableField, LisboaTextFieldStyleProtocol {
    var mainStackView: UIStackView! { get set }
    var bottomBorderView: UIView! { get set }
    var placeholder: String? { get set }
    var textFieldPlaceholder: String? { get set }
    var style: LisboaTextFieldStyle { get set }
    var text: String? { get set }
    var adjustTextSize: LisboaTextField.TextScaleType { get set }
    var updatableDelegate: UpdatableTextFieldDelegate? { get set }
    func setup()
}

protocol TextFieldDelegateConfigurable: AnyObject {
    var fieldDelegate: UITextFieldDelegate? { get set }
}

protocol CustomizableTextFieldProtocol {
    func setRightViewOffset(_ offset: (x: CGFloat, y: CGFloat))
}

protocol LisboaTextFieldStyleProtocol {
    func updateStyleIfNeed()
}

protocol LisboaTextFieldResignableProtocol {
    func hideKeyboard()
}

extension LisboaTextFieldStyleProtocol {
    func updateStyleIfNeed() {}
}

open class LisboaTextField: UIView {
    
    // MARK: - Init
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    // MARK: - Public attributes
    
    public private(set) var text: String?
    public var placeholder: String? {
        didSet {
            self.textFieldContainerView?.placeholder = self.placeholder
        }
    }
    public var textFieldPlaceholder: String? {
        didSet {
            self.textFieldContainerView?.textFieldPlaceholder = textFieldPlaceholder
        }
    }
    public var updatableDelegate: UpdatableTextFieldDelegate? {
        get {
            return self.textFieldContainerView?.updatableDelegate
        }
        set {
            self.textFieldContainerView?.updatableDelegate = newValue
        }
    }
    
    public var fieldDelegate: UITextFieldDelegate? {
        didSet {
            guard let delegateConfigurable = self.textFieldContainerView as? TextFieldDelegateConfigurable else { return }
            delegateConfigurable.fieldDelegate = self.fieldDelegate
        }
    }
    
    // MARK: - Private attributes
    private var textFieldContainerView: LisboaTextFieldViewProtocol?
    private var editingStyle: EditingStyle = .writable(configuration: WritableTextField(type: .simple))
    private var rightAccessory: RightAccessory = .none
    private var clearAccessory: ClearAccessory = .none
    private var clearView: LisboaClearView?
    private var style: LisboaTextFieldStyle = .default {
        didSet {
            self.textFieldContainerView?.style = style
        }
    }
    public var adjustType: TextScaleType = .none {
        didSet {
            self.textFieldContainerView?.adjustTextSize = adjustType
        }
    }
    public var separatorMargin: CGFloat = 10
    private var state: SecureState = .secure {
        didSet {
            self.updateIconMode()
        }
    }
    private var secureImages: (secureImage: String?, notSecureImage: String?)

    private lazy var errorStyle: LisboaTextFieldStyle = {
        var errorStyle = self.style
        errorStyle.verticalSeparatorBackgroundColor = .bostonRed
        errorStyle.titleLabelTextColor = .bostonRed
        errorStyle.titleLabelFont = .santander(family: .text, type: .regular, size: 10)
        return errorStyle
    }()
    
    // MARK: - Public methods
    
    public func setEditingStyle(_ editingStyle: EditingStyle) {
        self.editingStyle = editingStyle
        self.setupEditingStyle()
    }
    
    public func setRightAccessory(_ rightAccessory: RightAccessory, identifier: String? = nil) {
        self.rightAccessory = rightAccessory
        self.setupRightAccessory(identifier: identifier)
    }
    
    public func setClearAccessory(_ clearAccessory: ClearAccessory) {
        self.clearAccessory = clearAccessory
        self.setUpClearAccessory()
    }
    
    public func setStyle(_ style: LisboaTextFieldStyle) {
        self.style = style
    }
    
    public func setPlaceholder(_ placeholder: String) {
        self.placeholder = placeholder
    }
    
    public func setText(_ text: String?) {
        self.text = text
        self.fieldValue = text
        self.textFieldContainerView?.text = self.text
        self.isClearAccessoryVisible(self.text)
    }

    public func setAdjustFontSizeType(_ adjustType: TextScaleType) {
        self.adjustType = adjustType
    }

    @available(*, deprecated, message: " Please use setErrorAppearanceIfNeeded() ")
    public func setErrorAppearance() {
        self.setErrorAppearanceIfNeeded()
    }

    public func setErrorAppearanceIfNeeded() {
        if text?.count ?? 0 > 0 {
            self.textFieldContainerView?.style = self.errorStyle
            self.textFieldContainerView?.updateStyleIfNeed()
        }
    }

    public func clearErrorAppearanceIfNeeded() {
        if self.textFieldContainerView?.style != self.style {
            self.clearErrorAppearance()
        }
    }
 
    public func clearErrorAppearance() {
        self.textFieldContainerView?.style = self.style
        self.textFieldContainerView?.updateStyleIfNeed()
    }

    func setRightViewOffset(_ offset: (x: CGFloat, y: CGFloat)) {
        guard let customizable = self.textFieldContainerView as? CustomizableTextFieldProtocol else { return }
        customizable.setRightViewOffset(offset)
    }

    public func setTextFieldFocus() {
        guard let textFieldNotifiable = self.textFieldContainerView as? TextFieldNotifiableProtocol else { return }
        textFieldNotifiable.setTextFieldFocus()
    }
    
    public override func resignFirstResponder() -> Bool {
        guard let textFieldResignable = self.textFieldContainerView as? LisboaTextFieldResignableProtocol else { return super.resignFirstResponder() }
        textFieldResignable.hideKeyboard()
        return true
    }
    
    // MARK: - Private
    
    @objc func didSelectOverTextFieldButton() {
        switch self.editingStyle {
        case .writable:
            break
        case .actionable(configuration: let configuration):
            configuration.action()
        }
    }
}

// MARK: - Setup

private extension LisboaTextField {
    
    func setup() {
        self.resetTextFieldContainerIfNeeded()
        self.setupTextFieldContainer()
        self.setupFieldDelegate()
        self.setUpClearAccessory()
        self.setupRightAccessory()
    }
    
    func resetTextFieldContainerIfNeeded() {
        if self.textFieldContainerView != nil {
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.textFieldContainerView = nil
        }
    }
    
    func setupTextFieldContainer() {
        let textFieldContainerView = LisboaTextFieldFactory(editingStyle: self.editingStyle).get()
        textFieldContainerView.setup()
        self.addSubview(textFieldContainerView)
        textFieldContainerView.fullFit()
        textFieldContainerView.bottomBorderView.backgroundColor = self.style.verticalSeparatorBackgroundColor
        self.textFieldContainerView = textFieldContainerView
        self.textFieldContainerView?.text = self.text
        self.textFieldContainerView?.placeholder = self.placeholder
    }
    
    func setupFieldDelegate() {
        switch self.editingStyle {
        case .writable(configuration: let configuration):
            let formatter = configuration.formatter ?? UIFormattedCustomTextField()
            self.fieldDelegate = formatter
            formatter.customDelegate = self
        default:
            break
        }
    }
    
    func setupEditingStyle() {
        switch self.editingStyle {
        case .writable:
            self.setup()
        case .actionable:
            self.setup()
        }
    }

    func tapOnSecureImage() {
        switch self.state {
        case .secure:
            self.state = .char
        case .char:
            self.state = .secure
        }
        if let changeDelegate = self.fieldDelegate as? SecureTextFieldFormatter {
            changeDelegate.changeFormatter(state: self.state)
        }
    }
    
    func updateIconMode() {
        guard let secureImage = self.secureImages.secureImage,
              let notSecureImage = self.secureImages.notSecureImage else { return }
        switch self.state {
        case .secure:
            self.changeImageRightAccessory(secureImage)
        case .char:
            self.changeImageRightAccessory(notSecureImage)
        }
    }
    
    func changeImageRightAccessory(_ imageName: String?) {
        guard let view = self.textFieldContainerView?.mainStackView.allSubViewsOf(type: LisboaTextFieldRightImageView.self).first else { return }
        view.changeImage(imageName)
    }
}

extension LisboaTextField: ValidatableField {
    
    public var fieldValue: String? {
        get {
            return self.textFieldContainerView?.fieldValue
        }
        set {
            self.textFieldContainerView?.fieldValue = newValue
        }
    }
}

// MARK: - RightAccessory

private extension LisboaTextField {
    
    func setupRightAccessory(identifier: String? = nil) {
        switch self.rightAccessory {
        case .none: break
        case .image(let imageName, action: let action):
            self.addVerticalSeparator()
            let view = LisboaTextFieldRightImageView(imageName: imageName, action: action)
            view.widthAnchor.constraint(equalToConstant: 43).isActive = true
            view.setAccessibilityIdentifier(identifier: identifier)
            self.textFieldContainerView?.mainStackView.addArrangedSubview(view)
        case .uiImage(let image, action: let action):
            self.addVerticalSeparator()
            let view = LisboaTextFieldRightImageView(image: image, action: action)
            view.widthAnchor.constraint(equalToConstant: 43).isActive = true
            view.setAccessibilityIdentifier(identifier: identifier)
            self.textFieldContainerView?.mainStackView.addArrangedSubview(view)
        case .view(let view):
            self.addVerticalSeparator()
            view.accessibilityIdentifier = identifier
            self.textFieldContainerView?.mainStackView.addArrangedSubview(view)
        case .actionView(let view, let action):
            self.addVerticalSeparator()
            view.accessibilityIdentifier = identifier
            self.setRightActionView(view: view, action: action)
        case .secure(let image1, let image2):
            self.addVerticalSeparator()
            self.state = .secure
            guard let image = image1 else { return }
            let view = LisboaTextFieldRightImageView(imageName: image, action: self.tapOnSecureImage)
            self.secureImages = (image1, image2)
            view.widthAnchor.constraint(equalToConstant: 43).isActive = true
            view.setAccessibilityIdentifier(identifier: identifier)
            self.textFieldContainerView?.mainStackView.addArrangedSubview(view)
        }
    }
    
    func addVerticalSeparator() {
        let verticalSeparator = UIView()
        verticalSeparator.backgroundColor = self.style.backgroundColor
        verticalSeparator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        let verticalLine = UIView()
        verticalLine.backgroundColor = self.style.extraInfoHorizontalSeparatorBackgroundColor
        verticalSeparator.addSubview(verticalLine)
        verticalLine.fullFit(topMargin: self.separatorMargin, bottomMargin: self.separatorMargin, leftMargin: 0, rightMargin: 0)
        self.textFieldContainerView?.mainStackView.addArrangedSubview(verticalSeparator)
    }
    
    func setRightActionView(view: UIView, action: (() -> Void)?) {
        let button = ResponsiveButton()
        view.addSubview(button)
        button.fullFit()
        button.onTouchAction = { _ in
            self.executeRightViewAction(action)
        }
        self.textFieldContainerView?.mainStackView.addArrangedSubview(view)
    }
    
    func executeRightViewAction(_ action: (() -> Void)?) {
        if let action = action {
            action()
        } else {
            switch self.editingStyle {
            case .actionable(configuration: let configuration):
                configuration.action()
            default: break
            }
        }
    }
}

// MARK: - Clear Accessory

private extension LisboaTextField {
    
    func setUpClearAccessory() {
        switch self.clearAccessory {
        case .none:
            break
        case .clearDefault:
            self.clearView = LisboaClearView(action: self.resetTextField, style: self.style)
            self.textFieldContainerView?.mainStackView.insertArrangedSubview(self.clearView ?? UIView(), at: 1)
            self.isClearAccessoryVisible(self.text)
        }
    }
    
    func resetTextField() {
        self.setText(nil)
        self.updatableDelegate?.updatableTextFieldDidUpdate()
    }
    
    func isClearAccessoryVisible(_ value: String?) {
        guard self.clearAccessory != .none else { return }
        self.clearView?.isHidden = (value?.isEmpty == true) || value == nil
    }
}

extension LisboaTextField: ChangeTextFieldDelegate {
    
    public func willChangeText(textField: UITextField, text: String) {
        self.text = text
        self.isClearAccessoryVisible(text)
        self.clearErrorAppearanceIfNeeded()
    }
}
