import SANLegacyLibrary
import Foundation
import CoreDomain

struct TransferNational {
    
    private let dto: TransferNationalDTO
    
    public init(dto: TransferNationalDTO) {
        self.dto = dto
    }
    
    var issueDate: Date? {
        dto.issueDate
    }
    
    var transferAmount: Amount? {
        Amount.createFromDTO(dto.transferAmount)
    }
    
    var bankChargeAmount: Amount? {
        Amount.createFromDTO(dto.bankChargeAmount)
    }
    
    var expensesAmount: Amount? {
        Amount.createFromDTO(dto.expensesAmount)
    }
    
    var netAmount: Amount? {
        Amount.createFromDTO(dto.netAmount)
    }
    
    var scaRepresentable: SCARepresentable? {
        dto.scaRepresentable
    }
    
    var isCorrectFingerPrintFlag: Bool {
        dto.fingerPrintFlag == .biometry
    }
    
    var tokenSteps: String? {
        dto.tokenSteps
    }
}
