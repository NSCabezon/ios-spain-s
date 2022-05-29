//
//  XibButton.swift
//  UI
//
//  Created by Juan Diego Vázquez Moreno on 30/7/21.
//

import Foundation


open class XibButton: UIButton {

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let newView = self.loadFromNibIfEmbeddedInDifferentNib()
        for constraint in constraints {
            if constraint.secondItem != nil {
                newView.addConstraint(NSLayoutConstraint(item: newView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: newView, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            } else {
                newView.addConstraint(NSLayoutConstraint(item: newView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constraint.constant))
            }
        }
        return newView
    }

    private func loadFromNibIfEmbeddedInDifferentNib() -> UIButton {
        let placeholder = subviews.count == 0
        if placeholder {
            let view = viewFromNib()
            view.frame = frame
            translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
        return self
    }

    private func viewFromNib(withOwner owner: Any? = self) -> UIButton {
        let name = String(describing: type(of: self)).components(separatedBy: ".")[0]
        let view = UINib(nibName: name, bundle: .module).instantiate(withOwner: owner, options: nil)[0]
        return view as? UIButton ?? UIButton()
    }
}
