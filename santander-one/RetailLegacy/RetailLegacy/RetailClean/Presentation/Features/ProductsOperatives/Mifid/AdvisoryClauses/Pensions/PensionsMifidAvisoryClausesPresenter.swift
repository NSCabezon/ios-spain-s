class PensionsMifidAvisoryClausesPresenter: MifidAdvisoryClausesStepPresenter {
    override func validate(completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        guard let container = container else {
            return
        }
        
        let operativeData: ExtraContributionPensionOperativeData = container.provideParameter()
        guard let extraContributionPension = operativeData.extraContributionPension else { return }
        let pension = extraContributionPension.originPension
        let infoOperation = extraContributionPension.pensionInfoOperation
        let amount = extraContributionPension.amount
        
        let parameters = PensionMifidClausesParamenters(pension: pension,
                                                        infoOperation: infoOperation,
                                                        amount: amount,
                                                        advices: nil)
        let input = PensionsMifidAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.pensionsMifidAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            operativeData.advices = result.data
            completion(.success(state: result.state))
        }, onGenericErrorType: { (error)  in
            completion(.error(response: error))
        })
    }
}
