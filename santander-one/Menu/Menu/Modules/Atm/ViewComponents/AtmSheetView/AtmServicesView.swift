//
//  AtmServicesView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/28/20.
//
import UI
import CoreFoundationLib
import Foundation

final class AtmServicesView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var servicesStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setViewModels(_ viewModels: [AtmElementViewModel]) {
        viewModels.forEach(addServiceElement)
    }
}

private extension AtmServicesView {
    func setup() {
        self.setTexts()
        self.setColors()
        self.addAccessibilityIdentifiers()
    }
    
    func setTexts() {
        self.titleLabel.configureText(withKey: "atm_label_otherServices")
    }
    
    func setColors() {
        self.titleLabel.textColor = .lisboaGray
    }
    
    func addAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityAtm.AtmDetail.atmListOtherServices
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.serviceTitle
    }
    
    func addServiceElement(_ viewModel: AtmElementViewModel) {
        let element = AtmElementView()
        element.accessibilityIdentifier = AccessibilityAtm.AtmDetail.service
        element.setViewModel(viewModel)
        self.servicesStackView.addArrangedSubview(element)
    }
}
