//

import Foundation

enum CardMovementType {
    case list(cardTransaction: CardTransaction)
    case pending(cardPendingTransaction: CardPendingTransaction)
}

struct CardMovement {
    let movement: CardTransactionProtocol
    let transaction: CardMovementType
    
    init(transaction: CardTransaction) {
        movement = transaction
        self.transaction = .list(cardTransaction: transaction)
    }
    
    init(transaction: CardPendingTransaction) {
        movement = transaction
        self.transaction = .pending(cardPendingTransaction: transaction)
    }
}

extension CardMovement: GenericTransactionProtocol {}
