//

import Foundation

protocol CardTransactionProtocol {
    var description: String? { get }
    var amount: Amount { get }
    var transactionDate: Date? { get }
}
