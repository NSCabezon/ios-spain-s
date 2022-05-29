//
//  ActionableFloatingLisboaTextField.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 10/06/2020.
//

import UIKit
import CoreFoundationLib

final class ActionableFloatingLisboaTextField: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet private weak var overTextFieldButton: ResponsiveButton!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private var placeholderLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet private var placeholderLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Attributes
    
    var adjustTextSize: LisboaTextField.TextScaleType = .none {
        didSet {
            self.setTextSize()
        }
    }
    var style: LisboaTextFieldStyle = .default
    weak var updatableDelegate: UpdatableTextFieldDelegate?
    var fieldValue: String?
    var textFieldPlaceholder: String?
    private let expandedHeight: CGFloat = 24
    
    // MARK: - Public
    
    func addAction(_ action: @escaping () -> Void) {
        self.overTextFieldButton.onTouchAction = { _ in
            action()
        }
    }
}

private extension ActionableFloatingLisboaTextField {
    
    func changeTextFieldVisibility(isVisible: Bool, animated: Bool) {
        self.placeholderLabel.font = isVisible ? self.style.visibleTitleLabelFont : self.style.titleLabelFont
        self.textLabel.isHidden = !isVisible
        self.textLabelHeight.constant = isVisible ? self.expandedHeight: 0
        self.placeholderLabelCenterConstraint.isActive = !isVisible
        self.placeholderLabelBottomConstraint.isActive = isVisible
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            self.layoutIfNeeded()
        }
    }
    
    func isEmptyField(with text: String?) -> Bool {
        guard let text = text else { return true }
        return text.isEmpty
    }
}

extension ActionableFloatingLisboaTextField: LisboaTextFieldViewProtocol {

    var text: String? {
        get {
            self.textLabel.text
        }
        set {
            self.fieldValue = newValue
            self.textLabel.text = newValue
            let isEmptyField = self.isEmptyField(with: newValue)
            self.changeTextFieldVisibility(isVisible: !isEmptyField, animated: true)
        }
    }
    
    var placeholder: String? {
        get {
            self.placeholderLabel.text
        }
        set {
            self.placeholderLabel.text = newValue
        }
    }
    
    func setup() {
        self.updateStyle()
        self.overTextFieldButton.backgroundColor = .clear
        self.overTextFieldButton.setTitle("", for: .normal)
        self.changeTextFieldVisibility(isVisible: false, animated: false)
    }

    func updateStyle() {
        self.backgroundColor = self.style.backgroundColor
        self.placeholderLabel.font = self.style.titleLabelFont
        self.placeholderLabel.textColor = self.style.titleLabelTextColor
        self.containerView.backgroundColor = self.style.containerViewBackgroundColor
        self.containerView.layer.borderColor = self.style.containerViewBorderColor
        self.containerView.layer.borderWidth = self.style.containerViewBorderWidth
        self.textLabel.textColor = self.style.fieldTextColor
        self.textLabel.font = self.style.fieldFont
        self.bottomBorderView.backgroundColor = self.style.verticalSeparatorBackgroundColor
    }

    func setTextSize() {
        switch self.adjustTextSize {
        case .none:
            break
        case .minimumFontSize(size: let fontSize):
            self.textLabel.adjustsFontSizeToFitWidth = true
            let minimumScaleFactor = fontSize / self.style.fieldFont.pointSize
            self.textLabel.minimumScaleFactor = minimumScaleFactor
        case .noMinimumSize:
            self.textLabel.adjustsFontSizeToFitWidth = true
        case .percentage(percent: let percent):
            self.textLabel.adjustsFontSizeToFitWidth = true
            self.textLabel.minimumScaleFactor = percent
        }
    }
}
