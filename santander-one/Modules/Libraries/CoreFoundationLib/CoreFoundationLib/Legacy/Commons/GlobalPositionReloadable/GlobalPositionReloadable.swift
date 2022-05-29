import Foundation

/// The engine to handle the global position changes
public final class GlobalPositionReloadEngine {
    
    private var reloadableList: [WeakReference<GlobalPositionReloadable>]
    
    public init() {
        self.reloadableList = []
    }
    
    public func add(_ globalPositionReloadable: GlobalPositionReloadable) {
        let isAlreadyRefereneced = self.reloadableList.first {
            return $0.reference === globalPositionReloadable
        } != nil
        guard !isAlreadyRefereneced else { return }
        self.reloadableList.append(WeakReference(reference: globalPositionReloadable))
    }
    
    public func globalPositionDidReload() {
        self.reloadableList = self.reloadableList.filter { $0.reference != nil }
        self.reloadableList.forEach { $0.reference?.reload() }
    }
    
    public func removeList() {
        self.reloadableList = []
    }
}

/// Implement this protocol in any Presenter or class that needs to be reloaded when global position did reload
public protocol GlobalPositionReloadable: AnyObject {
    func reload()
}
