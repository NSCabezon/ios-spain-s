import CoreFoundationLib
import Transfer
import TransferOperatives

class OnePayTransferConfirmationPresenter: TransferConfirmationPresenter<OnePayTransferOperativeData, ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, OnePayTransferNavigatorProtocol> {
    
    override var screenId: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferConfirmationPage().page
        case .sepa?: return TrackerPagePrivate.InternationalTransferConfirmation().page
        default: return nil
        }
    }
    
    override func getTrackParameters() -> [String: String]? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return [
            TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? "",
            TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
        ]
    }
    
    override func proccessResponse(parameter: OnePayTransferOperativeData, response: ValidateOnePayTransferUseCaseOkOutput) {
        parameter.transferNational = response.transferNational
        parameter.scheduledTransfer = response.scheduledTransfer
    }
    
    override func getUseCase(mail: String?, parameter: OnePayTransferOperativeData) -> UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput>? {
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let destinationIBAN = parameter.iban,
              let amount = parameter.amount,
              let subType = parameter.subType,
              let time = parameter.time,
              let input = getUseCaseInput(mail: mail,
                                          parameter: parameter)
        else { return nil }
        var useCase: UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput>
        var transferType: TransferStrategyType?
        if let inputType = parameter.type, let inputTime = parameter.time {
            transferType = TransferStrategyType.transferType(type: inputType,
                                                         time: inputTime)
        }
        if parameter.isBiometryAppConfigEnabled, transferType == .national {
            useCase = dependencies.useCaseProvider.getValidateOnePaySanKeyTransferUseCase(input: input)
        } else {
            useCase = dependencies.useCaseProvider.getValidateOnePayTransferUseCase(input: input)
        }
        return useCase
    }
    
     override func getUseCaseInput(mail: String?, parameter: OnePayTransferOperativeData) -> ValidateOnePayTransferUseCaseInput? {
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let destinationIBAN = parameter.iban,
              let amount = parameter.amount,
              let subType = parameter.subType,
              let time = parameter.time
        else { return nil }
        let useCaseInput = ValidateOnePayTransferUseCaseInput(
            originAccount: originAccount,
            destinationIBAN: destinationIBAN,
            name: parameter.name,
            alias: parameter.alias,
            isSpanishResident: parameter.spainResident ?? true,
            saveFavorites: parameter.saveToFavorites ?? false,
            beneficiaryMail: mail,
            amount: amount,
            concept: parameter.concept,
            type: type,
            subType: subType,
            time: time,
            scheduledTransfer: parameter.scheduledTransfer,
            tokenPush: parameter.userPreffersBiometry ? parameter.tokenPush : nil
        )
        return useCaseInput
    }
    
    override func continueWithBiometricValidation() {
        self.validateWithBiometry()
    }

    override func modifyAmountAndConcept() {
        self.container?.backModify(controller: OnePayTransferSelectorViewController.self)
    }
    
    override func modifyOriginAccount() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        if parameter.isProductSelectedWhenCreated {
            container?.operativeContainerNavigator.backOnePay(parameter.list)
        } else {            
            self.container?.backModify(controller: OnePayAccountSelectorViewController.self)
        }
    }
    
    override func modifyTransferType() {
        self.container?.backModify(controller: TransferSelectorSubtypeViewController.self)
    }
    
    override func modifyDestinationAccount() {
        self.container?.backModify(controller: OnePayTransferDestinationViewController.self)
    }
    
    override func modifyCountry() {
        self.container?.backModify(controller: OnePayTransferSelectorViewController.self)
    }
    
    override func modifyIssueDate() {
        self.container?.backModify(controller: OnePayTransferDestinationViewController.self)
    }
    
    override func modifyPeriodic() {
        self.container?.backModify(controller: OnePayTransferDestinationViewController.self)
    }

    override func setSummaryState(with state: OnePayTransferSummaryState) {
        if let isNotMandatorySCASteps = dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isNotMandatorySCASteps,
           isNotMandatorySCASteps {
            let parameter: OnePayTransferOperativeData = containerParameter()
            parameter.summaryState = state
            container?.saveParameter(parameter: parameter)
        }
    }
    
    override func validateWithBiometry() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        parameter.userPreffersBiometry = false
        container?.saveParameter(parameter: parameter)
        guard
            let navigator = dependenciesResolver.resolve(firstOptionalTypeOf: SanKeyNavigatorProtocol.self),
            let navController = self.container?.operativeContainerNavigator.navigationController
        else { return }
        navigator.openSanKeyNavigatorFrom(navController, delegate: self)
    }
}
