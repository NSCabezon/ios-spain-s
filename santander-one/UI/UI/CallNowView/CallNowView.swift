//
//  CallNowViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public protocol CallNowViewDelegate: AnyObject {
    func didSelectCall(_ phoneNumber: String)
}

public final class CallNowView: XibView {
    public weak var delegate: CallNowViewDelegate?
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var iconPhoneImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        view?.layoutSubviews()
        view?.subviews.forEach({ $0.layoutSubviews() })
    }
    
    public func setViewModel(_ viewModel: PhoneViewModel) {
        numberLabel.text = viewModel.phone
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public func setViewModelWithoutNumberLabel(_ viewModel: PhoneViewModel) {
        numberLabel.text = viewModel.phone
        if let title = viewModel.title, let titleLabel = titleLabel {
            titleLabel.numberOfLines = 0
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: titleLabel,
                                                     attribute: NSLayoutConstraint.Attribute.width,
                                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                                     toItem: nil,
                                                     attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                     multiplier: 1,
                                                     constant: UIScreen.main.bounds.width / 3)
            titleLabel.superview?.addConstraints([widthConstraint])
            titleLabel.font = .santander(family: .text, type: .light, size: 16)
            titleLabel.configureText(withLocalizedString: title)
            numberLabel.isHidden = true
        }
        setNeedsLayout()
        setNeedsDisplay()
    }
}

private extension CallNowView {
    func setAppearance() {
        view?.drawRoundedAndShadowedNew(radius: 4,
                                        borderColor: .mediumSky,
                                        widthOffSet: 1,
                                        heightOffSet: 2)
        titleLabel.textColor = .white
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        titleLabel.text = localized("general_button_callNow")
        iconPhoneImage.image = Assets.image(named: "icnPhoneWhite")
        numberLabel.textColor = .white
        numberLabel.font = .santander(family: .text, type: .bold, size: 20.0)
        view?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(didTapOnCallNow)))
    }
    
    @objc func didTapOnCallNow() {
        guard let phoneNumber = numberLabel.text else { return }
        delegate?.didSelectCall(phoneNumber.trim())
    }
}
