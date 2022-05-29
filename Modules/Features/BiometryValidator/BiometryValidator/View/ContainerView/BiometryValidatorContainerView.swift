//
//  BiometryValidatorContainerView.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol BiometryValidatorContainerViewDelegate: AnyObject {
    func didTapInSign()
    func didTapInImage()
}

public final class BiometryValidatorContainerView: XibView {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var actionView: BiometryValidatorActionView!
    
    // MARK: - Attributes

    weak var delegate: BiometryValidatorContainerViewDelegate?

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Methods
    
    func configView(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        self.actionView.configView(type, status: status)
    }
}

private extension BiometryValidatorContainerView {
    func setupView() {
        self.backgroundColor = .skyGray
        self.actionView.backgroundColor = .clear
        self.actionView.delegate = self
        self.setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityBiometryValidatorContainerView.baseView
        
    }
}

extension BiometryValidatorContainerView: BiometryValidatorActionViewDelegate {
    func didTapInImage() {
        self.delegate?.didTapInImage()
    }
    
    func didTapInSign() {
        self.delegate?.didTapInSign()
    }
}
