//
//  ConfirmScheduledSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 29/07/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative
import CoreDomain

public protocol ConfirmScheduledSendMoneyUseCaseProtocol: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> {}

class ConfirmScheduledSendMoneyUseCase: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol, ValidateSendMoneyProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOtpSendMoneyUseCaseInput) throws -> UseCaseResponse<ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let sendMoneyModifier = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
        let transferType = sendMoneyModifier?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType.serviceString)
        let transferProvider: TransfersRepository = dependenciesResolver.resolve()
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
                return UseCaseResponse.error(GenericErrorOTPErrorOutput(nsError.localizedDescription, self.getOTPResult(errorMessage: nsError.localizedDescription), nsError.errorCode))
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
                otpCode: code)
            switch response {
            case .success:
                return .ok(ConfirmOtpSendMoneyUseCaseOkOutput(transferConfirmAccount: nil))
            case .failure(let error):
                let nsError = error as NSError
                let errorDescription = nsError.localizedDescription
                let otpType = getOTPResult(errorMessage: errorDescription)
                return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, nsError.errorCode))
            }
        } else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
    }
}

extension ConfirmScheduledSendMoneyUseCase: ConfirmScheduledSendMoneyUseCaseProtocol {}
