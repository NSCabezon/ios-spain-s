import Foundation

public enum SingleSignOnToApp {
    case moneyPlan
    case broker
    case videoCall

    public func getUrl(params: String?) -> String? {
        let baseUrl: String
        switch self {
        case .moneyPlan:
            baseUrl = "IMM"
        case .broker:
            baseUrl = "santanderbroker"
        case .videoCall:
            baseUrl = "santandervideollamada"
        }
        
        let url = "\(baseUrl)://sharingtoken"
        if let params = params {
            let completeUrl = "\(url)?\(params)"
            return completeUrl
        } else {
            return url
        }
    }
    
    public var storeId: Int {
        switch self {
        case .moneyPlan:
            return 1_130_926_932
        case .broker:
            return 1183758437
        case .videoCall:
            return 1435792108
        }
    }
}
