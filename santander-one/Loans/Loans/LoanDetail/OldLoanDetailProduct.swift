import Foundation

struct OldLoanDetailProduct {
    
    enum OldLoanDetailProductType {
        case basic
        case icon
    }
    
    let title: String
    let value: String
    let type: OldLoanDetailProductType
    let tooltipText: String?
    let titleIdentifier: String?
    let valueIdentifier: String?
    let iconIdentifier: String?
}
