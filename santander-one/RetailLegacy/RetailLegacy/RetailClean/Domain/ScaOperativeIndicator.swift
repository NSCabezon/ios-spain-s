import Foundation
import SANLegacyLibrary

public enum ScaOperativeIndicator {
    case login
    case accounts
    
    public var dto: ScaOperativeIndicatorDTO {
        switch self {
        case .login:
            return .login
        case .accounts:
            return .accounts
        }
    }
}
