import Foundation

enum OrderType {
    case buy
    case sale
    
    var orderDescriptionKey: String {
        switch self {
        case .buy:
            return "orderKind_label_buy"
        case .sale:
            return "orderKind_label_sale"
        }
    }
}
