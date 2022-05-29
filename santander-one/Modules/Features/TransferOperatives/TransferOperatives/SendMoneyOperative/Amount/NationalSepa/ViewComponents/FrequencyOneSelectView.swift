//
//  FrequencyOneSelectView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 30/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol FrequencyOneSelectDelegate: AnyObject {
    func didSelectFrecuencyItem(_ index: Int)
}

final class FrequencyOneSelectView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var frequencySelect: OneInputSelectView!
    weak var delegate: FrequencyOneSelectDelegate?
    private var viewModel: OneInputSelectViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneInputSelectViewModel) {
        self.viewModel = viewModel
        self.frequencySelect.setViewModel(viewModel)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setVoiceOverFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.descriptionOneLabel)
    }
}

private extension FrequencyOneSelectView {
    func setupView() {
        self.setOneLabel()
        self.setAccessibilityIdentifiers()
        self.frequencySelect.delegate = self
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_periodicity"))
    }
    
    func setAccessibilityIdentifiers() {
        self.descriptionOneLabel.setAccessibilitySuffix(AccessibilitySendMoneyAmount.frequencySuffix)
        self.frequencySelect.setAccessibilitySuffix(AccessibilitySendMoneyAmount.frequencySuffix)
    }
    
    func setAccessibilityInfo() {
        guard let viewModel = self.viewModel else { return }
        self.descriptionOneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_selectFrecuency", [.init(.number, "\(viewModel.pickerData.count)")]).text)
    }
}

extension FrequencyOneSelectView: OneInputSelectViewDelegate {
    func didSelectOneItem(_ index: Int) {
        self.delegate?.didSelectFrecuencyItem(index)
    }
}

extension FrequencyOneSelectView: AccessibilityCapable {}
