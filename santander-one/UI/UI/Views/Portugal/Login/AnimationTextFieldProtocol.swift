//
//  AnimationTextFieldProtocol.swift
//  UI
//
//  Created by David Gálvez Alonso on 28/12/2020.
//

import Foundation

public protocol AnimationTextFieldProtocol: AnyObject {
    var titleLabel: UILabel! { get set }
    var textField: ConfigurableActionsTextField! { get set }
    var centerConstraint: NSLayoutConstraint! { get set }
    var bottomConstraint: NSLayoutConstraint! { get set }
}

public extension AnimationTextFieldProtocol {
    func changeFieldVisibility(isFieldVisible: Bool, animated: Bool) {
        let titleLabelFont = UIFont.santander(family: .text, type: .regular, size: 20)
        let visibleTitleLabelFont = UIFont.santander(family: .text, type: .regular, size: 12)
        self.titleLabel.font = isFieldVisible ? visibleTitleLabelFont : titleLabelFont
        self.bottomConstraint.isActive = isFieldVisible
        self.centerConstraint.isActive = !isFieldVisible
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.titleLabel.superview?.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.titleLabel.superview?.layoutIfNeeded()
        }
    }
}
