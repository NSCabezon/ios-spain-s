//
//  ConfirmOTPDeferredInternalTransferUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import CoreFoundationLib
import Operative
import Transfer
import SANSpainLibrary
import SANServicesLibrary
import SANLegacyLibrary
import CoreDomain

class ConfirmOTPDeferredInternalTransferUseCase: UseCase<ConfirmOTPInternalTransferUseCaseInput, Void, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol {
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve()
        self.trusteerRepository = dependenciesResolver.resolve()
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var trusteerInfo: TrusteerInfoRepresentable? {
        guard
            let appSessiondId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersDeferred) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessiondId, appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: ConfirmOTPInternalTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        guard case .day(date: let date) = requestValues.time, let otpValidation = requestValues.otpValidation, let code = requestValues.code, let originAccount = requestValues.originAccount, let amount = requestValues.amount else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        guard let iban = requestValues.destinationAccount?.getIban() else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        let scheduledTransfer = requestValues.scheduledTransfer
        let scheduledTransferInput = SendMoneyScheduledTransferInput(ibanDestinationRepresentable: iban.dto,
                                                                     amountRepresentable: amount.dto,
                                                                     dateNextExecution: date,
                                                                     dateStartValidity: nil,
                                                                     dateEndValidity: nil,
                                                                     concept: requestValues.concept,
                                                                     saveAsUsual: false,
                                                                     saveAsUsualAlias: "",
                                                                     beneficiary: "",
                                                                     transferType: nil,
                                                                     actuanteCompany: scheduledTransfer?.company,
                                                                     actuanteCode: scheduledTransfer?.code,
                                                                     actuanteNumber: scheduledTransfer?.number,
                                                                     periodicity: nil,
                                                                     workingDayIssue: nil)
        let response = try self.dependenciesResolver.resolve(for: SpainTransfersRepository.self)
            .confirmDeferredTransfer(originAccount: originAccount.dto,
                                     scheduledTransferInput: scheduledTransferInput,
                                     otpValidation: otpValidation.dto, otpCode: code,
                                     trusteerInfo: trusteerInfo)
        switch response {
        case .success: return .ok()
        case .failure(let error):
            guard let error = error as? ServiceError,
                  let errorMessage = error.errorDescription
            else { return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))}
            let otpType = self.getOTPResult(errorMessage: errorMessage)
            return .error(GenericErrorOTPErrorOutput(error.errorDescription, otpType, error.errorCode))
        }
    }
}

extension ConfirmOTPDeferredInternalTransferUseCase: ConfirmOTPDeferredInternalTransferUseCaseProtocol { }
