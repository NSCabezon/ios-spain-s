import Foundation
import CoreFoundationLib
import CoreDomain

struct SpainDigitalProfileItem: DigitalProfileElemProtocol {
    var identifier: String = "bizum"
    func value() -> Int {
        return 10
    }
    func trackName() -> String {
        return "bizum"
    }
    func desc() -> String {
        return "frequentOperative_button_bizum"
    }
    func title() -> String {
        return "frequentOperative_button_bizum"
    }
    
    func accessibilityIdentifier() -> String {
        return "digitalProfile_label_bizum"
    }
}
