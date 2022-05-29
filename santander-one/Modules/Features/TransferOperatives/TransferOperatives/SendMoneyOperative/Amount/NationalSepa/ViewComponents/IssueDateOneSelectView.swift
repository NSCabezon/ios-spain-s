//
//  IssueDateOneSelectView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 6/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol IssueDateOneSelectDelegate: AnyObject {
    func didSelectIssueDate(_ date: Date)
}

final class IssueDateOneSelectView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var issueDateSelect: OneInputDateView!
    weak var delegate: IssueDateOneSelectDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneInputDateViewModel) {
        self.issueDateSelect.setViewModel(viewModel)
    }
    
    func setVoiceOverFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.descriptionOneLabel)
    }
}

private extension IssueDateOneSelectView {
    func setupView() {
        self.setOneLabel()
        self.setAccessibilityIdentifiers()
        self.issueDateSelect.delegate = self
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_issuanceDate"))
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    func setAccessibilityIdentifiers() {
        self.descriptionOneLabel.setAccessibilitySuffix(AccessibilitySendMoneyAmount.deferredSuffix)
        self.issueDateSelect.setAccessibilitySuffix(AccessibilitySendMoneyAmount.deferredSuffix)
    }
    
    func setAccessibilityInfo() {
        self.descriptionOneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_issueDate"))
    }
}

extension IssueDateOneSelectView: OneInputDateViewDelegate {
    func didSelectNewDate(_ dateValue: Date) {
        self.delegate?.didSelectIssueDate(dateValue)
    }
}

extension IssueDateOneSelectView: AccessibilityCapable {}
