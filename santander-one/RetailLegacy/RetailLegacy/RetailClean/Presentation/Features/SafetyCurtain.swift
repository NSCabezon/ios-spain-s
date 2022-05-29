import UIKit
import CoreFoundationLib

class SafetyCurtain {
    
    private let sessionManager: CoreSessionManager
    private let appEventsNotifier: AppEventsNotifier
    private var imageView: UIImageView?
    
    private var noSafeguard: Bool = true
    
    private var window: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    init(sessionManager: CoreSessionManager, appEventsNotifier: AppEventsNotifier) {
        self.sessionManager = sessionManager
        self.appEventsNotifier = appEventsNotifier
    }
    
    func setup() {
        appEventsNotifier.add(willResignActiveSubscriptor: self)
        appEventsNotifier.add(didBecomeActiveSubscriptor: self)
        let willBeginNotification = SafetyCurtainDoormanNotifications.safeguardEventWillBeginNotification
        NotificationCenter.default.addObserver(self, selector: #selector(eventWithSafeguardWillBegin), name: willBeginNotification, object: nil)
        let didFinishNotification = SafetyCurtainDoormanNotifications.safeguardEventDidFinishNotification
        NotificationCenter.default.addObserver(self, selector: #selector(eventWithSafeguardDidFinish), name: didFinishNotification, object: nil)
    }
    
    @objc
    private func eventWithSafeguardWillBegin() {
        noSafeguard = false
    }
    
    @objc
    private func eventWithSafeguardDidFinish() {
        noSafeguard = true
    }
    
    private func cover() {
        guard noSafeguard, let window = window else { return }
        uncover()
        window.endEditing(false)
        let imageView = UIImageView(frame: window.bounds)
        imageView.setSplashImage()
        window.addSubview(imageView)
        self.imageView = imageView
        self.imageView?.contentMode = .scaleAspectFill
    }
    
    private func uncover() {
        imageView?.removeFromSuperview()
    }
}

extension SafetyCurtain: AppEventWillResignActiveSuscriptor, AppEventDidBecomeActiveSuscriptor {
    
    func applicationWillResignActive() {
        cover()
    }
    
    func applicationDidBecomeActive() {
        uncover()
    }
}
