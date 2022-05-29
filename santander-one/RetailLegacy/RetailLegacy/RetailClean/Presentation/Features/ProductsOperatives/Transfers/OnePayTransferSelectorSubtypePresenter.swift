import CoreFoundationLib

class OnePayTransferSelectorSubtypePresenter: TransferSelectorSubtypePresenter<OnePayTransferOperativeData, SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, OnePayTransferNavigatorProtocol> {
            
    override var screenId: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferSubTypeSelector().page
        default: return nil
        }
    }
    
    override func getTrackParameters() -> [String: String]? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        return [
            TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? ""
        ]
    }
    
    override func proccessResponse(parameter: OnePayTransferOperativeData, response: SubtypeOnePayTransferUseCaseOkOutput) {
        parameter.transferNational = response.transferNational
    }
    
    override func getUseCase(subtype: OnePayTransferSubType, parameter: OnePayTransferOperativeData) -> UseCase<SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput>? {
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let amount = parameter.amount,
              let iban = parameter.iban
        else { return nil }
        let isSpanishResident = parameter.spainResident ?? false
        let saveAsUsual = parameter.saveToFavorites ?? false
  
        var input = SubtypeOnePayTransferUseCaseInput(originAccount: originAccount,
                                                      amount: amount,
                                                      maxAmount: parameter.maxImmediateNationalAmount,
                                                      subtype: subtype,
                                                      type: type,
                                                      beneficiary: parameter.name,
                                                      isSpanishResident: isSpanishResident,
                                                      iban: iban,
                                                      saveAsUsual: saveAsUsual,
                                                      saveAsUsualAlias: parameter.alias,
                                                      concept: parameter.concept,
                                                      tokenPush: nil)
        var transferType: TransferStrategyType?
        if let inputType = parameter.type, let inputTime = parameter.time {
            transferType = TransferStrategyType.transferType(type: inputType,
                                                         time: inputTime)
        }
        if parameter.isBiometryEnabled, transferType == .national {
            input.tokenPush = parameter.tokenPush
            return dependencies.useCaseProvider.getSubtypeOnePaySanKeyTransferUseCase(input: input)
        } else {
            return dependencies.useCaseProvider.getSubtypeOnePayTransferUseCase(input: input)
        }
        
    }
}
