//
//  AtmCashType.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/28/20.
//
import UI
import CoreFoundationLib
import Foundation

final class AtmCashType: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentStackView: UIStackView!
    private var horizontalStack: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setViewModels(_ viewModels: [AtmElementViewModel]) {
        viewModels.chunked(by: 2).forEach(addElements)
    }
}

private extension AtmCashType {
    func setup() {
        self.setTexts()
        self.setColors()
        self.addAccessibilityIdentifiers()
    }
    
    func setTexts() {
        self.titleLabel.configureText(withLocalizedString: localized("atm_label_billsAvailable"))
    }
    
    func setColors() {
        self.titleLabel.textColor = .lisboaGray
    }
    
    func addAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAtm.AtmDetail.atmListTicketsAvailable
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.cashTypeTitle
    }
    
    func addElements(_ viewModels: [AtmElementViewModel]) {
        let stackView = self.horizontalStack
        viewModels.forEach({ viewModel in
            let element = AtmElementView()
            element.setViewModel(viewModel)
            stackView.addArrangedSubview(element)
            self.addFillViewIfNeeded(size: viewModels.count, stackView: stackView)
        })
        self.contentStackView.addArrangedSubview(stackView)
    }
    
    private func addFillViewIfNeeded(size: Int, stackView: UIStackView) {
        guard size % 2 != 0 else { return }
        stackView.addArrangedSubview(UIView())
    }
}

private extension Array {
    func chunked(by size: Int) -> [[Element]] {
        let indexStrides = stride(from: 0, to: self.count, by: size)
        return indexStrides.map { currentIndex in
            let elementsInRange = self[currentIndex..<Swift.min(currentIndex + size, self.count)]
            return Array(elementsInRange)
        }
    }
}
