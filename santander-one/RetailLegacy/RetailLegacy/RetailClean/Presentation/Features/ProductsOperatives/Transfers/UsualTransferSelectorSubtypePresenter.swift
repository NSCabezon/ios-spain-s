import CoreFoundationLib

class UsualTransferSelectorSubtypePresenter: TransferSelectorSubtypePresenter<UsualTransferOperativeData, SubtypeUsualTransferUseCaseInput, SubtypeUsualTransferUseCaseOkOutput, VoidNavigator> {
    
    override var screenId: String? {
        return TrackerPagePrivate.UsualTransferSubTypeSelector().page
    }
    
    override func proccessResponse(parameter: UsualTransferOperativeData, response: SubtypeUsualTransferUseCaseOkOutput) {
        parameter.transferNational = response.transferNational
    }

    override func getUseCase(subtype: OnePayTransferSubType, parameter: UsualTransferOperativeData) -> UseCase<SubtypeUsualTransferUseCaseInput, SubtypeUsualTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput>? {
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let amount = parameter.amount
        else { return nil }
        let input = SubtypeUsualTransferUseCaseInput(originAccount: originAccount,
                                                     amount: amount,
                                                     maxAmount: parameter.maxImmediateNationalAmount,
                                                     subtype: subtype, type: type,
                                                     concept: parameter.concept,
                                                     favourite: parameter.originTransfer)
        let usecase = dependencies.useCaseProvider.getSubtypeUsualTransferUseCase(input: input)
        return usecase
    }
}
