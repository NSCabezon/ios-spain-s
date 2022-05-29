public struct WeakReference<T> {
    
    private weak var _reference: AnyObject?
    
    public init(reference: T) {
        _reference = reference as AnyObject
    }
    
    public var reference: T? {
        guard let subscriptor = _reference as? T else {
            return nil
        }
        return subscriptor
    }
}
