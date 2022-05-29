//
//  ManagerActionView.swift
//  PersonalManager
//
//  Created by alvola on 11/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

final class ManagerActionView: DesignableView {
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    private let maxLenghtAllowed = 9
    
    public func setTitle(_ title: String, icon: String) {
        self.title.text = localized(title)
        self.icon.image = Assets.image(named: icon)
    }
    
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
        setTitle(action)
        self.icon?.image = Assets.image(named: action.icon())
        self.action = action
        self.delegate = delegate
    }
    
    public func setAccesibilityId(_ identifier: String) {
        contentView?.accessibilityIdentifier = identifier
    }
    
    public func showNotificationBadge(_ show: Bool) {
        badgeView.isHidden = !show
    }
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabel()
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

private extension ManagerActionView {
    func configureView() {
        contentView?.backgroundColor = UIColor.white
        contentView?.layer.cornerRadius = 5.0
        contentView?.layer.borderWidth = 1.0
        contentView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView?.layer.shadowRadius = 2.0
        contentView?.layer.shadowOpacity = 1.0
        contentView?.layer.shadowColor = UIColor(white: 213.0 / 255.0, alpha: 1.0).cgColor
        contentView?.layer.shadowOpacity = 0.3
        contentView?.layer.masksToBounds = false
    }
    
     func configureLabel() {
        title.font = UIFont.santander(size: 13.0)
        title.textColor = UIColor.mediumSanGray
        title.backgroundColor = UIColor.clear
        title.numberOfLines = 2
    }
    
    private func setTitle(_ action: ManagerAction) {
        if localized(action.title()).count > maxLenghtAllowed {
            self.title.text = localized(action.alternativeTitle())
        } else {
            self.title.text = localized(action.title())
        }
        self.title.set(lineHeightMultiple: 0.65)
    }
}
