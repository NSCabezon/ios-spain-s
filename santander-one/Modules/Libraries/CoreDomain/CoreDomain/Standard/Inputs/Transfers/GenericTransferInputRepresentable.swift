//
//  GenericTransferInputRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

public struct SendMoneyGenericTransferInput {
    public let ibanRepresentable: IBANRepresentable?
    public let amountRepresentable: AmountRepresentable?
    public let concept: String?
    public let beneficiary: String?
    public let saveAsUsual: Bool?
    public let saveAsUsualAlias: String?
    public let transferType: String?
    public let beneficiaryMail: String?
    
    public init(ibanRepresentable: IBANRepresentable?,
                amountRepresentable: AmountRepresentable?,
                concept: String?,
                beneficiary: String?,
                saveAsUsual: Bool?,
                saveAsUsualAlias: String?,
                transferType: String?,
                beneficiaryMail: String?) {
        self.ibanRepresentable = ibanRepresentable
        self.amountRepresentable = amountRepresentable
        self.concept = concept
        self.beneficiary = beneficiary
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.transferType = transferType
        self.beneficiaryMail = beneficiaryMail
    }
}
