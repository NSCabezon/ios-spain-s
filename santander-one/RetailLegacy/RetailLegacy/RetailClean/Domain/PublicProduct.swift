import Foundation
import CoreFoundationLib

protocol ImageTitleCollectionProtocol {
    var id: String? { get }
    var text: String? { get }
    var icon: String? { get }
    var absoluteUrl: String? { get }
    var offers: [Offer]? { get }
}

public struct PublicProductItem: Codable, ImageTitleCollectionProtocol {
    let id: String?
    let text: String?
    let icon: String?
    let absoluteUrl: String?
    var offers: [Offer]? {
        return nil
    }
    init(product: PublicProduct) {
        self.id = product.id
        self.text = product.text
        self.icon = product.icon
        self.absoluteUrl = product.absoluteUrl
    }
}
