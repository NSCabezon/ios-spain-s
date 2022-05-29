import Foundation
import Operative
import CoreFoundationLib

extension BizumDonationOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }

    var extraParametersForTracker: [String: String] {
        return ["": ""]
    }
}
