//
//  Signature.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 17/01/2020.
//

import Foundation
import CoreDomain

import SANLegacyLibrary

public typealias SignatureResultEntity = CoreDomain.SignatureResultEntity

public class GenericErrorSignatureErrorOutput: StringErrorOutput {
    
    public let signatureResult: SignatureResultEntity
    public let errorCode: String?
    
    public init(_ errorDesc: String?, _ signatureResultType: SignatureResultEntity, _ errorCode: String?) {
        self.signatureResult = signatureResultType
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}

extension UseCase {
    
    public func processSignatureResult<T>(_ bSANResponse: BSANResponse<T>) throws -> SignatureResultEntity {
        if bSANResponse.isSuccess() {
            return SignatureResultEntity.ok
        } else if try bSANResponse.getErrorCode() == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            return SignatureResultEntity.otpUserExcepted
        } else {
            guard let errorMessage = try bSANResponse.getErrorMessage() else {
                return SignatureResultEntity.otherError
            }
            let uppercaseInsensitiveErrorMessage = errorMessage.uppercased().deleteAccent()
            if uppercaseInsensitiveErrorMessage.contains("REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SU CLAVE DE FIRMA HA SIDO REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. FIRMA REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00004")
                || uppercaseInsensitiveErrorMessage.contains("50201004")
                || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009003") {
                return SignatureResultEntity.revoked
            } else if uppercaseInsensitiveErrorMessage.contains("INVALIDO")
                        || uppercaseInsensitiveErrorMessage.contains("ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LOS VALORES DE LA FIRMA POR POSICIONES NO SON CORRECTOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. DATOS INVALIDOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE DE FIRMA INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "FIRMA POR POSICIONES INCORRECTA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00003")
                        || uppercaseInsensitiveErrorMessage.contains("50201001")
                        || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009000") {
                return SignatureResultEntity.invalid
            }
        }
        
        return SignatureResultEntity.otherError
    }
}
