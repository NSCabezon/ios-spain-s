//
//  BankerManagerActionsView.swift
//  BankerManager
//
//  Created by alvola on 10/02/2020.
//

import UIKit

final class BankerManagerActionsView: DesignableView {
    @IBOutlet weak var topStackView: UIStackView?
    @IBOutlet weak var bottomStackView: UIStackView?
    
    override func commonInit() {
        super.commonInit()
        
        topStackView?.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let top = topStackView else { return }
        top.arrangedSubviews.forEach({
            $0.widthAnchor.constraint(equalTo: top.widthAnchor, multiplier: 0.5, constant: -(top.spacing / 2.0)).isActive = true
        })
        guard let bottom = bottomStackView else { return }
        bottom.arrangedSubviews.forEach({
            $0.widthAnchor.constraint(equalTo: bottom.widthAnchor, multiplier: 0.5, constant: -(bottom.spacing / 2.0)).isActive = true
        })
    }
    
    public func setActions(_ actions: [ManagerActionViewModel], delegate: ManagerActionDelegate?, style: ManagerViewStyle) {
        actions.forEach({
            let newAction = PersonalManagerAction()
            newAction.setAction($0.action, delegate: delegate)
            newAction.setStyle(style)
            newAction.setAccesibilityId($0.accessibilityId)
            guard let stackView = addAction(newAction) else { return }
            newAction.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0).isActive = true
        })
        addFakeViews(topStackView!)
        addFakeViews(bottomStackView!)
        bottomStackView?.isHidden = bottomStackView?.arrangedSubviews.count == 0
        topStackView?.isHidden = topStackView?.arrangedSubviews.count == 0
    }
    
    public func showNotificationBadge(_ show: Bool, in viewIdentifier: String) {
        if let view = topStackView?.arrangedSubviews.first(where: {
            guard let view = $0 as? PersonalManagerAction else { return false }
            return view.contentView?.accessibilityIdentifier == viewIdentifier
        }) {
            (view as? PersonalManagerAction)?.showNotificationBadge(show)
        } else if let view = bottomStackView?.arrangedSubviews.first(where: {
            guard let view = $0 as? PersonalManagerAction else { return false }
            return view.contentView?.accessibilityIdentifier == viewIdentifier
        }) {
            (view as? PersonalManagerAction)?.showNotificationBadge(show)
        }
    }
    
    private func addFakeViews(_ stackView: UIStackView) {
        if stackView.arrangedSubviews.count == 1 {
            stackView.addArrangedSubview(UIView())
        }
    }
    
    private func addAction(_ action: PersonalManagerAction) -> UIStackView? {
        if topStackView?.arrangedSubviews.count ?? 0 < 2 {
            topStackView?.addArrangedSubview(action)
            return topStackView
        }
        bottomStackView?.addArrangedSubview(action)
        return bottomStackView
    }
}
