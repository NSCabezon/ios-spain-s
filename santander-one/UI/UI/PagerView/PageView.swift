//
//  PageView.swift
//  toTest
//
//  Created by alvola on 01/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

final class PageView: UIView {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var checkView: UIImageView?
    @IBOutlet weak var shadowView: UIView?
    @IBOutlet weak var bannedLabel: UILabel?
    
    public var selected: Bool = false
    
    override func awakeFromNib() { super.awakeFromNib(); commonInit() }
    
    private func commonInit() {
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.cornerRadius = 2.0
        imageView?.layer.borderColor = UIColor.turquoise.cgColor
        imageView?.layer.borderWidth = 1.0
        
        checkView?.image = Assets.image(named: "icnCheckBluePg")
        
        bannedLabel?.backgroundColor = UIColor.turquoise
        bannedLabel?.font = UIFont.santander(family: .text, type: .bold, size: 10.0)
        bannedLabel?.text = localized("generic_label_shortly")
        bannedLabel?.textColor = UIColor.white
        bannedLabel?.layer.cornerRadius = 2.0
        bannedLabel?.isHidden = true
        clipsToBounds = false
    }
    
    func selected(_ isSelected: Bool) {
        selected = isSelected
        checkView?.image = Assets.image(named: isSelected ? "icnCheckBluePg" : "")
        imageView?.backgroundColor = imageView?.image != nil ? .clear: .white
        imageView?.layer.borderColor = (isSelected ? UIColor.darkTorquoise : UIColor.lightGray).cgColor
        imageView?.layer.borderWidth = isSelected ? 2.0: 1.0
        shadowView?.isHidden = !isSelected
    }
    
    func banned(_ isBanned: Bool) {
        bannedLabel?.isHidden = !isBanned
    }
    
    func setInfo(_ info: PageInfo) {
        imageView?.image = Assets.image(named: info.imageName)
        imageView?.frame = CGRect(x: 0,
                                  y: 0,
                                  width: imageView?.image?.size.width ?? 0.0,
                                  height: imageView?.image?.size.height ?? 0.0)
    }
}

extension PageView {
    func changeBackgroundImage(WithImageNamed name: String) {
        self.imageView?.image = Assets.image(named: name)
    }
}
