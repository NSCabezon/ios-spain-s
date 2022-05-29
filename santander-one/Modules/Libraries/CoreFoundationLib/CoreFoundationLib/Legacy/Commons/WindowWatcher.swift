import UIKit

public protocol WindowWatcherSubscriptor: Subscriptor {
    func windowTouched()
}

public class WindowWatcher {
    public static let shared = WindowWatcher()
    
    private var subscriptors = [WeakReference<WindowWatcherSubscriptor>]()
    
    private init() {}
    
    public func add(subscriptor: WindowWatcherSubscriptor) {
        let weakReference = WeakReference<WindowWatcherSubscriptor>(reference: subscriptor)
        subscriptors += [weakReference]
    }
    
    public func remove(subscriptor: WindowWatcherSubscriptor) {
        subscriptors = subscriptors.filter { $0.reference?.subscriptorIdentifier != subscriptor.subscriptorIdentifier }
    }
    
    public func touched(view: UIView?, of window: UIWindow) {
        subscriptors.forEach { $0.reference?.windowTouched() }
    }
}

extension UIWindow {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        WindowWatcher.shared.touched(view: view, of: self)
        return view
    }
}
