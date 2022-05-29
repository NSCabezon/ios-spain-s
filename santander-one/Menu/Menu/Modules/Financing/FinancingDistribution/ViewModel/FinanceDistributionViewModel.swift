//
//  FinanceDistributionViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 31/08/2020.
//

import CoreFoundationLib

public final class FinanceDistributionViewModel {
    
    private var financeDistributionItems: [FinanceGraphData]?
    private var financingTotal: Decimal
    private var items: [FinanceDistributionItemEntity]?
    
    init(distributionEntity: FinanceDistributionEntity) {
        self.items = distributionEntity.items
        financingTotal = distributionEntity.items.map({$0.value}).reduce(0, +)
        self.financeDistributionItems = distributionEntity.items.map({ (item) -> FinanceGraphData in
            let percentValue: Decimal = item.value.percentTendingToHightFromTotal(financingTotal, decimalPlaces: 2)
            return FinanceGraphData(value: percentValue, type: item.financingType, amount: item.value)
        })
    }
    
    static func formattedMoneyFromAmount(_ value: Decimal) -> NSAttributedString {
        let moneyFont = UIFont.santander(family: .text, type: .bold, size: 18)
        let entity = AmountEntity(value: value)
        let decorator = MoneyDecorator(entity, font: moneyFont, decimalFontSize: 14.0)
        let formmatedDecorator = decorator.formatAsMillions()
        return formmatedDecorator ?? NSAttributedString()
    }
}

// graphData
public extension FinanceDistributionViewModel {
    func graphData() -> [FinanceGraphData]? {
        return financeDistributionItems
    }
    
    var centerText: NSAttributedString? {
        let debtText: String = localized("financing_label_totalDebt").text
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let amount = AmountEntity(value: financingTotal)
        let totalFinance = amount.getFormattedAmountAsMillions(withDecimals: 0)
        let fullText = "\(debtText)\n\(totalFinance)"
        
        let styler = TextStylizer.Builder(fullText: fullText)
        _ = styler.addPartStyle(part: TextStylizer.Builder.TextStyle(word: debtText)
            .setColor(.lisboaGray)
            .setStyle(UIFont.santander(family: .text, type: .light, size: 18.0))
            .setParagraphStyle(paragraphStyle)
        )
        _ = styler.addPartStyle(part: TextStylizer.Builder.TextStyle(word: totalFinance)
            .setColor(.lisboaGray)
            .setStyle(UIFont.santander(family: .text, type: .bold, size: 27.0))
            .setParagraphStyle(paragraphStyle)
        )
        return styler.build()
    }
}

// table data
public extension FinanceDistributionViewModel {
    func rowsAtSection(_ section: Int) -> Int {
        return financeDistributionItems?.count ?? 0
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> FinanceGraphData? {
        let item = financeDistributionItems?[indexPath.row]
        return item
    }
    
    func numberOfSections() -> Int {
        return 1
    }
}

public struct FinanceDistributionData {
    var breakDownTitle: String
    var formattedAmount: NSAttributedString
    let iconName: String
}

public struct FinanceGraphData {
    var value: Decimal
    let type: FinancialDistributionType
    let amount: Decimal
}
