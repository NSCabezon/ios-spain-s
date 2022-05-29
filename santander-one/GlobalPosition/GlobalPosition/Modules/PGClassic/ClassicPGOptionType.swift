import UIKit
import UI

protocol ClassicPGOptionType {
    var icon: UIImage? { get }
    var text: String { get }
    var content: String? { get }
    var action: () -> Void { get }
}

struct ClassicPGOption: ClassicPGOptionType {
    var imageKey: String
    var text: String
    var content: String?
    var action: () -> Void
    
    var icon: UIImage? {
        UIImage(named: imageKey)
    }
}
