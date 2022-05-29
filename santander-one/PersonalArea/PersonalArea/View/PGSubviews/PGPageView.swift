//
//  PGPageView.swift
//  PersonalArea-PersonalArea
//
//  Created by David Gálvez Alonso on 25/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class PGPageView: DesignableView {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var checkView: UIImageView?
    @IBOutlet weak var shadowView: UIView?
    @IBOutlet weak var bannedLabel: UILabel?
    
    public var selected: Bool = false
    
    override func internalInit() {
        super.internalInit()
        
        commonInit()
    }
    
    private func commonInit() {
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.cornerRadius = 2.0
        imageView?.layer.borderColor = UIColor.darkTorquoise.cgColor
        imageView?.layer.borderWidth = 1.0
        
        checkView?.image = Assets.image(named: "icnCheckBluePg")
        
        bannedLabel?.backgroundColor = UIColor.darkTorquoise
        bannedLabel?.font = UIFont.santander(family: .text, type: .bold, size: 6.0)
        bannedLabel?.text = localized("generic_label_shortly")
        bannedLabel?.textColor = UIColor.white
        bannedLabel?.layer.cornerRadius = 2.0
        bannedLabel?.isHidden = true
        clipsToBounds = false
    }
    
    func selected(_ isSelected: Bool) {
        selected = isSelected

        imageView?.backgroundColor = imageView?.image != nil ? .clear : .white
        imageView?.layer.borderColor = (isSelected ? UIColor.darkTorquoise : UIColor.lightSanGray).cgColor
        imageView?.layer.borderWidth = isSelected ? 2.0: 1.0
        checkView?.isHidden = !isSelected
        shadowView?.isHidden = !isSelected
    }
    
    func banned(_ isBanned: Bool) {
        bannedLabel?.isHidden = !isBanned
    }
    
    func setInfo(_ info: PageInfo) {
        let image = Assets.image(named: info.imageName)
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = image
    }
}

extension PGPageView {
    func changeBackgroundImage(WithImageNamed name: String) {
        let image = Assets.image(named: name)
        self.imageView?.image = image
    }
}
