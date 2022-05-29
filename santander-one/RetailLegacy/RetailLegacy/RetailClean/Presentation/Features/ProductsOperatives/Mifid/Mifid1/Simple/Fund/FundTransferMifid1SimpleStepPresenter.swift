import Foundation

class FundTransferMifid1SimpleStepPresenter: Mifid1SimpleStepPresenter {
    
    typealias FundData = (fund: Fund, destinationFund: Fund, amount: Amount?, shares: Decimal?)
    
    override func validate(completion: @escaping (Mifid1SimpleResponse) -> Void) {
        
        guard let container = container else { return }
        
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        guard let transferType = fundTransferTransaction.fundTransferType else {
            return
        }
        
        switch transferType {
        case .total:
            total(withContainer: container, completion: completion)
        case .partialAmount:
            partialByAmount(withContainer: container, completion: completion)
        case .partialShares:
            partialByShares(withContainer: container, completion: completion)
        }
    }
    
    private func total(withContainer container: MifidContainerProtocol, completion: @escaping (Mifid1SimpleResponse) -> Void) {
        
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let params = MifidFundTransferTotalData(originFund: fund, destinationFund: fundTransferTransaction.destinationFund)
        let input = FundTransferTotalMifid1UseCaseInput(data: params)
        let useCase = useCaseProvider.fundTransferTotalMifid1UseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { (error)  in
            completion(.error(response: error))
        })
    }
    
    private func partialByAmount(withContainer container: MifidContainerProtocol, completion: @escaping (Mifid1SimpleResponse) -> Void) {
        
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        
        let destination = fundTransferTransaction.destinationFund
        guard let amount = fundTransferTransaction.amount else {
            return
        }
        
        let parameters = MifidFundTransferPartialByAmountData(originFund: fund, destinationFund: destination, amount: amount)
        let input = FundTransferPartialByAmountMifid1UseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundTransferPartialByAmountMifid1UseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { (error)  in
            completion(.error(response: error))
        })
    }
    
    private func partialByShares(withContainer container: MifidContainerProtocol, completion: @escaping (Mifid1SimpleResponse) -> Void) {
        
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        
        let destination = fundTransferTransaction.destinationFund
        guard let shares = fundTransferTransaction.shares else {
            return
        }
        
        let parameters = MifidFundTransferPartialBySharesData(originFund: fund, destinationFund: destination, shares: shares)
        let input = FundTransferPartialBySharesMifid1UseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundTransferPartialBySharesMifid1UseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { (error)  in
            completion(.error(response: error))
        })
    }
}
