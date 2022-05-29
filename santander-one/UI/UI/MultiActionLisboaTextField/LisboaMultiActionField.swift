//
//  LisboaMultiActionField.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 29/12/2020.
//

import Foundation
import CoreFoundationLib

final public class LisboaMultiActionField: UIDesignableView, ValidatableField {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet private weak var fieldContainerView: UIView!
    @IBOutlet private weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet private var centrerConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet public weak var field: ConfigurableActionsTextField!
    @IBOutlet private weak var verticalSeparator: UIView!
    @IBOutlet weak private var actionView: UIView!
    @IBOutlet private weak var writeButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    private var rightViews: [ActionViewComponent] = [ActionViewComponent]()
    private var isEditingEnable = true
    private var handler: UITextFieldDelegate?
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

    public override func commonInit() {
        super.commonInit()
        configureErrorLabel()
    }
    
    // MARK: - Public Methods
    
    public func setText(_ text: String?) {
        self.field.text = text
        self.field.sendActions(for: .editingChanged)
    }

    public func updateData(text: String?) {
        self.setText(text)
        self.changeFieldVisibility(isFieldVisible: text?.isEmpty == false, animated: false)
    }
    
    public func configure(with handler: TextFieldFormatter?,
                          title: String,
                          style: ActionLisboaTextFieldStyle? = nil,
                          disabledActions: [TextFieldActions]? = nil,
                          rightViews: [ActionViewComponent]) {
        let unwrappedStyle = style ?? defaultStyle()
        self.rightViews.removeAll()
        self.rightViews.append(contentsOf: rightViews)
        setupRightViewComponents(rightViews)
        configureFieldWith(style: unwrappedStyle)
        setAppearanceWith(style: unwrappedStyle)
        self.titleLabel.text = title
        self.field.setDisabledActions(disabledActions)
        self.field.text = nil
        self.changeFieldVisibility(isFieldVisible: false, animated: false)
        self.fieldDelegate = self
        self.handler = handler
    }
    
    public override var isFirstResponder: Bool {
        field.isFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        field.becomeFirstResponder()
    }
    
    public func switchRightViewTo(_ type: ActionViewComponentType) {
         self.rightViews
        .filter({$0.componentType != type})
        .forEach({$0.view.isHidden = true})
        guard let viewToActivate = rightViews.filter({$0.componentType == type}).first else { return }
        viewToActivate.view.isHidden = false
    }
    
    public func updateRightView(_ rightView: ActionViewComponentType, disabled: Bool) {
        guard let component = self.rightViews.filter({$0.componentType == rightView}).first else { return }
        component.setViewDisabled(disabled)
    }
    
    @IBAction func editField() {
        guard isEditingEnable else { return }
        self.changeFieldVisibility(isFieldVisible: true, animated: true)
        self.field.becomeFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.fieldValue = textField.text
        self.updatableDelegate?.updatableTextFieldDidUpdate()
        self.hideError()
    }
    
    public func showError(_ error: String) {
        errorLabel.text = error
        errorLabel.isHidden = false
    }
    
    public func hideError() {
        errorLabel.isHidden = true
    }
}

private extension LisboaMultiActionField {
    func configureFieldWith(style: ActionLisboaTextFieldStyle) {
        self.field.backgroundColor = style.fieldBackgroundColor
        self.field.tintColor = style.fieldTintColor
        self.field.textColor = style.fieldTextColor
        self.field.font = style.fieldFont
    }
    
    func configureErrorLabel() {
        self.errorLabel.font = UIFont.santander(size: 13.0)
        self.errorLabel.textColor = UIColor.santanderRed
        self.errorLabel.isHidden = true
    }
    
    func setAppearanceWith(style: ActionLisboaTextFieldStyle) {
        self.fieldContainerView.backgroundColor = style.infoViewBackgroundColor
        self.actionView.backgroundColor = .clear
        self.verticalSeparator.backgroundColor = style.verticalSeparatorBackgroundColor
        self.titleLabel.font = style.titleLabelFont
        self.titleLabel.textColor = style.titleLabelTextColor
        self.fieldContainerView.layer.borderColor = style.containerViewBorderColor
        self.fieldContainerView.layer.borderWidth = style.containerViewBorderWidth
    }
    
    func changeFieldVisibility(isFieldVisible: Bool, animated: Bool) {
        let style = ActionLisboaTextFieldStyle.default
        self.writeButton.isHidden = isFieldVisible
        self.titleLabel.font = isFieldVisible ? style.visibleTitleLabelFont : style.titleLabelFont
        self.field.isHidden = !isFieldVisible
        self.fieldHeight.constant = isFieldVisible ? self.expandedHeight : 0
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
    
    func isEmptyField(with textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let placeholder = textField.placeholder ?? ""
        return text.isEmpty && placeholder.isEmpty
    }
    
    func setupRightViewComponents(_ components: [ActionViewComponent]) {
        components.forEach { (component) in
            component.view.translatesAutoresizingMaskIntoConstraints = false
            let tapGesture = ActionComponentGestureRecognizer(target: self,
                                                              action: #selector(performActionForActionView(sender:)),
                                                              component: component)
            component.view.addGestureRecognizer(tapGesture)
            self.actionView.addSubview(component.view)
            component.view.fullFit()
        }
    }
    
    @objc func performActionForActionView(sender: ActionComponentGestureRecognizer) {
        sender.actionComponent.action()
    }
    
    func defaultStyle() -> ActionLisboaTextFieldStyle {
        var style = ActionLisboaTextFieldStyle.default
        style.verticalSeparatorBackgroundColor = .darkTurqLight
        return style
    }
}

extension LisboaMultiActionField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let handler = handler,
              let response = handler.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) else {
            return false
        }
        return response
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        changeFieldVisibility(isFieldVisible: !(textField.text ?? "").isEmpty,
                              animated: false)
    }
}
