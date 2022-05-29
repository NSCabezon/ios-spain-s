//
//  CallNowViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public protocol SmallCallNowViewDelegate: AnyObject {
    func didSelectCall(_ phoneNumber: String)
}

public final class SmallCallNowView: XibView {
    public weak var delegate: SmallCallNowViewDelegate?
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var iconPhoneImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        if let title = viewModel.title {
            titleLabel.numberOfLines = 0
            titleLabel.font = .santander(family: .text, type: .light, size: 11)
            titleLabel.configureText(withLocalizedString: title)
            numberLabel.font = .santander(family: .text, type: .bold, size: 12)
            if viewModel.viewStyle == .hideNumberLabel {
                numberLabel.isHidden = true
            }
        }
        setNeedsLayout()
        setNeedsDisplay()
    }
}

private extension SmallCallNowView {
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
        view?.backgroundColor = UIColor.darkTorquoise
    }
    
    @IBAction func didTapOnCallNow() {
        guard let phoneNumber = numberLabel.text else { return }
        delegate?.didSelectCall(phoneNumber.trim())
    }
}
