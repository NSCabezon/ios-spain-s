//
//  PersonalManagerAction.swift
//  PersonalManager
//
//  Created by alvola on 10/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol ManagerActionDelegate: class {
    func didSelect(_ action: ManagerAction)
}

final class PersonalManagerAction: DesignableView {
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.bostonRedLight
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.isHidden = true
        addSubview(view)
        view.layer.cornerRadius = 7.0
        view.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 14.0).isActive = true
        icon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        view.topAnchor.constraint(equalTo: icon.topAnchor, constant: 0.0).isActive = true
        view.accessibilityIdentifier = "PersonalManagerViewNotificationBadge"
        return view
    }()
    
    weak var delegate: ManagerActionDelegate?
    var action: ManagerAction?
    
    public func setAction(_ action: ManagerAction, delegate: ManagerActionDelegate?) {
        self.title.text = localized(action.title())
        self.subtitle.text = localized(action.subtitle())
        self.icon.image = Assets.image(named: action.icon())
        self.action = action
        self.delegate = delegate
    }
    public func setAccesibilityId(_ identifier: String) {
        contentView?.accessibilityIdentifier = identifier
    }
    
    public func showNotificationBadge(_ show: Bool) {
        badgeView.isHidden = !show
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func setStyle(_ style: ManagerViewStyle) {
        contentView?.backgroundColor = style.actionViewBackgroundColor
        title?.textColor = style.actionViewTitleLabelColor
        subtitle?.textColor = style.actionViewSubtitleLabelColor
        if let tintColor = style.actionViewImageTintColor { icon.changeImageTintColor(tintedWith: tintColor) }
        if let borderColor = style.actionViewBorderColor {
            contentView?.layer.borderWidth = 1
            contentView?.layer.borderColor = style.actionViewBorderColor
        }
    }
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabels()
    }
    
    private func configureView() {
        contentView?.backgroundColor = UIColor.mediumSkyGray.withAlphaComponent(0.2)
        contentView?.layer.cornerRadius = 5.0
        contentView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView?.layer.shadowRadius = 2.0
        contentView?.layer.shadowOpacity = 1.0
        contentView?.layer.shadowColor = UIColor(white: 213.0 / 255.0, alpha: 1.0).cgColor
        contentView?.layer.shadowOpacity = 0.3
        contentView?.layer.masksToBounds = false
    }
    
    private func configureLabels() {
        title?.font = UIFont.santander(type: .bold, size: 16.0)
        title?.backgroundColor = UIColor.clear
        subtitle?.font = UIFont.santander(size: 12.0)
        subtitle?.backgroundColor = UIColor.clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        contentView?.layer.shadowRadius = 4.0
        contentView?.layer.shadowOpacity = 1.0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        contentView?.layer.shadowRadius = 2.0
        contentView?.layer.shadowOpacity = 0.3
        guard let action = action else { return }
        delegate?.didSelect(action)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        contentView?.layer.shadowRadius = 2.0
        contentView?.layer.shadowOpacity = 0.3
    }
}
