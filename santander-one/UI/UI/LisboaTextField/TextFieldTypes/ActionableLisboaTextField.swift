//
//  ActionableLisboaTextField.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 28/05/2020.
//

import UIKit
import CoreFoundationLib

final class ActionableLisboaTextField: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet private weak var button: ResponsiveButton!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Attributes
    
    var style: LisboaTextFieldStyle = .default
    var placeholder: String? {
        didSet {
            self.label.text = placeholder
        }
    }
    var textFieldPlaceholder: String?
    var adjustTextSize: LisboaTextField.TextScaleType = .none {
        didSet {
            self.setTextSize()
        }
    }
    weak var updatableDelegate: UpdatableTextFieldDelegate?
    var fieldValue: String?
    
    // MARK: - Public
    
    func addAction(_ action: @escaping () -> Void) {
        button.onTouchAction = { _ in
            action()
        }
    }
    
    func setTextSize() {
        switch self.adjustTextSize {
        case .none:
            break
        case .minimumFontSize(size: let fontSize):
            self.label.adjustsFontSizeToFitWidth = true
            let minimumScaleFactor = fontSize / self.style.fieldFont.pointSize
            self.label.minimumScaleFactor = minimumScaleFactor
        case .noMinimumSize:
            self.label.adjustsFontSizeToFitWidth = true
        case .percentage(percent: let percent):
            self.label.adjustsFontSizeToFitWidth = true
            self.label.minimumScaleFactor = percent
        }
    }
}

extension ActionableLisboaTextField: LisboaTextFieldViewProtocol {
    var text: String? {
        get {
            self.label.text
        }
        set {
            if newValue == nil || (newValue?.isEmpty == true) {
                self.label.text = placeholder
                self.fieldValue = nil
            } else {
                self.label.text = newValue
                self.fieldValue = newValue
            }
        }
    }
    
    func setup() {
        self.updateStyle()
        self.button.backgroundColor = .clear
        self.button.setTitle("", for: .normal)
    }
    
    func updateStyle() {
        self.backgroundColor = self.style.backgroundColor
        self.label.font = self.style.titleLabelFont
        self.label.textColor = self.style.titleLabelTextColor
        self.containerView.backgroundColor = self.style.containerViewBackgroundColor
        self.containerView.layer.borderColor = self.style.containerViewBorderColor
        self.containerView.layer.borderWidth = self.style.containerViewBorderWidth
    }
}
