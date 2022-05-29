import Foundation
import CoreFoundationLib
import SANLegacyLibrary

extension UseCase {

    func checkRepositoryResponse<T>(_ bsanResponse: BSANResponse<T>) throws -> T? {
        if bsanResponse.isSuccess() {
            return try bsanResponse.getResponseData()
        }
        throw IllegalResponseException("illegal response")
    }

    func checkRepositoryResponse<T>(_ repositoryResponse: RepositoryResponse<T>) throws -> T? {
        if repositoryResponse.isSuccess() {
            return try repositoryResponse.getResponseData()
        }
        throw IllegalResponseException("illegal response")
    }
}

func getSignatureResult<T>(_ bSANResponse: BSANResponse<T>) throws -> SignatureResult {
    if bSANResponse.isSuccess() {
        return SignatureResult.ok
    } else if try bSANResponse.getErrorCode() == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
        return SignatureResult.otpUserExcepted
    } else {
        
        guard let errorMessage = try bSANResponse.getErrorMessage() else {
            return SignatureResult.otherError
        }
        let uppercaseInsensitiveErrorMessage = errorMessage.uppercased().deleteAccent()
        
        if uppercaseInsensitiveErrorMessage.contains("REVOCADA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "SU CLAVE DE FIRMA HA SIDO REVOCADA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. FIRMA REVOCADA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00004") {
            return SignatureResult.revoked
        } else if uppercaseInsensitiveErrorMessage.contains("INVALIDO") ||
            uppercaseInsensitiveErrorMessage.contains("ERRONEA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "LOS VALORES DE LA FIRMA POR POSICIONES NO SON CORRECTOS") ||
            uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. DATOS INVALIDOS") ||
            uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE INTRODUCIDA ES ERRONEA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE DE FIRMA INTRODUCIDA ES ERRONEA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "FIRMA POR POSICIONES INCORRECTA") ||
            uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00003") {
            return SignatureResult.invalid
        }
    }
    
    return SignatureResult.otherError
}

func getOTPResult<T>(_ bSANResponse: BSANResponse<T>) throws -> OTPResult {
    if bSANResponse.isSuccess() {
        return .ok
    } else {
        guard let errorMessage = try bSANResponse.getErrorMessage() else {
            return .serviceDefault
        }
        let errorMessageLowercased = errorMessage.lowercased().deleteAccent()
        guard errorMessageLowercased.contains(OTPErrorMessages.otpFailed1)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed2)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed3)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed4)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed5)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed6)
                || errorMessageLowercased.contains(OTPErrorMessages.otpFailed7) else {
            return .otherError(errorDesc: errorMessage)
        }
        return .wrongOTP
    }
}

public enum OTPResult {
    case ok
    case wrongOTP
    case serviceDefault
    case otherError(errorDesc: String)
}

public enum SignatureResult {
    case ok
    case revoked
    case invalid
    case otpUserExcepted
    case otherError
}
