//
//  PersonalManagerBannerView.swift
//  PersonalManager
//
//  Created by alvola on 11/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol PersonalManagerBannerViewDelegate: class {
    func moreInfoDidPressed()
}

class PersonalManagerBannerView: DesignableView {

    @IBOutlet weak private var frameview: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var moreInfoButton: UIButton!
    @IBOutlet weak private var phoneImageView: UIImageView!
    
    public weak var delegate: PersonalManagerBannerViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        self.configureLabels()
        self.configureButton()
        self.configureView()
    }
}

private extension PersonalManagerBannerView {
    func configureView() {
        backgroundColor = UIColor.clear
        self.contentView?.backgroundColor = UIColor.clear
        self.frameview?.backgroundColor = UIColor.blueAnthracita
        self.setPhoneImageView()
    }
    
    func configureLabels() {
        self.titleLabel.font = UIFont.santander(size: 20.0)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.set(localizedStylableText: localized("manager_title_withoutMenager"))
        
        self.subtitleLabel.font = UIFont.santander(size: 12.0)
        self.subtitleLabel.textColor = UIColor.white
        self.subtitleLabel.set(localizedStylableText: localized("manager_text_ownManager"))
    }
    
    func configureButton() {
        self.moreInfoButton.setTitle(localized("manager_label_moreInfo"), for: .normal)
        self.moreInfoButton.titleLabel?.font = UIFont.santander(type: .regular, size: 14.0)
        self.moreInfoButton.setImage(Assets.image(named: "icnArrowRightPersonalArea"), for: .normal)
        self.moreInfoButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        self.moreInfoButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: -4)
        self.moreInfoButton.setTitleColor(UIColor.white, for: .normal)
        self.moreInfoButton.backgroundColor = UIColor.clear
        self.moreInfoButton.addTarget(self, action: #selector(moreInfoDidPressed), for: .touchUpInside)
    }
    
    func setPhoneImageView() {
        self.phoneImageView.contentMode = .top
        self.phoneImageView.clipsToBounds = true
        let image = Assets.image(named: "myManagerImgPhoneComplete")
        self.phoneImageView.image = image?.resizeTopAlignedToFill(newWidth: self.phoneImageView.frame.width)
    }
    
    @objc func moreInfoDidPressed() {
        self.delegate?.moreInfoDidPressed()
    }
}
