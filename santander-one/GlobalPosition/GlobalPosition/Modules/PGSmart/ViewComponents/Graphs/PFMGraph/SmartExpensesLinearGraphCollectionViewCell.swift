//
//  SmartExpensesCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 24/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

protocol DiscreteModeConformable {
    var discreteMode: Bool {get set}
}

class SmartExpensesLinearGraphCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "SmartExpensesCollectionViewCell"
    
    private let selectedYourBalanceTextStyle: [NSAttributedString.Key: Any] =
        [.foregroundColor: UIColor.white, .font: UIFont.santander(family: FontFamily.headline, size: 18)]
    
    @IBOutlet weak var financialStatusView: FinantialStatusView!
    @IBOutlet weak var simpleFinancialStatusView: SimpleFinancialStatusView!
    @IBOutlet weak var expensesLinearGraphViewPort: ExpensesGraphViewPort!

    private var currentGraphData: CurrentBalanceGraphData?

    weak var graphViewPortDelegate: ExpensesGraphViewPortActionsDelegate?
    
    func setup(data: CurrentBalanceGraphData) {
        currentGraphData = data
        self.setYourBalanceSelected(totalBalance: currentGraphData?.total, financingTotal: currentGraphData?.financing, tooltipText: data.tooltipText)
        simpleFinancialStatusView.refreshLabels()
    }
    
    override func didMoveToSuperview() {
        expensesLinearGraphViewPort.dashLine.editButtonAction = { [weak self] in
            if let tapView = self?.expensesLinearGraphViewPort.dashLine.tapView {
                self?.graphViewPortDelegate?.didTapOnEditBudget(originView: tapView)
            }
        }
        expensesLinearGraphViewPort.onTapGraph = { [weak self] in
            self?.graphViewPortDelegate?.didTapOnAnalysis()
        }
        let popUpConfiguration = SimpleFinancialStatusView.PopUpConfiguration(text: localized("tooltip_title_budgetYourExpenses"), subtitle: nil, position: .bottom)
        simpleFinancialStatusView.configurePopUpWith(configuration: popUpConfiguration)
        
        financialStatusView.leftInfo.backgroundColor = .clear
        financialStatusView.rightInfo.backgroundColor = .clear
    }

    func configure(with data: ExpensesGraphViewModel) {
        expensesLinearGraphViewPort.setModel(data)
        expensesLinearGraphViewPort.stopLoading()
    }
    
    func startLoading() {
        expensesLinearGraphViewPort.showLoading()
    }
    
    func setDiscreteMode(_ enabled: Bool) { financialStatusView.setDiscreteMode(enabled) }
    
    private func setYourBalanceSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let selectedYourBalanceTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 12.0)]
            
        let unselectedTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .regular, size: 12.0)]
        let subtitleSelectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 26.0)]
        let subtitleUnselectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 26.0)]
        
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                     decimalSize: 20.0,
                                                     color: .white)
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text,
                                                                            attributes: subtitleSelectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                       decimalSize: 14.0,
                                                       color: .white)
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text,
                                                                              attributes: subtitleUnselectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: selectedYourBalanceTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: unselectedTextStyle)
        
        financialStatusView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .gray, tooltipText: tooltipText)
        financialStatusView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        financialStatusView.setLeftSelected()
    }
}
