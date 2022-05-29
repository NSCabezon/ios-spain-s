class PensionMifid1StepPresenter: Mifid1SimpleStepPresenter {
    // MARK: - Tracking
    override var screenId: String? {
        return TrackerPagePrivate.PensionExtraordinaryContributionMifid().page
    }
    
    override func validate(completion: @escaping (Mifid1SimpleResponse) -> Void) {
        guard let container = container else { return }
        
        let operativeData: ExtraContributionPensionOperativeData = container.provideParameter()
        guard let extraContributionPension = operativeData.extraContributionPension else { return }
        let pension = extraContributionPension.originPension
        let infoOperation = extraContributionPension.pensionInfoOperation
        let amount = extraContributionPension.amount
        
        let params = PensionMifidClausesParamenters(pension: pension, infoOperation: infoOperation, amount: amount, advices: operativeData.advices)
        
        let input = PensionsMifid1UseCaseInput(data: params)
        let useCase = useCaseProvider.pensionsMifid1UseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result  in
            completion(.success(response: result))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}
