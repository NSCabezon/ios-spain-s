class FundSubscriptionMifidAvisoryClausesPresenter: MifidAdvisoryClausesStepPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.FundSubscriptionMifid().page
    }

    // MARK: -

    override func validate(completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        guard let container = container else {
            return
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let transaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        switch transaction.fundSubscriptionType {
        case .amount:
            amountSubscription(withContainer: container, completion: completion)
        case .participation:
            sharesSubscription(withContainer: container, completion: completion)
        }
    }
    
    private func amountSubscription(withContainer container: MifidContainerProtocol, completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        guard let amount = fundSubscriptionTransaction.amount else {
            return
        }
        let parameters = MifidFundSubscriptionAmountData(fund: fund, amount: amount)
        let input = FundSubscriptionAmountAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundSubscriptionAmountAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
    
    private func sharesSubscription(withContainer container: MifidContainerProtocol, completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        guard let shares = fundSubscriptionTransaction.shares else {
            return
        }
        let parameters = MifidFundSubscriptionSharesData(fund: fund, shares: shares)
        let input = FundSubscriptionSharesAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.fundSubscriptionSharesAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
