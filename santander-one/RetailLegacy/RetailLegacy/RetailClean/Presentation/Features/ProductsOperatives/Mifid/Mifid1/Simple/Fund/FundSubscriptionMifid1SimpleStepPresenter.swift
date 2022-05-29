import Foundation

class FundSubscriptionMifid1SimpleStepPresenter: Mifid1SimpleStepPresenter {
    // MARK: - Tracking
    override var screenId: String? {
        return TrackerPagePrivate.FundSubscriptionMifid().page
    }
    
    override func validate(completion: @escaping (Mifid1SimpleResponse) -> Void) {        
        guard let container = container else { return }
        
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let transaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        switch transaction.fundSubscriptionType {
        case .amount:
            guard let amount = operativeData.amount else {
                return
            }
            let params = MifidFundSubscriptionAmountData(fund: fund, amount: amount)
            let input = FundSubscriptionAmountMifid1UseCaseInput(data: params)
            let useCase = useCaseProvider.fundSubscriptionAmountMifid1UseCase(input: input)
            
            UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
                completion(.success(response: result))
            }, onGenericErrorType: { error in
                completion(.error(response: error))
            })
        case .participation:
            guard let decimal = operativeData.shares else {
                return
            }
            let params = MifidFundSubscriptionSharesData(fund: fund, shares: decimal)
            let input = FundSubscriptionSharesMifid1UseCaseInput(data: params)
            let useCase = useCaseProvider.fundSubscriptionSharesMifid1UseCase(input: input)
            
            UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
                completion(.success(response: result))
            }, onGenericErrorType: { error in
                completion(.error(response: error))
            })
        }
    }
}
