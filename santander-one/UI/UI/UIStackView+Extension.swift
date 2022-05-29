//
//  UIStackView+Extension.swift
//  Pods
//
//  Created by Boris Chirino Fernandez on 19/05/2020.
//

import UIKit

public extension UIStackView {
    func setBackgroundColor(color: UIColor, rounded: Bool) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if rounded {
          subview.drawBorder(cornerRadius: 4.0, color: color, width: 2.0)
        }
        insertSubview(subview, at: 0)
    }
    
    @discardableResult
       func removeAllArrangedSubviews() -> [UIView] {
           return arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
       }

        func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
           removeArrangedSubview(view)
           NSLayoutConstraint.deactivate(view.constraints)
           view.removeFromSuperview()
           return view
       }
    
    func roundedWithColor(_ color: UIColor, radius: CGFloat, width: CGFloat = 1.0) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = .clear
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subview.drawBorder(cornerRadius: radius, color: color, width: width)
        insertSubview(subview, at: 0)
    }
    
    func roundedWithShadowConfiguration(_ configuration: ShadowConfiguration, radius: CGFloat, width: CGFloat = 1.0, borderColor: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = .white
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subview.drawRoundedBorderAndShadow(with: configuration,
                                                            cornerRadius: radius,
                                                            borderColor: borderColor,
                                                            borderWith: width)
        insertSubview(subview, at: 0)
    }
}
