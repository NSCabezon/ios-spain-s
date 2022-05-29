//
//  DateOneSelectView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 31/1/22.
//

import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine

final class DateOneSelectView: XibView {

    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var dateSelect: OneInputDateView!
    private var dateSelected: Date?
    private var subject = PassthroughSubject<Date, Never>()
    public lazy var publisher: AnyPublisher<Date, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var titleDescriptionKey: String = ""
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneInputDateViewModel, titleDescriptionKey: String) {
        if let dateSelected = viewModel.firstDate {
            self.dateSelected = dateSelected
        }
        self.titleDescriptionKey = titleDescriptionKey
        self.setOneLabel()
        self.dateSelect.setViewModel(viewModel)
        guard let inputAccessibilityIdentifier = viewModel.accessibilityInputKey else { return }
        self.dateSelect.setAccessibilitySuffix(inputAccessibilityIdentifier)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setMinDate(_ date: Date) {
        self.dateSelect.setMinDate(date)
    }
    
    func setDate(_ date: Date?) {
        guard let dateSelected = date else { return }
        self.dateSelect.setDate(dateSelected)
    }
    
    func clearDateTextField() {
        self.dateSelected = nil
        self.dateSelect.clearDateTextField()
    }
}

private extension DateOneSelectView {
    func setupView() {
        self.dateSelect.delegate = self
    }
    
    func setOneLabel() {
        self.descriptionOneLabel.setupViewModel(OneLabelViewModel(type: .normal, mainTextKey: self.titleDescriptionKey))
    }
    
    func setAccessibilityInfo() {
        self.descriptionOneLabel.accessibilityElementsHidden = true
    }
}

extension DateOneSelectView: OneInputDateViewDelegate {
    func didSelectNewDate(_ dateValue: Date) {
        self.dateSelected = dateValue
        subject.send(dateValue)
    }
    
    func didSelectCancelOption() {
        if self.dateSelected == nil {
            self.dateSelect.clearDateTextField()
        }
    }
}

extension DateOneSelectView: AccessibilityCapable {}
