//
//  LastMovementsView.swift
//  Cards
//
//  Created by Laura González on 06/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol LastMovementsViewDelegate: AnyObject {
    func didMoreMovementsSelected()
}

final class LastMovementsView: UIDesignableView {
    
    @IBOutlet weak var movementsStackView: UIStackView!
    
    weak var delegate: LastMovementsViewDelegate?
    private var isFooterHidden: Bool = true
    private var totalExpensesView: SettlementMovementTotalCell?
    override public func getBundleName() -> String {
        return "Cards"
    }
    
    override public func commonInit() {
        super.commonInit()
        setupView()
    }
    
    func setSingleCardStyle(_ viewModels: [NextSettlementMovementViewModel]) {
        let numMovements = viewModels.count
        switch numMovements {
        case 1:
            self.setMovementView(viewModels[0], showSeparator: false)
        case 2:
            self.setTwoMovementViews(viewModels)
        default:
            self.setTwoMovementViews(viewModels)
            self.setFooterView()
        }
    }

    func setMultipleCardStyle(_ viewModels: [NextSettlementMovementViewModel]) {
        totalExpensesView = SettlementMovementTotalCell()
        setTotalAmount(viewModels)
        movementsStackView.addArrangedSubview(totalExpensesView ?? SettlementMovementTotalCell())
        self.setFooterView()
    }
    
    func setMultipleCardEmptyViewStyle() {
        totalExpensesView = SettlementMovementTotalCell()
        let totalAmountString = Decimal(0).toStringWithCurrency()
        totalExpensesView?.configureCell(totalAmountString)
        movementsStackView.addArrangedSubview(totalExpensesView ?? SettlementMovementTotalCell())
    }
    
    func setTotalAmount(_ viewModels: [NextSettlementMovementViewModel]) {
        let totalAmount = viewModels.lazy.compactMap { $0.amount }.reduce(0, +)
        let totalAmountString = Decimal(abs(totalAmount)).toStringWithCurrency()
        totalExpensesView?.configureCell(totalAmountString)
    }
}

private extension LastMovementsView {
    func setupView() {
        self.backgroundColor = .clear
    }
    
    func setMovementView(_ viewModel: NextSettlementMovementViewModel, showSeparator: Bool) {
        let movementView = SettlementMovementCell()
        movementView.configureCell(viewModel)
        movementView.configureSeparator(showSeparator)
        movementsStackView.addArrangedSubview(movementView)
    }
    
    func setTwoMovementViews(_ viewModels: [NextSettlementMovementViewModel]) {
        self.setMovementView(viewModels[0], showSeparator: true)
        self.setMovementView(viewModels[1], showSeparator: false)
    }
    
    func setFooterView() {
        let footerView = SeeSettlementMovementsView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didMoreMovementsSelected))
        footerView.seeMovementsButton.addGestureRecognizer(tapGesture)
        movementsStackView.addArrangedSubview(footerView)
    }
    
    @objc func didMoreMovementsSelected() {
        self.delegate?.didMoreMovementsSelected()
    }
}
