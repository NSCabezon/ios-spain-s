import Foundation
import CoreFoundationLib

final class OldLoanDetailConfiguration {

    let loan: LoanEntity
    let loanDetail: LoanDetailEntity
    
    init(loan: LoanEntity, loanDetail: LoanDetailEntity) {
        self.loan = loan
        self.loanDetail = loanDetail
    }
}
