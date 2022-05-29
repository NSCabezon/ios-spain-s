import Foundation

struct LoanDetailProduct {
    
    enum LoanDetailProductType {
        case basic
        case icon
    }
    
    let title: String
    let value: String
    let type: LoanDetailProductType
    let tooltipText: String?
    let titleIdentifier: String?
    let valueIdentifier: String?
    let iconIdentifier: String?
}
