import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class LoanDetail: Loan {
    
    private(set) var loanDetailDTO: LoanDetailDTO
    
    static func create(_ dto: LoanDTO, detailDTO: LoanDetailDTO) -> LoanDetail {
        return LoanDetail(dto, detailDTO: detailDTO)
    }
    
    private init(_ dto: LoanDTO, detailDTO: LoanDetailDTO) {
        self.loanDetailDTO = detailDTO
        super.init(LoanEntity(dto))
    }
    
    var getHolder: String? { return loanDetailDTO.holder }
    var getLinkedAccountContract: String? { return loanDetailDTO.linkedAccountContract?.formattedValue }
    var getLinkedAccountDesc: String? { return loanDetailDTO.linkedAccountDesc }
    var getInterestType: String? { return loanDetailDTO.interestType }
    var getInterestTypeDesc: String? { return loanDetailDTO.interestTypeDesc }
    var getFeePeriodicDesc: String? { return loanDetailDTO.feePeriodDesc }
    var getCurrentInterestAmount: String? { return loanDetailDTO.currentInterestAmount }
    var getOpeningDate: Date? { return loanDetailDTO.openingDate }
    var getInitialDueDate: Date? { return loanDetailDTO.initialDueDate }
    var getCurrentDueDate: Date? { return loanDetailDTO.currentDueDate }
    var getNextInstallmentDate: Date? { return loanDetailDTO.nextInstallmentDate }
    var getInitialAmount: String? {
        guard let initialAmount = loanDetailDTO.initialAmount else { return nil }
        return Amount.createFromDTO(initialAmount).getFormattedAmountUIWith1M()
    }
    
}
