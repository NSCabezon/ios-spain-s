//
//  LisboaTextFieldWithErrorView.swift
//  Account
//
//  Created by Margaret on 29/07/2020.
//

import UIKit
import CoreFoundationLib

public class LisboaTextFieldWithErrorView: XibView {
    @IBOutlet public weak var textField: LisboaTextField!
    @IBOutlet public weak var errorView: UIView! {
        didSet {
            self.errorView.isHidden = true
        }
    }
    @IBOutlet private weak var errorLabel: UILabel! {
        didSet {
            self.errorLabel.numberOfLines = 1
            self.errorLabel.adjustsFontSizeToFitWidth = true
            self.errorLabel.minimumScaleFactor = 0.5
            self.errorLabel.setSantanderTextFont(type: .regular, size: 13, color: .bostonRed)
        }
    }
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Public functions
    @objc public func hideError() {
        self.errorView.isHidden = true
        self.textField.clearErrorAppearance()
    }

    public func showError(_ error: String?) {
        self.errorView.isHidden = (error == nil) ? true : false
        self.errorLabel.text = localized(error ?? "")
        self.textField.setErrorAppearanceIfNeeded()
    }
    
    public func setHeight(_ constant: CGFloat) {
        self.heightConstraint.constant = constant
    }
}
