class FundTransferMifidAvisoryClausesPresenter: MifidAdvisoryClausesStepPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.FundSubscriptionMifid().page
    }

    // MARK: -

    override func validate(completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        guard let container = container else {
            return
        }
        
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
    
    private func total(withContainer container: MifidContainerProtocol, completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        
        let parameters = MifidFundTransferTotalData(originFund: fund, destinationFund: fundTransferTransaction.destinationFund)
        let input = FundTransferTotalAdvicesUseCaseInput( data: parameters)
        let useCase = useCaseProvider.fundTransferTotalAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
    
    private func partialByAmount(withContainer container: MifidContainerProtocol, completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        
        let destination = fundTransferTransaction.destinationFund
        guard let amount = fundTransferTransaction.amount else {
            return
        }
        
        let parameters = MifidFundTransferPartialByAmountData(originFund: fund, destinationFund: destination, amount: amount)
        let input = FundTransferPartialByAmountAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundTransferPartialByAmountAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
    
    private func partialByShares(withContainer container: MifidContainerProtocol, completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        
        let fund: Fund = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        
        let destination = fundTransferTransaction.destinationFund
        guard let shares = fundTransferTransaction.shares else {
            return
        }
        
        let parameters = MifidFundTransferPartialBySharesData(originFund: fund, destinationFund: destination, shares: shares)
        let input = FundTransferPartialBySharesAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundTransferPartialBySharesAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
