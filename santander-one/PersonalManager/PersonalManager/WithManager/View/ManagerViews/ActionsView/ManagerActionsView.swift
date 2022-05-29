//
//  ManagerActionsView.swift
//  PersonalManager
//
//  Created by alvola on 11/02/2020.
//

import UIKit

final class ManagerActionsView: DesignableView {
    
    @IBOutlet weak var stackView: UIStackView?
    
    override func commonInit() {
        super.commonInit()
        
        stackView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func setActions(_ actions: [ManagerActionViewModel], delegate: ManagerActionDelegate?) {
        guard let stackView = stackView else { return }
        actions.forEach({
            let newAction = ManagerActionView()
            newAction.setAction($0.action, delegate: delegate)
            newAction.setAccesibilityId($0.accessibilityId)
            stackView.addArrangedSubview(newAction)
            newAction.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0).isActive = true
        })
        stackView.isHidden = stackView.arrangedSubviews.count == 0
    }
    
    public func showNotificationBadge(_ show: Bool, in viewIdentifier: String) {
        if let view = stackView?.arrangedSubviews.first(where: {
            guard let view = $0 as? ManagerActionView else { return false }
            return view.contentView?.accessibilityIdentifier == viewIdentifier}) {
            (view as? ManagerActionView)?.showNotificationBadge(show)
        }
    }
}
