import Foundation
import CoreFoundationLib
import CoreDomain

struct ServicesForYou {
    let representable: ServicesForYouRepresentable
    
    init(_ dto: ServicesForYouDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    var dto: ServicesForYouDTO {
        precondition((representable as? ServicesForYouDTO) != nil)
        return representable as! ServicesForYouDTO
    }
    // swiftlint:enable force_cast
    
    init(_ representable: ServicesForYouRepresentable) {
        self.representable = representable
    }
    
    var categories: [CategoryRepresentable]? {
        var categoriesRepresentable: [CategoryRepresentable] = []
        for categoryRepresentable in representable.categoriesRepresentable {
            categoriesRepresentable.append(categoryRepresentable)
        }
        return categoriesRepresentable
    }
}
