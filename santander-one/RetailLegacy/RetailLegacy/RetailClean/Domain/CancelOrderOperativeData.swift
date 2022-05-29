//

import Foundation

struct CancelOrderOperativeData {
    let stockAccount: StockAccount
    let order: Order
    let dialogTitle: LocalizedStylableText
    let dialogMessage: LocalizedStylableText
    let acceptTitle: LocalizedStylableText
}

extension CancelOrderOperativeData: OperativeParameter {}
