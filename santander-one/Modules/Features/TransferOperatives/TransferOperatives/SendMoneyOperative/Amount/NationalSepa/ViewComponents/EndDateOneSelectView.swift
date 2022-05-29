//
//  EndDateOneSelectView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 1/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol EndDateOneSelectDelegate: AnyObject {
    func didSelectEndDate(_ date: Date)
}

final class EndDateOneSelectView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var endDateSelect: OneInputDateView!
    weak var delegate: EndDateOneSelectDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneInputDateViewModel) {
        self.endDateSelect.setViewModel(viewModel)
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    func setStatus(_ status: OneStatus) {
        self.endDateSelect.setOneStatus(status)
    }
    
    func setEndDate(_ date: Date) {
        self.endDateSelect.setMinDate(date)
    }
}

private extension EndDateOneSelectView {
    func setupView() {
        self.setOneLabel()
        self.endDateSelect.delegate = self
        self.setAccessibilityIdentifiers()
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_endDate"))
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.descriptionOneLabel.setAccessibilitySuffix(suffix ?? "")
        self.endDateSelect.setAccessibilitySuffix(suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.descriptionOneLabel.accessibilityLabel = localized("voiceover_selectEndDate")
    }
}

extension EndDateOneSelectView: OneInputDateViewDelegate {
    func didSelectNewDate(_ dateValue: Date) {
        self.delegate?.didSelectEndDate(dateValue)
    }
}

extension EndDateOneSelectView: AccessibilityCapable {}
