class FundTransferMifid2StepPresenter: Mifid2StepPresenter {
    override func validate(completion: @escaping (Mifid2Response) -> Void) {
        guard let container = container else {
            return
        }
        
        let fund: FundDetail = container.provideParameter()
        let input = FundsMifid2IndicatorsUseCaseInput(mifidOperative: container.mifidOperative,
                                                      product: fund)
        let useCase = useCaseProvider.fundsMifid2IndicatorsUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
