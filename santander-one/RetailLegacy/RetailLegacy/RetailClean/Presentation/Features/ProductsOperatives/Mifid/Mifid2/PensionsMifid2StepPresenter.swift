class PensionsMifid2StepPresenter: Mifid2StepPresenter {
    // MARK: - Tracking
    override var screenId: String? {
        return TrackerPagePrivate.PensionExtraordinaryContributionMifid().page
    }
    
    override func validate(completion: @escaping (Mifid2Response) -> Void) {
        guard let container = container else {
            return
        }
        
        let input = PensionsMifid2IndicatorsUseCaseInput(mifidOperative: container.mifidOperative)
        let useCase = useCaseProvider.pensionsMifid2IndicatorsUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
