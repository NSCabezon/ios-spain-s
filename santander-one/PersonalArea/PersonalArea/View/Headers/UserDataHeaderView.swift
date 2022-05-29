//
//  UserDataHeaderView.swift
//  PersonalArea
//
//  Created by alvola on 15/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol UserDataHeaderDelegate: AnyObject {
    func cameraDidPressed()
}

final class UserDataHeaderView: DesignableView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var cameraImage: UIImageView?
    @IBOutlet weak var separationView: UIView?
    
    weak var delegate: UserDataHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            cameraImage?.isHidden = true
            titleLabel?.text = localized("personalData_label_changePhoto")
            userImageView?.image = image
        }
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabel()
        configureImages()
        self.setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        contentView?.backgroundColor = UIColor.skyGray
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureLabel() {
        titleLabel?.font = UIFont.santander(family: .text, size: 14.0)
        titleLabel?.textColor = UIColor.darkTorquoise
        titleLabel?.text = localized("personalData_label_addPhoto")
        titleLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraDidPressed)))
        titleLabel?.isUserInteractionEnabled = true
    }
    
    private func configureImages() {
        cameraImage?.image = Assets.image(named: "icnCamera")
        
        userImageView?.backgroundColor = UIColor.white
        userImageView?.layer.cornerRadius = (userImageView?.bounds.height ?? 0.0) / 2.0
        userImageView?.layer.borderColor = UIColor.botonRedLight.cgColor
        userImageView?.layer.borderWidth = 1.0
        userImageView?.clipsToBounds = true
        userImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraDidPressed)))
        userImageView?.isUserInteractionEnabled = true
    }
    
    private func setAccessibilityIdentifiers() {
        titleLabel?.accessibilityIdentifier = AccessibilityBasicInfoPersonalArea.btnPersonalAreaAddPhoto
        userImageView?.accessibilityIdentifier = AccessibilityBasicInfoPersonalArea.btnPersonalAreaIcnCamera
        cameraImage?.accessibilityIdentifier = AccessibilityBasicInfoPersonalArea.icnCameraPersonalArea
    }
    
    @objc func cameraDidPressed() { delegate?.cameraDidPressed() }
}
