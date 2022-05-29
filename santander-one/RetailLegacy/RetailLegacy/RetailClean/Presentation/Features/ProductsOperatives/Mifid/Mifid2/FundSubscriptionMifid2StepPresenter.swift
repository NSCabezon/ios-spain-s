class FundSubscriptionMifid2StepPresenter: Mifid2StepPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.FundSubscriptionMifid().page
    }

    // MARK: -

    override func validate(completion: @escaping (Mifid2Response) -> Void) {
        guard let container = container else {
            return
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.fundDetail else {
            return
        }
        let input = FundsMifid2IndicatorsUseCaseInput(mifidOperative: container.mifidOperative, product: fund)
        let useCase = useCaseProvider.fundsMifid2IndicatorsUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
