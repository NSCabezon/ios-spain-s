//
//  OneGradientView.swift
//  UIOneComponents
//
//  Created by José María Jiménez Pérez on 21/10/21.
//

import CoreFoundationLib

public enum OneGradientType {
    case oneSantanderGradient(direction: GradientDirection = .leftToRight)
    case oneGrayGradient(direction: GradientDirection = .topToBottom)
    case oneTurquoiseGradient(direction: GradientDirection = .topToBottom)
}

public enum GradientDirection {
    case topToBottom
    case bottomToTop
    case leftToRight
    case custom(startPoint: CGPoint, endPoint: CGPoint)
    
    public var startPoint: CGPoint {
        switch self {
        case .topToBottom: return CGPoint(x: 0.5, y: 0)
        case .bottomToTop: return CGPoint(x: 0.5, y: 1)
        case .leftToRight: return CGPoint(x: 0, y: 0.5)
        case .custom(let startPoint, _): return startPoint
        }
    }
    
    public var endPoint: CGPoint {
        switch self {
        case .topToBottom: return CGPoint(x: 0.5, y: 1)
        case .bottomToTop: return CGPoint(x: 0.5, y: 0)
        case .leftToRight: return CGPoint(x: 1, y: 0.5)
        case .custom(_, let endPoint): return endPoint
        }
    }
}

public class OneGradientView: UIView {
    
    private var gradientType: OneGradientType?
    private var backgroundLayer: CALayer?
    
    public func setupType(_ gradientType: OneGradientType) {
        self.gradientType = gradientType
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundLayer = self.backgroundLayer {
            backgroundLayer.frame = self.bounds
        } else {
            guard let gradientType = self.gradientType else { return }
            self.backgroundLayer = self.applyOneGradient(gradientType)
        }
    }
}

public extension UIView {
    func applyOneGradient(_ gradientType: OneGradientType) -> CALayer {
        switch gradientType {
        case .oneGrayGradient(let direction):
            switch direction {
            case .bottomToTop:
                return self.applyGradientBackground(colors: [.oneWhite, .oneSkyGray])
            default:
                return self.applyGradientBackground(colors: [.oneSkyGray, .oneWhite],
                                             startPoint: direction.startPoint,
                                             endPoint: direction.endPoint)
            }
        case .oneSantanderGradient(let direction):
            return self.applyGradientBackground(colors: [.oneBostonRed, .oneSantanderRed],
                                         startPoint: direction.startPoint,
                                         endPoint: direction.endPoint)
        case .oneTurquoiseGradient(let direction):
            return self.applyGradientBackground(colors: [.oneDarkTurquoise, .oneDarkEmerald],
                                         startPoint: direction.startPoint,
                                         endPoint: direction.endPoint)
        }
    }
}
