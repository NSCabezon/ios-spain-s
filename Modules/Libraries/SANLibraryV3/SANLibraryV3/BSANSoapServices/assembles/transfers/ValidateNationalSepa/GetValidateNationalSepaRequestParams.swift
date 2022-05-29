//
//  GetValidateNationalSepaRequestParams.swift
//  SANLibraryV3
//
//  Created by Ignacio González Miró on 21/10/21.
//

import Foundation

public struct ValidateSanKeyTransferRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO?
    public var version: String
    public var terminalId: String
    public var language: String
    public var beneficiary: String
    public var isSpanishResidentBeneficiary: Bool
    public var saveAsUsualAlias: String?
    public var saveAsUsual: Bool
    public var beneficiaryMail: String
    public var ibandto: IBANDTO
    public var transferAmount: AmountDTO
    public var bankCode: String
    public var branchCode: String
    public var product: String
    public var contractNumber: String
    public var concept: String
    public var transferType: TransferTypeDTO
    public var tokenPush: String?
}
