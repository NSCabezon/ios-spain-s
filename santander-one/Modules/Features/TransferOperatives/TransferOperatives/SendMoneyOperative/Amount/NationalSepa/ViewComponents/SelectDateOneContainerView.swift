//
//  SelectDateOneContainerView.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 11/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SelectDateOneContainerViewDelegate: AnyObject {
    func didSelectStartDate(_ date: Date)
    func didSelectEndDate(_ date: Date)
    func didSelectDeadlineCheckbox(_ isDeadLine: Bool)
    func didSelectIssueDate(_ date: Date)
    func didSelecteOneFilterSegment(_ type: SendMoneyDateTypeViewModel)
    func didSelectBusinessDay(_ type: SendMoneyEmissionTypeViewModel)
    func didSelectFrequency(_ type: SendMoneyPeriodicityTypeViewModel)
    func getSendMoneyPeriodicity(_ index: Int) -> SendMoneyPeriodicityTypeViewModel
}

final class SelectDateOneContainerView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: SelectDateOneContainerViewDelegate?
    private var dependenciesResolver: DependenciesResolver?
    private lazy var selectionDateOneFilterView: SelectionDateOneFilterView = {
        let view = SelectionDateOneFilterView()
        view.delegate = self
        return view
    }()
    private lazy var frequencySelectView: FrequencyOneSelectView = {
        let view = FrequencyOneSelectView()
        view.delegate = self
        return view
    }()
    private lazy var businessDaySelectView: BusinessDayOneSelectView = {
        let view = BusinessDayOneSelectView()
        view.delegate = self
        return view
    }()
    private lazy var frequencyDeadlineView: FrequencyDeadlineOneSelectDateView = {
        let view = FrequencyDeadlineOneSelectDateView()
        view.delegate = self
        return view
    }()
    private lazy var issueDateView: IssueDateOneSelectView = {
        let view = IssueDateOneSelectView()
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViewModels(_ viewModel: SelectDateOneContainerViewModel, isSelectDeadlineCheckbox: Bool, endDate: Date?) {
        self.dependenciesResolver = viewModel.dependenciesResolver
        self.addSelectionDateOneFilterView(viewModel.selectionDateOneFilterViewModel)
        self.setFrequencySelectView(viewModel.oneInputSelectFrequencyViewModel)
        self.setFrequencyDeadLineView(viewModel.frequencyDeadlineOneSelectDateViewModel)
        if let oneInputSelectViewModel = viewModel.oneInputSelectViewModel {
            self.setBusinessDaySelectView(oneInputSelectViewModel)
        }
        self.setIssueDateView(viewModel.oneInputDateViewModel)
        self.didSelecteOneFilterSegment(viewModel.selectionDateOneFilterViewModel.selectedIndex)
        if !isSelectDeadlineCheckbox {
            self.frequencyDeadlineView.didSelectOneCheckbox(false)
            self.frequencyDeadlineView.didSelectEndDate(endDate ?? Date().getDateByAdding(days: 3))
        }
    }
}

private extension SelectDateOneContainerView {
    
    func addSelectionDateOneFilterView(_ viewModel: SelectionDateOneFilterViewModel) {
        self.selectionDateOneFilterView.setViewModel(viewModel)
        self.stackView.addArrangedSubview(self.selectionDateOneFilterView)
    }
    
    func setFrequencySelectView(_ viewModel: OneInputSelectViewModel) {
        self.frequencySelectView.setViewModel(viewModel)
        self.frequencySelectView.isHidden = true
        self.stackView.addArrangedSubview(self.frequencySelectView)
    }
    
    func setBusinessDaySelectView(_ viewModel: OneInputSelectViewModel) {
        self.businessDaySelectView.setViewModel(viewModel)
        self.businessDaySelectView.isHidden = true
        self.stackView.addArrangedSubview(self.businessDaySelectView)
    }
    
    func setFrequencyDeadLineView(_ viewModel: FrequencyDeadlineOneSelectDateViewModel) {
        self.frequencyDeadlineView.setViewModel(viewModel)
        self.frequencyDeadlineView.isHidden = true
        self.stackView.addArrangedSubview(self.frequencyDeadlineView)
    }
    
    func setIssueDateView(_ viewModel: OneInputDateViewModel) {
        self.issueDateView.setViewModel(viewModel)
        self.issueDateView.isHidden = true
        self.stackView.addArrangedSubview(self.issueDateView)
    }
    
    func didSelectNow() {
        self.frequencySelectView.isHidden = true
        self.businessDaySelectView.isHidden = true
        self.frequencyDeadlineView.isHidden = true
        self.issueDateView.isHidden = true
    }
    
    func didSelectPeriodic() {
        self.frequencySelectView.isHidden = false
        self.businessDaySelectView.isHidden = false
        self.frequencyDeadlineView.isHidden = false
        self.issueDateView.isHidden = true
        self.frequencySelectView.setVoiceOverFocus()
    }
    
    func didSelectDay() {
        self.frequencySelectView.isHidden = true
        self.businessDaySelectView.isHidden = true
        self.frequencyDeadlineView.isHidden = true
        self.issueDateView.isHidden = false
        self.issueDateView.setVoiceOverFocus()
    }
    
    func didSelectSegment(_ sendMoneyDateType: SendMoneyDateTypeViewModel) {
        switch sendMoneyDateType {
        case .now:
            self.didSelectNow()
        case .periodic:
            self.didSelectPeriodic()
        case .day:
            self.didSelectDay()
        }
    }
}

extension SelectDateOneContainerView: SelectionDateOneFilterDelegate {
    func didSelecteOneFilterSegment(_ index: Int) {
        var sendMoneyDateType: SendMoneyDateTypeViewModel = .now
        switch(index) {
        case 0:
            sendMoneyDateType = .now
        case 1:
            sendMoneyDateType = .day
        case 2:
            sendMoneyDateType = .periodic
        default: break
        }
        self.didSelectSegment(sendMoneyDateType)
        self.delegate?.didSelecteOneFilterSegment(sendMoneyDateType)
    }
}

extension SelectDateOneContainerView: FrequencyDeadlineOneSelectDateDelegate {
    func didSelectStartDate(_ date: Date) {
        self.delegate?.didSelectStartDate(date)
    }
    
    func didSelectEndDate(_ date: Date) {
        self.delegate?.didSelectEndDate(date)
    }
    
    func didSelectNoDeadLine(_ isDeadLine: Bool) {
        self.delegate?.didSelectDeadlineCheckbox(isDeadLine)
    }
}

extension SelectDateOneContainerView: IssueDateOneSelectDelegate {
    func didSelectIssueDate(_ date: Date) {
        self.delegate?.didSelectIssueDate(date)
    }
}

extension SelectDateOneContainerView: FrequencyOneSelectDelegate {
    func didSelectFrecuencyItem(_ index: Int) {
        self.frequencyDeadlineView.setVoiceOverFocus()
        let sendMoneyPeriodicity = self.delegate?.getSendMoneyPeriodicity(index)
        self.delegate?.didSelectFrequency(sendMoneyPeriodicity ?? .month)
    }
}

extension SelectDateOneContainerView: BusinessDayOneSelectDelegate {
    func didSelectBusinessItem(_ index: Int) {
        let emissionType = SendMoneyEmissionTypeViewModel(rawValue: index)
        self.delegate?.didSelectBusinessDay(emissionType ?? .previous)
    }
}
