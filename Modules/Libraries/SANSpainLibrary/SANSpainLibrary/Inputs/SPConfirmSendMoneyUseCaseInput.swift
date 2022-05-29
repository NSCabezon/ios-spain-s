//
//  SPConfirmSendMoneyUseCaseInput.swift
//  SANSpainLibrary
//
//  Created by José María Jiménez Pérez on 18/3/22.
//

import CoreDomain

public final class SPConfirmSendMoneyNoSepaUseCaseInput: ConfirmSendMoneyNoSepaInputRepresentable {
    public let otpCode: String
    public let otpValidation: OTPValidationRepresentable
    public let validationNoSepa: ValidationIntNoSepaRepresentable
    public let validationSwift: ValidationSwiftRepresentable?
    public let noSepaTransferInput: SendMoneyNoSEPAInput
    public let countryCode: String?
    public let aliasPayee: String?
    public let isNewPayee: Bool
    public let trusteerInfo: TrusteerInfoRepresentable?
    
    public init(otpCode: String,
                otpValidation: OTPValidationRepresentable,
                validationNoSepa: ValidationIntNoSepaRepresentable,
                validationSwift: ValidationSwiftRepresentable?,
                noSepaTransferInput: SendMoneyNoSEPAInput,
                countryCode: String?,
                aliasPayee: String?,
                isNewPayee: Bool,
                trusteerInfo: TrusteerInfoRepresentable?) {
        self.otpCode = otpCode
        self.otpValidation = otpValidation
        self.validationNoSepa = validationNoSepa
        self.validationSwift = validationSwift
        self.noSepaTransferInput = noSepaTransferInput
        self.countryCode = countryCode
        self.aliasPayee = aliasPayee
        self.isNewPayee = isNewPayee
        self.trusteerInfo = trusteerInfo
    }
}
