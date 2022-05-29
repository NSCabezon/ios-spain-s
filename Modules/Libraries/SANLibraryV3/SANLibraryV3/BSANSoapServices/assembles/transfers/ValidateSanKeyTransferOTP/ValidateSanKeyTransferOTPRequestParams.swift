//
//  ValidateSanKeyTransferOTPRequestParams.swift
//  SANLibraryV3
//
//  Created by Andres Aguirre Juarez on 25/10/21.
//

import Foundation

struct ValidateSanKeyTransferOTPRequestParams {
    let token: String
    let userDataDTO: UserDataDTO?
    let version: String
    let terminalId: String
    let ibandto: IBANDTO
    let transferAmount: AmountDTO
    let bankCode: String
    let branchCode: String
    let product: String
    let contractNumber: String
    let signatureDTO: SignatureDTO?
    let language: String
    let dialectISO: String
    let tokenPasos: String
    let footPrint: String
    let deviceToken: String
}
