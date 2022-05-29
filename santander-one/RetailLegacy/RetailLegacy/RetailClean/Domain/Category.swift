import CoreFoundationLib
import Foundation
import CoreDomain

struct Category {
    let representable: CategoryRepresentable
    
    init(_ dto: CategoryDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    var dto: CategoryDTO {
        precondition((representable as? CategoryDTO) != nil)
        return representable as! CategoryDTO
    }
    // swiftlint:enable force_cast
    
    init(_ representable: CategoryRepresentable) {
        self.representable = representable
    }
    
    var name: String? {
        return representable.name
    }
    
    var imageRelativeURL: String? {
        return representable.imageRelativeURL
    }
    
    var iconRelativeURL: String? {
        return representable.iconRelativeURL
    }
    
    var items: [ItemRepresentable]? {
        guard let itemsRepresentable = representable.itemsRepresentable else { return nil }
        var items: [ItemRepresentable] = []
        for itemRepresentable in itemsRepresentable {
            items.append(itemRepresentable)
        }
        return items
    }
}
