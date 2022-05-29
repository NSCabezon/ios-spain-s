//
//  ConfirmScheduledSendMoneyUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 5/1/22.
//

import TransferOperatives
import CoreFoundationLib
import Operative
import SANSpainLibrary
import SANLegacyLibrary
import CoreDomain

final class ConfirmScheduledSendMoneyUseCase: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol, ValidateSendMoneyProtocol {
    
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
        let sendMoneyModifier = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
        let transferType = sendMoneyModifier?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType.serviceString)
        let transferProvider: SpainTransfersRepository = dependenciesResolver.resolve()
        let code = requestValues.code
        if case .periodic(start: let startDate,
                          end: let endDate,
                          periodicity: let periodicity,
                          emission: let workingDayIssue) = requestValues.time,
           let otpValidation = requestValues.otpValidation {
            let periodicity = sendMoneyModifier?.serviceKeyForPeriodicity(periodicity) ?? ""
            let workingDayIssue = sendMoneyModifier?.serviceKeyForWorkingDayIssue(workingDayIssue) ?? ""
            let endDateValue: DateModel?
            switch endDate {
            case .never: endDateValue = nil
            case .date(let date): endDateValue = DateModel(date: date)
            }
            guard let input = requestValues.toSendMoneyScheduledTransferInput(startDate: startDate,
                                                                              endDate: endDateValue,
                                                                              periodicity: periodicity,
                                                                              workingDayIssue: workingDayIssue,
                                                                              iban: requestValues.destinationIBAN,
                                                                              subtype: transferType) else {
                return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
            }
            let response = try transferProvider.confirmPeriodicTransfer(
                originAccount: requestValues.originAccount,
                scheduledTransferInput: input,
                otpValidation: otpValidation,
                otpCode: code)
            switch response {
            case .success:
                return .ok(ConfirmOtpSendMoneyUseCaseOkOutput(transferConfirmAccount: nil))
            case .failure(let error):
                let nsError = error as NSError
                return UseCaseResponse.error(GenericErrorOTPErrorOutput(nsError.localizedDescription, self.getSendMoneyOTPResult(errorMessage: nsError.localizedDescription), nsError.errorCode))
            }
        } else if case .day(date: let date) = requestValues.time,
                  let otpValidation = requestValues.otpValidation {
            guard let input = requestValues.toSendMoneyScheduledTransferInput(
                    date: date,
                    iban: requestValues.destinationIBAN,
                    subType: transferType) else {
                return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
            }
            let response = try transferProvider.confirmDeferredTransfer(
                originAccount: requestValues.originAccount,
                scheduledTransferInput: input,
                otpValidation: otpValidation,
                otpCode: code,
                trusteerInfo: self.trusteerInfo)
            switch response {
            case .success:
                return .ok(ConfirmOtpSendMoneyUseCaseOkOutput(transferConfirmAccount: nil))
            case .failure(let error):
                let nsError = error as NSError
                let errorDescription = nsError.localizedDescription
                let otpType = self.getSendMoneyOTPResult(errorMessage: errorDescription)
                return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, nsError.errorCode))
            }
        } else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
    }
}

extension ConfirmScheduledSendMoneyUseCase: ConfirmScheduledSendMoneyUseCaseProtocol {}
