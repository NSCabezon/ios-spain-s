//
//  TransferEmittedDetailEntity.swift
//  Models
//
//  Created by alvola on 23/06/2021.
//

import SANLegacyLibrary

extension TransferEmittedDetailEntity: EmittedTransferDetailForPDFProtocol {
    public var periodicity: String? {
        // Android is doing it this way
        if origin != beneficiary {
            return nil
        }
        return "summary_label_timely"
    }
    
    public var originAsteriskIBAN: String? {
        origin?.getAsterisk()
    }
    
    public var destinyAsteriskIBAN: String? {
        beneficiary?.getAsterisk()
    }
    
    public var fees: String? {
        nil
    }
    
    public var totalAmount: String? {
        nil
    }

    public var beneficiaryIBAN: String {
        beneficiary?.ibanString ?? ""
    }
    
    public var amountToDebit: Bool {
        true
    }
}

public final class TransferEmittedDetailEntity {

    private(set) var transferDetailDTO: TransferEmittedDetailDTO
    public init(dto: TransferEmittedDetailDTO) {
        transferDetailDTO = dto
    }

    public var origin: IBANEntity? {
        guard let iban = transferDetailDTO.origin else { return nil }
        return IBANEntity(iban)
    }

    public var beneficiary: IBANEntity? {
        guard let iban = transferDetailDTO.beneficiary else { return nil }
        return IBANEntity(iban)
    }

    public var transferAmount: AmountEntity? {
        guard let amountDTO = transferDetailDTO.transferAmount else { return nil }
        return AmountEntity(amountDTO)
    }
    
    public var beneficiaryName: String? {
        return transferDetailDTO.beneficiaryName
    }
    
    public var emisionDate: Date? {
        return transferDetailDTO.emisionDate
    }
    
    public var valueDate: Date? {
        return transferDetailDTO.valueDate
    }
    
    public var feesEntity: AmountEntity? {
        guard let amountDTO = transferDetailDTO.banckCharge else { return nil }
        return AmountEntity(amountDTO)
    }
    
    public var totalAmountEntity: AmountEntity? {
        guard let amountDTO = transferDetailDTO.netAmount else { return nil }
        return AmountEntity(amountDTO)
    }
}
