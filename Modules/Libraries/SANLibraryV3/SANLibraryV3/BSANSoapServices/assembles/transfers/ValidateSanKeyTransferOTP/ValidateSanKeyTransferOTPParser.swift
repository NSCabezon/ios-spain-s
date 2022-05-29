//
//  ValidateSanKeyTransferOTPParser.swift
//  SANLibraryV3
//
//  Created by Andres Aguirre Juarez on 25/10/21.
//

import Foundation
import Fuzi

public class ValidateSanKeyTransferOTPParser: BSANParser<ValidateSanKeyTransferOTPResponse, ValidateSanKeyTransferOTPHandler> {
    override func setResponseData() {
        response.sanKeyOtpValidationDTO = handler.sanKeyOtpValidationDTO
    }
}

public class ValidateSanKeyTransferOTPHandler: BSANHandler {
    var sanKeyOtpValidationDTO = SanKeyOTPValidationDTO()
    override func parseResult(result: XMLElement) throws {
        sanKeyOtpValidationDTO = SanKeyOTPValidationDTOParser.parse(result)
    }
}
