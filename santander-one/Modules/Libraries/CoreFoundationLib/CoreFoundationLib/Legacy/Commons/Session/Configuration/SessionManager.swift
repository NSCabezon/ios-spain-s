//
//  Session.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 6/9/21.
//

import Foundation

public enum SessionControllerErrorType {
    case logout
    case renewToken
}

public enum SessionFinishedReason: Equatable {
    case failRenewTokenService
    case failRenewTokenException
    case timeoutInactivity
    case timeoutOutOfApp
    case failedGPReload(reason: String?)
    case notAuthorized
    case unknown
    case logOut
}

public protocol SessionManagerDelegate: AnyObject {
    func didFinishSession()
}

/// Defines an action that has to be performed once the session is started
public protocol SessionStartedAction {
    var action: () -> Void { get }
}

/// Defines an action that has to be performed once the session is finished
public protocol SessionFinishedAction {
    var action: (SessionFinishedReason) -> Void { get }
}

/// Defines the country implementation of configuration for session
public struct SessionConfiguration {
    let timeToExpireSession: TimeInterval
    let timeToRefreshToken: TimeInterval?
    let sessionStartedActions: [SessionStartedAction]
    let sessionFinishedActions: [SessionFinishedAction]
    
    public init(timeToExpireSession: TimeInterval, timeToRefreshToken: TimeInterval?, sessionStartedActions: [SessionStartedAction], sessionFinishedActions: [SessionFinishedAction]) {
        self.timeToExpireSession = timeToExpireSession
        self.timeToRefreshToken = timeToRefreshToken
        self.sessionStartedActions = sessionStartedActions
        self.sessionFinishedActions = sessionFinishedActions
    }
}

public protocol CoreSessionManager {
    var configuration: SessionConfiguration { get }
    var isSessionActive: Bool { get }
    var lastFinishedSessionReason: SessionFinishedReason? { get }
    func setLastFinishedSessionReason(_ reason: SessionFinishedReason)
    func sessionStarted(completion: (() -> Void)?)
    func finishWithReason(_ reason: SessionFinishedReason)
}

public enum SessionState {
    case idle
    case logged
}

public class DefaultSessionManager {
    
    public let configuration: SessionConfiguration
    public var lastFinishedSessionReason: SessionFinishedReason?
    
    private let dependenciesResolver: DependenciesResolver
    private var expireSessionTimer: SessionTimer?
    private var refreshSessionTimer: SessionTimer?
    private let appEventsNotifier: AppEventsNotifierProtocol
    private weak var delegate: SessionManagerDelegate?
    private var userSessionState: SessionState = .idle {
        didSet {
            switch userSessionState {
            case .idle:
                stop()
            case .logged:
                start()
            }
        }
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = dependenciesResolver.resolve()
        self.appEventsNotifier = dependenciesResolver.resolve()
        NotificationCenter.default.addObserver(self, selector: #selector(onWindowTouched), name: .windowTouched, object: nil)
    }
}

extension DefaultSessionManager: CoreSessionManager {
    
    public func setLastFinishedSessionReason(_ reason: SessionFinishedReason) {
        self.lastFinishedSessionReason = reason
    }
    
    public func sessionStarted(completion: (() -> Void)?) {
        userSessionState = .logged
        self.delegate = dependenciesResolver.resolve(forOptionalType: SessionManagerDelegate.self)
        let actions = configuration.sessionStartedActions
        let group = DispatchGroup()
        actions.forEach { action in
            group.enter()
            action.action()
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            completion?()
        }
    }
    
    public func finishWithReason(_ reason: SessionFinishedReason) {
        configuration.sessionFinishedActions.forEach { action in
            action.action(reason)
        }
        lastFinishedSessionReason = reason
        logout()
    }
    
    public var isSessionActive: Bool {
        return userSessionState == .logged
    }
}

public extension DefaultSessionManager {
    
    struct DefaultSessionFinishedAction: SessionFinishedAction {
        
        let dependenciesResolver: DependenciesResolver
        
        init(dependenciesResolver: DependenciesResolver) {
            self.dependenciesResolver = dependenciesResolver
        }
        
        public var action: (SessionFinishedReason) -> Void {
            return { _ in
                self.dependenciesResolver.resolve(for: UseCaseHandler.self).stopAll()
                self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).removeList()
                self.dependenciesResolver.resolve(for: WebViewCacheProtocol.self).clearCookies()
            }
        }
    }
}

private extension DefaultSessionManager {
    var refreshSessionUseCase: RefreshSessionUseCase {
        return dependenciesResolver.resolve(firstTypeOf: RefreshSessionUseCase.self)
    }
    
    var logoutUseCase: LogoutUseCase {
        return dependenciesResolver.resolve(firstTypeOf: LogoutUseCase.self)
    }
    
    func setup() {
        setupExpireSessionTimer()
        setupRefreshSessionTimer()
    }
    
    func setupExpireSessionTimer() {
        stop(timer: &expireSessionTimer)
        expireSessionTimer = SessionTimer(timeout: configuration.timeToExpireSession) { [weak self] in
            guard let self = self else { return }
            self.stop(timer: &self.expireSessionTimer)
            self.finishWithReason(.timeoutInactivity)
        }
        expireSessionTimer?.createTimer()
    }
    
    func setupRefreshSessionTimer() {
        guard let timeToRefreshToken = configuration.timeToRefreshToken else { return }
        stop(timer: &refreshSessionTimer)
        refreshSessionTimer = SessionTimer(timeout: timeToRefreshToken) { [weak self] in
            guard let self = self else { return }
            self.stop(timer: &self.refreshSessionTimer)
            self.refreshSession()
        }
        refreshSessionTimer?.createTimer()
    }
    
    func start() {
        appEventsNotifier.add(willResignActiveSubscriptor: self)
        appEventsNotifier.add(didBecomeActiveSubscriptor: self)
        WindowWatcher.shared.add(subscriptor: self)
        setup()
    }
    
    func stop() {
        stop(timer: &refreshSessionTimer)
        refreshSessionTimer = nil
        stop(timer: &expireSessionTimer)
        expireSessionTimer = nil
        appEventsNotifier.remove(willResignActiveSubscriptor: self)
        appEventsNotifier.remove(didBecomeActiveSubscriptor: self)
    }
    
    func stop(timer: inout SessionTimer?) {
        timer?.stop()
    }
    
    func refreshSession() {
        Scenario(useCase: refreshSessionUseCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] in
                self?.setupRefreshSessionTimer()
            }
            .onError { [weak self] _ in
                self?.finishWithReason(.failRenewTokenService)
            }
    }
    
    func logout() {
        Scenario(useCase: logoutUseCase)
            .execute(on: dependenciesResolver.resolve())
            .finally { [weak self] in
                self?.userSessionState = .idle
                self?.delegate?.didFinishSession()
            }
    }
    
    @objc func onWindowTouched() {
        setupExpireSessionTimer()
    }
}

private extension DefaultSessionManager {
    
    class SessionTimer {
        var timer: Timer?
        let timeout: TimeInterval
        let startedAt: Date
        let onFinish: () -> Void
        
        init(timeout: TimeInterval, onFinish: @escaping () -> Void) {
            self.startedAt = Date()
            self.timeout = timeout
            self.onFinish = onFinish
        }
        
        @objc func timerFired() {
            onFinish()
        }
        
        func stop() {
            timer?.invalidate()
        }
        
         func createTimer() {
            self.timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        }
    }
}

// MARK: - AppEventWillResignActiveSuscriptor, AppEventDidBecomeActiveSuscriptor

extension DefaultSessionManager: AppEventWillResignActiveSuscriptor, AppEventDidBecomeActiveSuscriptor {
    
    public func applicationWillResignActive() {
        stop(timer: &refreshSessionTimer)
        stop(timer: &expireSessionTimer)
    }
    
    public func applicationDidBecomeActive() {
        let timeToExpireSession = configuration.timeToExpireSession
        guard
            let date = expireSessionTimer?.startedAt
        else {
            return
        }
        let timeLeft = timeToExpireSession - Date().timeIntervalSince(date)
        if timeLeft > 0 {
            stop(timer: &expireSessionTimer)
            expireSessionTimer = SessionTimer(timeout: timeLeft) { [weak self] in
                guard let self = self else { return }
                self.stop(timer: &self.expireSessionTimer)
                self.finishWithReason(.timeoutInactivity)
            }
            expireSessionTimer?.createTimer()

            guard
                let tokenDate = refreshSessionTimer?.startedAt,
                let timeToRefreshToken = configuration.timeToRefreshToken
            else {
                return
            }
            let tokenTimeLeft = timeToRefreshToken - Date().timeIntervalSince(tokenDate)
            if tokenTimeLeft > 0 {
                stop(timer: &refreshSessionTimer)
                refreshSessionTimer = SessionTimer(timeout: tokenTimeLeft) { [weak self] in
                    guard let self = self else { return }
                    self.stop(timer: &self.refreshSessionTimer)
                    self.refreshSession()
                }
                refreshSessionTimer?.createTimer()
            } else {
                refreshSession()
            }
        } else {
            finishWithReason(.timeoutOutOfApp)
        }
    }
}

extension DefaultSessionManager: WindowWatcherSubscriptor {
    public func windowTouched() {
        NotificationCenter.default.post(name: .windowTouched, object: self)
    }
}
 
private extension Notification.Name {
    static let windowTouched = Notification.Name("on-window-touched")
}
