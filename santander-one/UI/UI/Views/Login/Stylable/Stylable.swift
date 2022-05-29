import UIKit

public protocol Stylist {
    associatedtype T
    func performStyling(_ object: T)
}

public protocol Stylable: AnyObject {
    func applyStyle<S: Stylist>(_ stylist: S) where S.T == Self
}

extension Stylable {
    public func applyStyle<S: Stylist>(_ stylist: S) where S.T == Self {
        stylist.performStyling(self)
    }
}
