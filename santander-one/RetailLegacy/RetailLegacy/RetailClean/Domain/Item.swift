import CoreFoundationLib
import Foundation
import CoreDomain

struct Item {
    let representable: ItemRepresentable
    
    public init(_ dto: ItemDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    var dto: ItemDTO {
        precondition((representable as? ItemDTO) != nil)
        return representable as! ItemDTO
    }
    // swiftlint:enable force_cast
    
    init(_ representable: ItemRepresentable) {
        self.representable = representable
    }
    
    var name: String? {
        return representable.name
    }
    
    var link: String? {
        return representable.link
    }
}
