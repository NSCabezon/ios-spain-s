import UIKit
import CoreFoundationLib

public class AppEventsNotifier {
    
    private var willResignActiveSubscriptors = [WeakReference<AppEventWillResignActiveSuscriptor>]()
    private var willEnterForegroundSubscriptors = [WeakReference<AppEventWillEnterForegroundSuscriptor>]()
    private var willDidBecomeActiveSubscriptors = [WeakReference<AppEventDidBecomeActiveSuscriptor>]()
    
    public init() {
        prepare()
    }
    
    private func prepare() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

private extension AppEventsNotifier {
    
    @objc private func applicationWillResignActive() {
        self.willResignActiveSubscriptors.forEach { $0.reference?.applicationWillResignActive() }
    }
    
    @objc private func applicationDidBecomeActive() {
        self.willDidBecomeActiveSubscriptors.forEach { $0.reference?.applicationDidBecomeActive() }
    }
    
    @objc private func applicationWillEnterForeground() {
        self.willEnterForegroundSubscriptors.forEach { $0.reference?.applicationWillEnterForeground() }
    }
}

extension AppEventsNotifier: AppEventsNotifierProtocol {

    public func add(willEnterForegroundSubscriptor subscriptor: AppEventWillEnterForegroundSuscriptor) {
        self.willEnterForegroundSubscriptors.append(WeakReference(reference: subscriptor))
    }
    
    public func remove(willEnterForegroundSubscriptor subscriptor: AppEventWillEnterForegroundSuscriptor) {
        self.willEnterForegroundSubscriptors.removeAll(where: { $0.reference?.subscriptorIdentifier == subscriptor.subscriptorIdentifier })
    }
    
    public func add(didBecomeActiveSubscriptor subscriptor: AppEventDidBecomeActiveSuscriptor) {
        self.willDidBecomeActiveSubscriptors.append(WeakReference(reference: subscriptor))
    }
    
    public func remove(didBecomeActiveSubscriptor subscriptor: AppEventDidBecomeActiveSuscriptor) {
        self.willDidBecomeActiveSubscriptors.removeAll(where: { $0.reference?.subscriptorIdentifier == subscriptor.subscriptorIdentifier })
    }
    
    public func add(willResignActiveSubscriptor subscriptor: AppEventWillResignActiveSuscriptor) {
        self.willResignActiveSubscriptors.append(WeakReference(reference: subscriptor))
    }
    
    public func remove(willResignActiveSubscriptor subscriptor: AppEventWillResignActiveSuscriptor) {
        self.willResignActiveSubscriptors.removeAll(where: { $0.reference?.subscriptorIdentifier == subscriptor.subscriptorIdentifier })
    }
}
