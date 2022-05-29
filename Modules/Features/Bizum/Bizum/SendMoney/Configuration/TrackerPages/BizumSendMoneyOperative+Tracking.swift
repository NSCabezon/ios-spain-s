import Operative
import CoreFoundationLib

extension BizumSendMoneyOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }

    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension BizumSendMoneyOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return BizumSendMoneySignaturePage().page
    }
}

extension BizumSendMoneyOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        return BizumSendMoneyOTPPage().page
    }
}

extension BizumSendMoneyOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}
