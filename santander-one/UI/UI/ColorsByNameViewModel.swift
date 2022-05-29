import CoreFoundationLib

public extension ColorsByNameViewModel {
    var color: UIColor {
        switch self.type {
        case .first: return .santanderYellow
        case .second: return .limeGreen
        case .third: return .lisboaPurple
        case .quarter: return .turquoise
        case .fifth: return .darkSky
        case .sixth: return .rubyRed
        case .seventh: return .lightBrown
        case .eighth: return .darkPurple
        case .ninth: return .darkTorquoise
        }
    }
}
