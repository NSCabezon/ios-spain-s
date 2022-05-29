//
//  SPConfirmSendMoneyNoSepaUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 18/3/22.
//

import CoreFoundationLib
import TransferOperatives
import SANSpainLibrary
import CoreDomain
import Operative

final class SPConfirmSendMoneyNoSepaUseCase: UseCase<ConfirmNoSepaSendMoneyUseCaseInput, SendMoneyOperativeData, GenericErrorOTPErrorOutput>, ConfirmSendMoneyNoSepaUseCaseProtocol, OTPUseCaseProtocol {
    
    let dependenciesResolver: DependenciesResolver
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.trusteerRepository = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: ConfirmNoSepaSendMoneyUseCaseInput) throws -> UseCaseResponse<SendMoneyOperativeData, GenericErrorOTPErrorOutput> {
        guard let input = self.getSPConfirmSendMoneyNoSepaUseCaseInput(requestValues: requestValues) else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil) )
        }
        let transferRepository: SpainTransfersRepository = self.dependenciesResolver.resolve()
        let response = try transferRepository.confirmSendMoneyNoSepa(input: input)
        switch response {
        case .success(let confirmationNoSepa):
            let operativeData = requestValues.operativeData
            if confirmationNoSepa.result == "PE" {
                operativeData.summaryState = .error()
            } else {
                operativeData.summaryState = .success()
            }
            return .ok(operativeData)
        case .failure(let error):
            let nsError = error as NSError
            let errorDescription = nsError.localizedDescription
            let otpType = self.getSendMoneyOTPResult(errorMessage: errorDescription)
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, nsError.errorCode))
        }
    }
}

extension SPConfirmSendMoneyNoSepaUseCase: SendMoneyNoSEPAInputCreatorCapable {}
private extension SPConfirmSendMoneyNoSepaUseCase {
    var trusteerInfo: TrusteerInfoRepresentable? {
        guard
            let appSessiondId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersDeferred) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessiondId, appConfigRepository: appConfigRepository)
    }
    
    func getSPConfirmSendMoneyNoSepaUseCaseInput(requestValues: ConfirmNoSepaSendMoneyUseCaseInput) -> SPConfirmSendMoneyNoSepaUseCaseInput? {
        let operativeData = requestValues.operativeData
        guard let validationNoSepa = operativeData.noSepaTransferValidation,
              let noSepaTransferInput = self.getNoSepaTransferInput(requestValues: operativeData)
        else { return nil }
        return SPConfirmSendMoneyNoSepaUseCaseInput(
            otpCode: requestValues.otpCode,
            otpValidation: requestValues.otpValidation,
            validationNoSepa: validationNoSepa,
            validationSwift: operativeData.swiftValidationRepresentable,
            noSepaTransferInput: noSepaTransferInput,
            countryCode: operativeData.countryCode,
            aliasPayee: operativeData.destinationAlias,
            isNewPayee: operativeData.saveToFavorite,
            trusteerInfo: self.trusteerInfo
        )
    }
}
