import Foundation
import CoreFoundationLib

class StockModelView: TableModelViewItem<StockViewCell> {
    
    var stock: Stock
    var isBuyActive: Bool
    var isSellActive: Bool
    var isManaged: Bool
    var isFirstTransaction: Bool
    var actionBuy: (_ stock: Stock) -> Void
    var actionSell: (_ stock: Stock) -> Void
    var shouldDisplayDate: Bool = false
    
    init(_ stock: Stock, isManaged: Bool, isBuyActive: Bool, isSellActive: Bool, actionBuy: @escaping (_ stock: Stock) -> Void, actionSell: @escaping (_ stockTransaction: Stock) -> Void, _ privateComponent: PresentationComponent) {
        self.stock = stock
        self.isFirstTransaction = false
        self.isBuyActive = isBuyActive
        self.isSellActive = isSellActive
        self.actionBuy = actionBuy
        self.actionSell = actionSell
        self.isManaged = isManaged
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: StockViewCell) {
        viewCell.setState(state: stock.state)
        viewCell.name = stock.name
        viewCell.setAmount(amount: stock.amount)
        let info = dependencies.stringLoader.getString("stocks_label_revaluation")
        viewCell.setVariation(variation: stock.variation, info: info, compareZero: stock.variationCompare)
        let buy = dependencies.stringLoader.getString("stocks_button_buy")
        let sell = dependencies.stringLoader.getString("stocks_button_sell")
        viewCell.setTitleLeftButton(text: buy, selector: #selector(touchBuy), target: self)
        viewCell.setTitleRightButton(text: sell, selector: #selector(touchSell), target: self)
        let numberOfTitles = stock.numberOfTitles
        let valueFormatted = formatterForRepresentation(.decimal(decimals: 0)).string(from: NSNumber(value: numberOfTitles)) ?? ""
        let price = stock.priceTitle
        let titles = dependencies.stringLoader.getQuantityString("stocks_label_stocksNumber", numberOfTitles, [StringPlaceholder(StringPlaceholder.Placeholder.number, valueFormatted), StringPlaceholder(StringPlaceholder.Placeholder.value, price)])
        viewCell.setTitles(titles: titles)
        viewCell.isBuyActive = isBuyActive
        viewCell.isSellActive = isSellActive
        viewCell.isManaged = isManaged
        viewCell.isDetailLoaded = stock.state == .done
        viewCell.managedPortfolioText = dependencies.stringLoader.getString("portfolioManaged_label_managed")
    }
    
    @objc func touchBuy () {
        actionBuy(stock)
    }
    
    @objc func touchSell () {
        actionSell(stock)
    }
}

extension StockModelView: DateProvider {
    
    var transactionDate: Date? {
        return nil
    }
    
}
