//
//  LoginSessionHandlerCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import CoreFoundationLib

protocol LoginSessionHandlerCapable {
    var scaOpt: HandleScaOtpCapable { get }
    var scaBloqued: HandleScaBloquedCapable { get }
    var metricsTracker: TrackMetricsLocationCapable { get }
    var loadSessionDataHandler: HandleLoadSessionDataSuccessCapable { get }
    var loadingMessage: UpdateLoadingMessageCapable { get }
    func handleLoadSessionError(error: LoadSessionError)
    func handleUserCanceled()
    func onSuccess()
    func onScaBloqued()
    func onScaOtp(firstTime: Bool, userName: String)
}

extension LoginSessionHandlerCapable where Self: TrackMetricsLocationCapable {
    var metricsTracker: TrackMetricsLocationCapable {
        return self
    }
}

extension LoginSessionHandlerCapable where Self: HandleLoadSessionDataSuccessCapable {
    var loadSessionDataHandler: HandleLoadSessionDataSuccessCapable {
        return self
    }
}

extension LoginSessionHandlerCapable where Self: UpdateLoadingMessageCapable {
    var loadingMessage: UpdateLoadingMessageCapable {
        return self
    }
}

extension LoginSessionHandlerCapable where Self: HandleScaBloquedCapable {
    var scaBloqued: HandleScaBloquedCapable {
        return self
    }
}

extension LoginSessionHandlerCapable where Self: HandleScaOtpCapable {
    var scaOpt: HandleScaOtpCapable {
        return self
    }
}

extension LoginSessionHandlerCapable {
    func handle(event: SessionManagerProcessEvent) {
        switch event {
        case .fail(let error):
            self.handleLoadSessionError(error: error)
        case .loadDataSuccess:
            onSuccess()
        case .updateLoadingMessage(let isPb, let name):
            self.loadingMessage.updateLoadingMessage(isPb: isPb, name: name)
        case .cancelByUser:
            self.handleUserCanceled()
        }
    }

    func onSuccess() {
        self.metricsTracker.trackMetricsLocation()
        self.loadSessionDataHandler.handleLoadSessionDataSuccess()
    }

    func onScaBloqued() {
        self.scaBloqued.handleScaBloqued()
    }

    func onScaOtp(firstTime: Bool, userName: String) {
        self.scaOpt.handleScaOtp(username: userName, isFirstTime: firstTime)
    }
}
