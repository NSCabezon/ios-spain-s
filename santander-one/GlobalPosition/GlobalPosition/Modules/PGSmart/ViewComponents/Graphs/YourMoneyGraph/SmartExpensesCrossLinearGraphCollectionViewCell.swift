//
//  SmartExpensesCrossLinearGraphCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 24/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

class SmartExpensesCrossLinearGraphCollectionViewCell: UICollectionViewCell {
    private let selectedYourBalanceTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 12.0)]
    private let selectedFinanceTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 12.0)]
        
    private let unselectedTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .regular, size: 12.0)]
    private let subtitleSelectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 26.0)]
    private let subtitleUnselectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.santander(family: .text, type: .bold, size: 26.0)]
        
    static let cellIdentifier = "SmartExpensesCrossLinearGraphCollectionViewCell"
    @IBOutlet weak var financialStatusView: FinantialStatusView!
    @IBOutlet weak var crossLinearImageView: UIImageView!
    private var currentGraphData: CurrentBalanceGraphData?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(data: CurrentBalanceGraphData) {
        currentGraphData = data
        
        self.setYourBalanceSelected(totalBalance: currentGraphData?.total, financingTotal: currentGraphData?.financing, tooltipText: data.tooltipText)
        self.crossLinearImageView.image = Assets.image(named: "imgGraphicMoneyPgSmart")
    }
    
    override func didMoveToSuperview() {
        financialStatusView.leftInfo.backgroundColor = .clear
        financialStatusView.rightInfo.backgroundColor = .clear
        
        financialStatusView.setLeftAction { [weak self] in
            self?.setYourBalanceSelected(totalBalance: self?.currentGraphData?.total, financingTotal: self?.currentGraphData?.financing, tooltipText: self?.currentGraphData?.tooltipText ?? "")
            self?.crossLinearImageView.image = Assets.image(named: "imgGraphicMoneyPgSmart")
        }
        
        financialStatusView.setRightAction { [weak self] in
            self?.setFinantialTotalSelected(totalBalance: self?.currentGraphData?.total, financingTotal: self?.currentGraphData?.financing, tooltipText: self?.currentGraphData?.tooltipText ?? "")
            self?.crossLinearImageView.image = Assets.image(named: "imgGraphicFinancitionPgSmart")
        }
    }
    
    private func setYourBalanceSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                     decimalSize: 20.0,
                                                     color: .white)
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleSelectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                       decimalSize: 14.0,
                                                       color: UIColor.white.withAlphaComponent(0.8))
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleUnselectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: selectedYourBalanceTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: unselectedTextStyle)
        
        financialStatusView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .gray, tooltipText: tooltipText)
        financialStatusView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        financialStatusView.setLeftSelected()
    }
    
    private func setFinantialTotalSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                     decimalSize: 14.0,
                                                     color: UIColor.white.withAlphaComponent(0.8))
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleUnselectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                       decimalSize: 20.0,
                                                       color: UIColor.white)
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleSelectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: unselectedTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: selectedFinanceTextStyle)
        
        financialStatusView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .gray, tooltipText: tooltipText)
        financialStatusView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        financialStatusView.setRightSelected()
    }
        
    func setGraphHidden(_ isHidden: Bool) {
        self.crossLinearImageView.isHidden = isHidden
    }
    func setDiscreteMode(_ enabled: Bool) {
        financialStatusView.setDiscreteMode(enabled)
    }
}
