//
//  UIViewExtensions.swift
//  UIOneComponents
//
//  Created by Adrian Arcalá Ocón on 13/8/21.
//

import Foundation

public enum OneCornerRadiusType {
    case oneShRadius4
    case oneShRadius8
    case oneShRadiusCircle
}

public enum OneSpacingType {
    case none
    case oneSizeSpacing4
    case oneSizeSpacing8
    case oneSizeSpacing12
    case oneSizeSpacing16
    case oneSizeSpacing20
    case oneSizeSpacing24
    case oneSizeSpacing32
    case oneSizeSpacing40
    case oneSizeSpacing48
    case oneSizeSpacing64
    case oneSizeSpacing96
    case oneSizeSpacing128

    private var values: [OneSpacingType: CGFloat] {
        return [
            .none: 0,
            .oneSizeSpacing4: 4,
            .oneSizeSpacing8: 8,
            .oneSizeSpacing12: 12,
            .oneSizeSpacing16: 16,
            .oneSizeSpacing20: 20,
            .oneSizeSpacing24: 24,
            .oneSizeSpacing32: 32,
            .oneSizeSpacing40: 40,
            .oneSizeSpacing48: 48,
            .oneSizeSpacing64: 64,
            .oneSizeSpacing96: 96,
            .oneSizeSpacing128: 128
        ]
    }

    public var value: CGFloat {
        return values[self] ?? 0.0
    }
}

public enum OneShadowsType {
    case none
    case oneShadowSmall
    case oneShadowMedium
    case oneShadowLargeTop
    case oneShadowLargeBottom
    case oneShadowLarge
}

extension UIView {
    public func setOneCornerRadius(type: OneCornerRadiusType) {
        let view = self
        switch type {
            case .oneShRadius4: view.layer.cornerRadius = 4
            case .oneShRadius8: view.layer.cornerRadius = 8
            case .oneShRadiusCircle: view.layer.cornerRadius = view.frame.height/2
        }
    }
    
    public func oneSpacing(type: OneSpacingType) -> CGFloat {
        return type.value
    }

    public func setOneShadows(type: OneShadowsType) {
        switch type {
        case .none: setShadows(offset: (x: 0, y: 0), blur: 0.0, alpha: 0.0, color: .clear)
        case .oneShadowSmall: setShadows(offset: (x: 0, y: 2), blur: 4, alpha: 0.5, color: .oneLightSanGray)
        case .oneShadowMedium: setShadows(offset: (x: 0, y: 4), blur: 6, alpha: 0.15, color: .oneLightSanGray)
        case .oneShadowLargeTop: setShadows(offset: (x: 0, y: -3), blur: 2, alpha: 0.5, color: .oneBrownishGray)
        case .oneShadowLargeBottom: setShadows(offset: (x: 0, y: 3), blur: 2, alpha: 0.5, color: .oneBrownishGray)
        case .oneShadowLarge: setShadows(offset: (x: 1, y: 2), blur: 8, alpha: 0.35, color: .oneLisboaGray)
        }
    }
    
    public func addSubview(_ view: UIView, topMargin: OneSpacingType = .none, bottomMargin: OneSpacingType = .none, leftMargin: OneSpacingType = .none, rightMargin: OneSpacingType = .none) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: oneSpacing(type: topMargin)),
            view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -oneSpacing(type: rightMargin)),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: oneSpacing(type: topMargin)),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -oneSpacing(type: bottomMargin))
        ])
    }
    
    private func setShadows(offset: (x: Int, y: Int), blur: CGFloat, alpha: Float, color: UIColor) {
        let view = self
        view.layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        view.layer.shadowRadius = blur / 2
        view.layer.shadowOpacity = alpha
        view.layer.shadowColor = color.cgColor
    }
    
    public func addLayer(path: CGMutablePath, color: UIColor, width: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.lineWidth = width
        borderLayer.strokeColor = color.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(borderLayer)
    }
}
