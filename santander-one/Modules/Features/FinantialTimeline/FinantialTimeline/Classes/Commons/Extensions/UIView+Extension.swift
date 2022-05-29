//
//  UIView+.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 16/07/2019.
//

import UIKit

struct AutoLayoutConstant {
    
    fileprivate let constant: CGFloat
    fileprivate let relation: NSLayoutConstraint.Relation
    fileprivate let priority: UILayoutPriority
    
    static func equal(to constant: CGFloat, priority: UILayoutPriority = .required) -> AutoLayoutConstant {
        return AutoLayoutConstant(constant: constant, relation: .equal, priority: priority)
    }
    
    static func greaterThanOrEqual(to constant: CGFloat, priority: UILayoutPriority = .required) -> AutoLayoutConstant {
        return AutoLayoutConstant(constant: constant, relation: .greaterThanOrEqual, priority: priority)
    }
    
    static func lessThanOrEqual(to constant: CGFloat, priority: UILayoutPriority = .required) -> AutoLayoutConstant {
        return AutoLayoutConstant(constant: constant, relation: .lessThanOrEqual, priority: priority)
    }
}

extension UIView {
    
    func addSubviewWithAutoLayout(_ view: UIView, topAnchorConstant: AutoLayoutConstant = .equal(to: 0), bottomAnchorConstant: AutoLayoutConstant = .equal(to: 0), leftAnchorConstant: AutoLayoutConstant = .equal(to: 0), rightAnchorConstant: AutoLayoutConstant = .equal(to: 0)) {
        view.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let topConstraint = constraint(view.topAnchor, to: topAnchor, anchorConstant: topAnchorConstant)
        let bottomConstraint = constraint(view.bottomAnchor, to: bottomAnchor, anchorConstant: bottomAnchorConstant)
        let leftConstraint = constraint(view.leftAnchor, to: leftAnchor, anchorConstant: leftAnchorConstant)
        let rightConstraint = constraint(view.rightAnchor, to: rightAnchor, anchorConstant: rightAnchorConstant)
        topConstraint.priority = topAnchorConstant.priority
        bottomConstraint.priority = bottomAnchorConstant.priority
        leftConstraint.priority = leftAnchorConstant.priority
        rightConstraint.priority = rightAnchorConstant.priority
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        leftConstraint.isActive = true
        rightConstraint.isActive = true
    }
    
    private func constraint<AnchorType>(_ anchor: NSLayoutAnchor<AnchorType>, to destinationAnchor: NSLayoutAnchor<AnchorType>, anchorConstant: AutoLayoutConstant) -> NSLayoutConstraint {
        switch anchorConstant.relation {
        case .equal:
            return anchor.constraint(equalTo: destinationAnchor, constant: anchorConstant.constant)
        case .greaterThanOrEqual:
            return anchor.constraint(greaterThanOrEqualTo: destinationAnchor, constant: anchorConstant.constant)
        case .lessThanOrEqual:
            return anchor.constraint(lessThanOrEqualTo: destinationAnchor, constant: anchorConstant.constant)
        @unknown default:
            return anchor.constraint(equalTo: destinationAnchor, constant: anchorConstant.constant)
        }
    }
    
    func anchor(left: NSLayoutXAxisAnchor? = nil, top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, width: CGFloat? = nil, height: CGFloat? = nil, padding: UIEdgeInsets? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: padding?.left ?? 0).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding?.top ?? 0).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: padding?.right ?? 0).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: padding?.bottom ?? 0).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
