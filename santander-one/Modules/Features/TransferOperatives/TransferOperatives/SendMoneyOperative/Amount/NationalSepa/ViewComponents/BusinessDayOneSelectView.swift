//
//  BusinessDayOneSelectView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 30/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol BusinessDayOneSelectDelegate: AnyObject {
    func didSelectBusinessItem(_ index: Int)
}

final class BusinessDayOneSelectView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var businessDaySelect: OneInputSelectView!
    
    weak var delegate: BusinessDayOneSelectDelegate?
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
        self.businessDaySelect.setViewModel(viewModel)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
}

private extension BusinessDayOneSelectView {
    func setupView() {
        self.setOneLabel()
        self.businessDaySelect.delegate = self
        self.setAccessibilityIdentifiers()
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_workingDayIssue"))
    }
    
    func setAccessibilityIdentifiers() {
        self.descriptionOneLabel.setAccessibilitySuffix(AccessibilitySendMoneyAmount.businessDaySuffix)
        self.businessDaySelect.setAccessibilitySuffix(AccessibilitySendMoneyAmount.businessDaySuffix)
    }
    
    func setAccessibilityInfo() {
        guard let viewModel = self.viewModel else { return }
        self.descriptionOneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_selectCoincidedDay", [.init(.number, "\(viewModel.pickerData.count)")]).text)
    }
    
}

extension BusinessDayOneSelectView: OneInputSelectViewDelegate {
    func didSelectOneItem(_ index: Int) {
        self.delegate?.didSelectBusinessItem(index)
    }
}

extension BusinessDayOneSelectView: AccessibilityCapable {}
