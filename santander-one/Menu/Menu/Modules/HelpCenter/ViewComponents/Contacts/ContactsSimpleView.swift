//
//  ContactsSimpleView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 03/03/2020.
//

import UI
import CoreFoundationLib

protocol ContactsSimpleViewProtocol: AnyObject {
    func didTapSimpleView(action: ContactsSimpleViewModelAction)
}

class ContactsSimpleView: XibView {
    @IBOutlet private weak var contactView: UIView!
    @IBOutlet private weak var imageViewIcon: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    private var viewModel: ContactsSimpleViewModel?
    var phoneNumber: String?
    weak var delegate: ContactsSimpleViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        self.contactView.drawRoundedAndShadowedNew()
        self.labelTitle.font = .santander(family: .text, type: .regular, size: 20.0)
        self.labelTitle.textColor = .lisboaGray
        self.labelTitle.numberOfLines = 0
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.numberOfLines = 0
    }
    
    public func setModel(viewModel: ContactsSimpleViewModel) {
        if let title = viewModel.title {
            self.labelTitle.configureText(withLocalizedString: title)
        }
        
        if let subtitle = viewModel.subtitle {
            self.descriptionLabel.configureText(withLocalizedString: subtitle)
        }
        
        self.imageViewIcon.image = Assets.image(named: viewModel.icon)
        self.viewModel = viewModel
        self.setAccessibilityIdentifiers()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let action = viewModel?.action else { return }
        self.delegate?.didTapSimpleView(action: action)
    }
    
    private func setAccessibilityIdentifiers() {
        if let action = viewModel?.action {
            self.accessibilityIdentifier = "helpCenter_contactView_view_\(action)"
            self.labelTitle.accessibilityIdentifier = "helpCenter_contactView_title_\(action)"
            self.descriptionLabel.accessibilityIdentifier = "helpCenter_contactView_desc_\(action)"
            self.imageViewIcon.isAccessibilityElement = true
            self.setAccessibility { self.imageViewIcon.isAccessibilityElement = false }
            self.imageViewIcon.accessibilityIdentifier = "helpCenter_contactView_image_\(action)"
        }
    }
}

extension ContactsSimpleView: AccessibilityCapable { }
