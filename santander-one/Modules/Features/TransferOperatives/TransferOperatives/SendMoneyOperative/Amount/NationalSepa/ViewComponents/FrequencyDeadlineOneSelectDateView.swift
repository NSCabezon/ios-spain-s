//
//  FrequencyDeadlineOneSelectDateView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 1/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol FrequencyDeadlineOneSelectDateDelegate: AnyObject {
    func didSelectStartDate(_ date: Date)
    func didSelectEndDate(_ date: Date)
    func didSelectNoDeadLine(_ isDeadLine: Bool)
}

final class FrequencyDeadlineOneSelectDateView: XibView {
    @IBOutlet private weak var dateStackView: UIStackView!
    @IBOutlet private weak var deadLineCheckBox: OneCheckboxView!
    weak var delegate: FrequencyDeadlineOneSelectDateDelegate?
    private var viewModel: FrequencyDeadlineOneSelectDateViewModel?
    private lazy var startDateOneSelectView: StartDateOneSelectView = {
        let view = StartDateOneSelectView()
        view.delegate = self
        return view
    }()
    private lazy var endDateOneSelectView: EndDateOneSelectView = {
        let view = EndDateOneSelectView()
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: FrequencyDeadlineOneSelectDateViewModel) {
        self.viewModel = viewModel
        self.setDeadlineCheckBox(viewModel.deadlineCheckBoxViewModel)
        self.setStartDateOneSelectView(viewModel.startDateViewModel)
        self.setEndDateOneSelectView(viewModel.endDateViewModel)
    }
    
    func setVoiceOverFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.startDateOneSelectView)
    }
}

private extension FrequencyDeadlineOneSelectDateView {
    func setupView() {
        self.setAccessibilityIdentifiers()
    }
    
    func setStartDateOneSelectView(_ viewModel: OneInputDateViewModel?) {
        guard let viewModel = viewModel else { return }
        self.startDateOneSelectView.setViewModel(viewModel)
        self.dateStackView.addArrangedSubview(self.startDateOneSelectView)
    }
    
    func setEndDateOneSelectView(_ viewModel: OneInputDateViewModel?) {
        guard let viewModel = viewModel else { return }
        self.endDateOneSelectView.setViewModel(viewModel)
        self.dateStackView.addArrangedSubview(self.endDateOneSelectView)
    }
    
    func setDeadlineCheckBox(_ viewModel: OneCheckboxViewModel?) {
        guard let viewModel = viewModel else { return }
        self.deadLineCheckBox.delegate = self
        self.deadLineCheckBox.setViewModel(viewModel)
    }
    
    func setAccessibilityIdentifiers() {
        self.startDateOneSelectView.setAccessibilitySuffix(AccessibilitySendMoneyAmount.startDateSuffix)
        self.endDateOneSelectView.setAccessibilitySuffix(AccessibilitySendMoneyAmount.endDateSuffix)
        self.deadLineCheckBox.setAccessibilitySuffix(AccessibilitySendMoneyAmount.frequencySuffix)
    }
}

extension FrequencyDeadlineOneSelectDateView: StartDateOneSelectDelegate {
    func didSelectStartDate(_ date: Date) {
        self.delegate?.didSelectStartDate(date)
        let minDate = date.getDateByAdding(days: 1)
        self.endDateOneSelectView.setEndDate(minDate)
        UIAccessibility.post(notification: .layoutChanged, argument: self.deadLineCheckBox)
    }
}

extension FrequencyDeadlineOneSelectDateView: EndDateOneSelectDelegate {
    func didSelectEndDate(_ date: Date) {
        self.deadLineCheckBox.setStatus(.inactive)
        self.delegate?.didSelectEndDate(date)
    }
}

extension FrequencyDeadlineOneSelectDateView: OneCheckboxViewDelegate {
    func didSelectOneCheckbox(_ isSelected: Bool) {
        self.endDateOneSelectView.setStatus(isSelected ? .disabled : .activated)
        self.delegate?.didSelectNoDeadLine(isSelected)
    }
}
