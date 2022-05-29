//
//  SendMoneyNoSEPAInput.swift
//  CoreDomain
//
//  Created by Juan Diego Vázquez Moreno on 25/1/22.
//

public struct SendMoneyNoSEPAInput {
    public let originAccountRepresentable: AccountRepresentable
    public let beneficiary: String
    public let beneficiaryAccountSwift: String?
    public let beneficiaryAccount: String
    public let beneficiaryAccountAddress: String?
    public let beneficiaryAccountLocality: String?
    public let beneficiaryAccountCountry: String
    public let beneficiaryAccountBankName: String
    public let beneficiaryAccountBankAddress: String?
    public let beneficiaryAccountBankLocation: String?
    public let beneficiaryAccountBankCountry: String?
    public let indicatorResidence: Bool
    public let dateOperation: DateModel?
    public let transferAmount: AmountRepresentable
    public let expensiveIndicator: String
    public let type: String?
    public let countryCode: String
    public let concept: String?
    public let beneficiaryEmail: String?

    public var accountType: String {
        return beneficiaryAccountSwift != nil ? "C" : "D"
    }

    public init(originAccountRepresentable: AccountRepresentable,
                beneficiary: String,
                beneficiaryAccountSwift: String?,
                beneficiaryAccount: String,
                beneficiaryAccountAddress: String?,
                beneficiaryAccountLocality: String?,
                beneficiaryAccountCountry: String,
                beneficiaryAccountBankName: String,
                beneficiaryAccountBankAddress: String?,
                beneficiaryAccountBankLocation: String?,
                beneficiaryAccountBankCountry: String?,
                indicatorResidence: Bool,
                dateOperation: DateModel?, 
                transferAmount: AmountRepresentable,
                expensiveIndicator: String,
                type: String?,
                countryCode: String,
                concept: String,
                beneficiaryEmail: String?) {
        self.originAccountRepresentable = originAccountRepresentable
        self.beneficiary = beneficiary
        self.beneficiaryAccountSwift = beneficiaryAccountSwift
        self.beneficiaryAccount = beneficiaryAccount
        self.beneficiaryAccountAddress = beneficiaryAccountAddress
        self.beneficiaryAccountLocality = beneficiaryAccountLocality
        self.beneficiaryAccountCountry = beneficiaryAccountCountry
        self.beneficiaryAccountBankName = beneficiaryAccountBankName
        self.beneficiaryAccountBankAddress = beneficiaryAccountBankAddress
        self.beneficiaryAccountBankLocation = beneficiaryAccountBankLocation
        self.beneficiaryAccountBankCountry = beneficiaryAccountBankCountry
        self.indicatorResidence = indicatorResidence
        self.dateOperation = dateOperation
        self.transferAmount = transferAmount
        self.expensiveIndicator = expensiveIndicator
        self.type = type
        self.countryCode = countryCode
        self.concept = concept
        self.beneficiaryEmail = beneficiaryEmail
    }
}
