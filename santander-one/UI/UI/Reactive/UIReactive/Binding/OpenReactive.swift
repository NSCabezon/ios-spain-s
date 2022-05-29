import Foundation

public struct UIReactive<Base> {
    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol UIReactiveCompatible {
    associatedtype CompatibleType
    var bindable: UIReactive<CompatibleType> { get set }
}

extension UIReactiveCompatible {
    public var bindable: UIReactive<Self> {
        get { return UIReactive(self) }
        set {}
    }
}

extension NSObject: UIReactiveCompatible {}
