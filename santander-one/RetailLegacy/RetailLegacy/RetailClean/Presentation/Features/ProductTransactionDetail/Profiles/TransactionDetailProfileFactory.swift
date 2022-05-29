import Foundation
import CoreDomain

struct TransactionDetailProfileFactory {
    var product: GenericProductProtocol?
    var transaction: GenericTransactionProtocol
    var productHome: PrivateMenuProductHome
    var errorHandler: GenericPresenterErrorHandler
    var dependencies: PresentationComponent
    var transactionDetailManager: ProductLauncherOptionsPresentationDelegate

    func makeTransactionDetailProfile() -> TransactionDetailProfile? {
        switch productHome {
        case .funds:
            return FundTransactionDetailProfile(product: product,
                                                transaction: transaction,
                                                dependencies: dependencies,
                                                errorHandler: errorHandler,
                                                transactionDetailManager: transactionDetailManager)
            
        case .pensions:
            return PensionTransactionDetailProfile(product: product,
                                                   transaction: transaction,
                                                   dependencies: dependencies,
                                                   errorHandler: errorHandler,
                                                   transactionDetailManager: transactionDetailManager)
        case .impositionTransactionDetail:
            return ImpositionsTransactionDetailProfile(product: product,
                                                       transaction: transaction,
                                                       dependencies: dependencies,
                                                       errorHandler: errorHandler,
                                                       transactionDetailManager: transactionDetailManager)
            
        case .cardsPending:
            return CardPendingTransactionDetailProfile(product: product,
                                                transaction: transaction,
                                                dependencies: dependencies,
                                                errorHandler: errorHandler,
                                                transactionDetailManager: transactionDetailManager)
        case .portfolioProductTransactionDetail:
            return PortfolioProductTransactionDetailProfile(product: product,
                                                            transaction: transaction,
                                                            dependencies: dependencies,
                                                            errorHandler: errorHandler,
                                                            transactionDetailManager: transactionDetailManager)
        case .bill:
            return BillDetailProfile(product: product,
                                     transaction: transaction,
                                     dependencies: dependencies,
                                     errorHandler: errorHandler,
                                     transactionDetailManager: transactionDetailManager)
        default:
            return nil
        }
    }
}
