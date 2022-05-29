//
//  ScheduledTransferDetailEntity.swift
//  Models
//
//  Created by alvola on 13/07/2021.
//

import SANLegacyLibrary
import Foundation

public final class ScheduledTransferDetailEntity {

    private(set) public var transferDetailDTO: TransferScheduledDetailDTO

    public init(dto: TransferScheduledDetailDTO) {
        transferDetailDTO = dto
    }
    
    public var iban: IBANEntity? {
        guard let iban = transferDetailDTO.iban else { return nil }
        return IBANEntity(iban)
    }

    public var beneficiary: IBANEntity? {
        guard let iban = transferDetailDTO.ibanBeneficiary else { return nil }
        return IBANEntity(iban)
    }

    public var transferAmount: AmountEntity? {
        guard let amount = transferDetailDTO.transferAmount else { return nil }
        return AmountEntity(amount)
    }
    
    public var concept: String? {
        return transferDetailDTO.concept
    }

    public var beneficiaryName: String? {
        return transferDetailDTO.beneficiary
    }

    public var nextExecutionDate: Date? {
        return transferDetailDTO.dateNextExecution
    }

    public var endDate: Date? {
        return transferDetailDTO.dateEndValidity
    }

    public var dateValidFrom: Date? {
        return transferDetailDTO.dateStartValidity
    }
    
    public var isValidForDetail: Bool {
        return transferAmount != nil &&
            beneficiaryName != nil &&
            beneficiary != nil
    }
}
