//
//  OTPUseCaseProtocol.swift
//  Operative
//
//  Created by David Gálvez Alonso on 21/05/2020.
//

import SANLegacyLibrary

public protocol OTPUseCaseProtocol: AnyObject {
    func getOTPResult<T>(_ bSANResponse: BSANResponse<T>) throws -> OTPResult
    func getOTPResult(errorMessage: String) -> OTPResult
    func getOTPResultUsingServerMessage<T>(_ bSANResponse: BSANResponse<T>) throws -> OTPResult
    func getOTPResultUsingServerMessage(errorMessage: String) -> OTPResult
    func getSendMoneyOTPResult(errorMessage: String) -> OTPResult
}

extension OTPUseCaseProtocol {
    public func getOTPResult<T>(_ bSANResponse: BSANResponse<T>) throws -> OTPResult {
        if bSANResponse.isSuccess() {
            return OTPResult.correctOTP
        } else {
            guard let errorMessage = try bSANResponse.getErrorMessage() else {
                return OTPResult.serviceDefault
            }
            return self.handleErrorMessage(errorMessage, useServerMessage: false)
        }
    }
    
    public func getOTPResult(errorMessage: String) -> OTPResult {
        return self.handleErrorMessage(errorMessage, useServerMessage: false)
    }
    
    public func getSendMoneyOTPResult(errorMessage: String) -> OTPResult {
        let lowerCaseErrorMessage = errorMessage.lowercased().deleteAccent()
        if lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed1)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed2)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed3)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed4)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed5)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed6)
            || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed7) {
            return .wrongOTP
        } else if lowerCaseErrorMessage.contains(OTPErrorMessages.otpRevoked) {
            return .otpRevoked
        } else if lowerCaseErrorMessage.contains(OTPErrorMessages.otpExpired) {
            return .otpExpired
        }
        return .unknown
    }

    public func getOTPResultUsingServerMessage<T>(_ bSANResponse: BSANResponse<T>) throws -> OTPResult {
        if bSANResponse.isSuccess() {
            return OTPResult.correctOTP
        } else {
            guard let errorMessage = try bSANResponse.getErrorMessage() else {
                return OTPResult.serviceDefault
            }
            return self.handleErrorMessage(errorMessage, useServerMessage: true)
        }
    }

    public func getOTPResultUsingServerMessage(errorMessage: String) -> OTPResult {
        return self.handleErrorMessage(errorMessage, useServerMessage: true)
    }
}

private extension OTPUseCaseProtocol {
    func handleErrorMessage(_ errorMessage: String, useServerMessage: Bool) -> OTPResult {
        if useServerMessage {
            return .otherError(errorDesc: errorMessage)
        }
        let lowerCaseErrorMessage = errorMessage.lowercased().deleteAccent()
        guard lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed1)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed2)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed3)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed4)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed5)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed6)
                || lowerCaseErrorMessage.contains(OTPErrorMessages.otpFailed7) else {
            return .serviceDefault
        }
        return .wrongOTP
    }
}
