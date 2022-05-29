//
//  ConfirmGenericSendMoneyUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 20/08/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative
import SANSpainLibrary
import SANServicesLibrary
import TransferOperatives
import CoreDomain

class ConfirmGenericSendMoneyUseCase: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol, ValidateSendMoneyProtocol {
    
    let dependenciesResolver: DependenciesResolver
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    private var trusteerInfo: TrusteerInfoRepresentable? {
        guard
            let appSessiondId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersDeferred) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessiondId, appConfigRepository: appConfigRepository)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = dependenciesResolver.resolve()
        self.trusteerRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: ConfirmOtpSendMoneyUseCaseInput) throws -> UseCaseResponse<ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager: SpainTransfersRepository = dependenciesResolver.resolve()
        let transferType = self.dependenciesResolver.resolve(for: SendMoneyModifierProtocol.self).transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType.serviceString)
        let input = SendMoneyGenericTransferInput(ibanRepresentable: requestValues.destinationIBAN,
                                                  amountRepresentable: requestValues.amount,
                                                  concept: requestValues.concept,
                                                  beneficiary: requestValues.name,
                                                  saveAsUsual: requestValues.saveFavorites,
                                                  saveAsUsualAlias: requestValues.alias,
                                                  transferType: transferType,
                                                  beneficiaryMail: requestValues.beneficiaryMail)
        let response = try manager.confirmGenericTransfer(
            originAccount: requestValues.originAccount,
            nationalTransferInput: input,
            otpValidation: requestValues.otpValidation,
            otpCode: requestValues.code, trusteerInfo: trusteerInfo)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(ConfirmOtpSendMoneyUseCaseOkOutput(transferConfirmAccount: TransferConfirmAccountDTO(transferConfirmAccountRepresentable: data)))
        case .failure(let error):
            let nsError = error as NSError
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(nsError.localizedDescription, self.getSendMoneyOTPResult(errorMessage: nsError.localizedDescription), nsError.errorCode))
        }
    }
}

extension ConfirmGenericSendMoneyUseCase: ConfirmGenericSendMoneyUseCaseProtocol { }
