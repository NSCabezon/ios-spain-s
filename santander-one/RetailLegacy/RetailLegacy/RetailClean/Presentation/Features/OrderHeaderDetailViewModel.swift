//

import Foundation

class OrderHeaderDetailViewModel: TableModelViewItem<OrderHeaderStatusTableViewCell> {
    
    let order: Order

    init(order: Order, dependencies: PresentationComponent) {
        self.order = order
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OrderHeaderStatusTableViewCell) {
        guard let orderTicker = order.ticker else { return }
        viewCell.orderDateLabel.text = order.date != nil ? dateToString(order.date!) : ""
        viewCell.tickerNameLabel.text = order.title + " (" + orderTicker + ")"
        viewCell.numberOfOrderLabel.text = numberOfOrderUI(from: order.number)
      
        switch order.situation {
        case .pending:
            viewCell.statusOrderLabel.set(localizedStylableText: dependencies.stringLoader.getString(order.situation.situationKey))
            viewCell.orderColor = "F5A623"
        case .executed:
            viewCell.statusOrderLabel.set(localizedStylableText: dependencies.stringLoader.getString(order.situation.situationKey))
            viewCell.orderColor = "9ABC3C"
        case .cancelled:
            viewCell.statusOrderLabel.set(localizedStylableText: dependencies.stringLoader.getString(order.situation.situationKey))
            viewCell.orderColor = "F54B4B"
        case .negotiated:
            viewCell.statusOrderLabel.set(localizedStylableText: dependencies.stringLoader.getString(order.situation.situationKey))
            viewCell.orderColor = "1BB3BC"
        case .rejected:
            viewCell.statusOrderLabel.set(localizedStylableText: dependencies.stringLoader.getString(order.situation.situationKey))
            viewCell.orderColor = "9E3667"
        case .undefined:
            viewCell.statusOrderLabel.text =  ""
            viewCell.orderColor = "FFFFFF"
        }
        
    }
    
    private func dateToString(_ date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
    
    private func numberOfOrderUI(from numberOrder: String) -> String {
        let orderNumber = dependencies.stringLoader.getString("ordersDetail_label_numberOrder", [StringPlaceholder(StringPlaceholder.Placeholder.number, numberOrder)]).text
        return orderNumber
    }
}
