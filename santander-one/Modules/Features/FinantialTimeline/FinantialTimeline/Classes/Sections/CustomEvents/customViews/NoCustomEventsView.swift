//
//  NoCustomEventsView.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import UIKit

protocol NoCustomEventsViewDelegate: AnyObject {
    func newEventTapped()
}

class NoCustomEventsView: UIView {
    
    let icon = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let button = GlobileEndingButton()
    
    
    weak var delegate: NoCustomEventsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    func configView() {        
        configIcon()
        configTitleLabel()
        configMessageLabel()
        configButton()
    }
    
    func configIcon() {
        icon.image = UIImage(fromModuleWithName: "icPersonalEvent")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray

        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }

    func configTitleLabel() {
        titleLabel.font = .santanderHeadline(type: .bold, with: 20)
        titleLabel.textColor = .brownishGrey
        titleLabel.textAlignment = .center
        titleLabel.text = IBLocalizedString(CustomEventsString().noEventsTitle)

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 7).isActive = true
    }

    func configMessageLabel() {
        messageLabel.font = .santanderText(type: .light, with: 14)
        messageLabel.textColor = .brownishGrey
        messageLabel.textAlignment = .center
        messageLabel.text = IBLocalizedString(CustomEventsString().noEventsMessage)

        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 17).isActive = true
    }
    
    func configButton() {
        button.isEnabled = true
        button.setTitle(CustomEventsString().noEventsCreateNewButton, for: .normal)
        button.setImage(UIImage(fromModuleWithName: "icCalendar")?.withRenderingMode(.alwaysTemplate), position: .left, withPadding: 10)
        button.isUserInteractionEnabled = true
        button.onClick(createNewEvent)

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 90).isActive = true
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc func createNewEvent() {
        delegate?.newEventTapped()
    }
    
}
