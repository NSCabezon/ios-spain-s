//
//  FinanceableProductSelectorView.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 03/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol FinanceableProductSelectorDetailDelegate: AnyObject {
    func selectorDisplaysDetailView(_ isDisplayed: Bool)
}

final class FinanceableProductSelectorView<Product: Equatable & DropdownElement>: UIView {
    private let dropdownView: DropdownView<Product> = DropdownView<Product>(frame: .zero)
    private var onSelected: ((Product) -> Void)?
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    weak var delegate: FinanceableProductSelectorDetailDelegate?
    
    func configureWithProducts(_ products: [Product], title: String, onSelected: @escaping (Product) -> Void) {
        let dropdownConfiguration = DropdownConfiguration<Product>(title: title, elements: products, displayMode: .growToScreenBounds(inset: 20))
        self.dropdownView.configure(dropdownConfiguration)
        self.onSelected = onSelected
    }
    
    public func selectElement(_ element: Product) {
        self.dropdownView.selectElement(element)
    }
    
    public func setDropdownAccessibilityIdentifier(_ identifier: String) {
        dropdownView.selectionLabel.accessibilityIdentifier = identifier
    }
}

private extension FinanceableProductSelectorView {
    
    func setup() {
        self.accessibilityIdentifier = "areaDropdownEmit"
        self.addSubview(self.horizontalStackView)
        self.horizontalStackView.addArrangedSubview(self.horizontalLine(color: .mediumSkyGray))
        self.horizontalStackView.addArrangedSubview(self.verticalStackView)
        self.horizontalStackView.addArrangedSubview(self.horizontalLine(color: .mediumSkyGray))
        self.verticalStackView.addArrangedSubview(self.verticalLine(color: .mediumSkyGray))
        self.verticalStackView.addArrangedSubview(self.dropdownView)
        self.verticalStackView.addArrangedSubview(self.verticalLine(color: .darkTurqLight))
        self.dropdownView.delegate = self
        self.dropdownView.selectorDelegate = self
        self.horizontalStackView.fullFit(topMargin: 0, bottomMargin: 6, leftMargin: 16, rightMargin: 16)
    }
    
    func verticalLine(color: UIColor) -> UIView {
        let lineContainer = UIView()
        lineContainer.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineContainer.backgroundColor = color
        return lineContainer
    }
    
    func horizontalLine(color: UIColor) -> UIView {
        let line = UIView()
        line.widthAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = color
        return line
    }
}

extension FinanceableProductSelectorView: DropdownDelegate {
    
    func didSelectOption(element: DropdownElement) {
        guard let card = element as? Product else { return }
        self.onSelected?(card)
    }
}

extension FinanceableProductSelectorView: DropdownViewDisplayedDelegate {
    func isDropdownViewDisplayed(_ isDisplayed: Bool) {
        delegate?.selectorDisplaysDetailView(isDisplayed)
    }
}
