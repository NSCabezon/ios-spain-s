import CoreFoundationLib

class UsualTransferConfirmationPresenter: TransferConfirmationPresenter<UsualTransferOperativeData, ValidateUsualTransferUseCaseInput, ValidateUsualTransferUseCaseOkOutput, VoidNavigator> {
    override var screenId: String? {
        return TrackerPagePrivate.UsualTransferConfirmation().page
    }
    
    override func getTrackParameters() -> [String: String]? {
        let parameter: UsualTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?:
            return [
                TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
            ]
        default:
            return nil
        }
    }
    
    override func proccessResponse(parameter: UsualTransferOperativeData, response: ValidateUsualTransferUseCaseOkOutput) {
        parameter.transferNational = response.transferNational
    }
    
    override func getUseCase(mail: String?, parameter: UsualTransferOperativeData) -> UseCase<ValidateUsualTransferUseCaseInput, ValidateUsualTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput>? {
        guard let input = getUseCaseInput(mail: mail,
                                          parameter: parameter)
        else { return nil }
        let usecase = dependencies.useCaseProvider.getValidateUsualTransferUseCaseInput(input: input)
        return usecase
    }
    
    override func getUseCaseInput(mail: String?, parameter: UsualTransferOperativeData) -> ValidateUsualTransferUseCaseInput? {
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let amount = parameter.amount,
              let subType = parameter.subType
        else { return nil }
        let useCaseInput = ValidateUsualTransferUseCaseInput(originAccount: originAccount,
                                                             favourite: parameter.originTransfer,
                                                             beneficiaryMail: mail,
                                                             amount: amount,
                                                             concept: parameter.concept,
                                                             type: type,
                                                             subType: subType)
        return useCaseInput
    }
    override func modifyAmountAndConcept() {
        self.container?.backModify(controller: FormViewController.self)
    }
    
    override func modifyOriginAccount() {
        self.container?.backModify(controller: OnePayAccountSelectorViewController.self)
    }
    
    override func modifyTransferType() {
        self.container?.backModify(controller: TransferSelectorSubtypeViewController.self)
    }
}
