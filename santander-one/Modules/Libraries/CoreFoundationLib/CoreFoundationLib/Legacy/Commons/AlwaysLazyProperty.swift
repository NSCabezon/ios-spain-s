public class AlwaysLazyProperty<T> {
    public var property: T? {
        get {
            if let property = _property {
                return property
            }
            
            _property = build()
            
            return _property
        }
        set {
            _property = newValue
        }
    }
    public var build: () -> T
    private var _property: T?
    
    public init(build: @escaping () -> T) {
        self.build = build
    }
}
