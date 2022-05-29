//
//  StartDateOneSelectView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 1/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol StartDateOneSelectDelegate: AnyObject {
    func didSelectStartDate(_ date: Date)
}

final class StartDateOneSelectView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var startDateSelect: OneInputDateView!
    weak var delegate: StartDateOneSelectDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneInputDateViewModel) {
        self.startDateSelect.setViewModel(viewModel)
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension StartDateOneSelectView {
    func setupView() {
        self.setOneLabel()
        self.startDateSelect.delegate = self
        self.setAccessibilityIdentifiers()
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_startDate"))
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.descriptionOneLabel.setAccessibilitySuffix(suffix ?? "")
        self.startDateSelect.setAccessibilitySuffix(suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.descriptionOneLabel.accessibilityLabel = localized("voiceover_selectStartDate")
    }
}

extension StartDateOneSelectView: OneInputDateViewDelegate {
    func didSelectNewDate(_ dateValue: Date) {
        self.delegate?.didSelectStartDate(dateValue)
    }
}

extension StartDateOneSelectView: AccessibilityCapable {}
