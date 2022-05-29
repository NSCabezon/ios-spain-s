//
//  PersonalAreaUserNameHeader.swift
//  PersonalArea
//
//  Created by alvola on 08/11/2019.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine

protocol PersonalAreaUserNameHeaderDelegate: AnyObject {
    func cameraDidPressed()
    func userInfoDidPressed()
}

enum PersonalAreaUserNameHeaderActions {
    case camera
    case username
}

final class PersonalAreaUserNameHeader: DesignableView {
    @IBOutlet private weak var cameraImage: UIImageView?
    @IBOutlet private weak var avatarImage: UIImageView?
    @IBOutlet private weak var cameraFrame: UIView?
    @IBOutlet private weak var userNameLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var goToImage: UIImageView?
    @IBOutlet private weak var goToClickView: UIView?
    @IBOutlet private weak var separationView: UIView?
    @IBOutlet private weak var nameLabelFirstBaseline: NSLayoutConstraint!
    
    let didSelectActionSubject = PassthroughSubject<PersonalAreaUserNameHeaderActions, Never>()
    
    weak var delegate: PersonalAreaUserNameHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setUsername(_ username: String) {
        userNameLabel?.text = username.capitalized
    }
    
    func setDelegate(_ delegate: PersonalAreaUserNameHeaderDelegate) {
        self.delegate = delegate
    }
    
    func setImage(_ image: UIImage?) {
        avatarImage?.image = image
        avatarImage?.isHidden = image == nil
        cameraImage?.isHidden = image != nil
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabels()
        configureCamera()
        configureArrow()
        self.setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        backgroundColor = UIColor.skyGray
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureLabels() {
        userNameLabel?.font = UIFont.santander(family: .text, type: .bold, size: 19.0)
        userNameLabel?.text = ""

        userNameLabel?.textColor = UIColor.lisboaGray
        userNameLabel?.adjustsFontSizeToFitWidth = true
        
        descriptionLabel?.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        descriptionLabel?.text = localized("personalArea_label_allData")
        descriptionLabel?.textColor = UIColor.lisboaGray
        descriptionLabel?.numberOfLines = 2
    }
    
    private func configureCamera() {
        cameraFrame?.layer.cornerRadius = (cameraFrame?.bounds.height ?? 0.0) / 2.0
        cameraFrame?.layer.borderColor = UIColor.botonRedLight.cgColor
        cameraFrame?.layer.borderWidth = 1.4
        cameraFrame?.backgroundColor = UIColor.white
        cameraFrame?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraDidPressed)))
        cameraFrame?.isUserInteractionEnabled = true
        cameraImage?.image = Assets.image(named: "icnCamera")
        avatarImage?.layer.cornerRadius = (cameraFrame?.bounds.height ?? 0.0) / 2.0
    }
    
    private func configureArrow() {
        goToImage?.image = Assets.image(named: "icnArrowRight")
        goToClickView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToDidPressed)))
        goToClickView?.isUserInteractionEnabled = true
    }
  
    private func setAccessibilityIdentifiers() {
        self.cameraFrame?.accessibilityIdentifier = AccessibilityUserNameHeaderPersonalArea.icnPersonalAreaBtnCamera
        self.userNameLabel?.accessibilityIdentifier = AccessibilityUserNameHeaderPersonalArea.personalAreaLabelUserNameData
        self.descriptionLabel?.accessibilityIdentifier = AccessibilityUserNameHeaderPersonalArea.personalAreaLabelAllData
        self.goToImage?.accessibilityIdentifier = AccessibilityUserNameHeaderPersonalArea.icnArrowRight
    }
    
    @objc private func goToDidPressed() {
        delegate?.userInfoDidPressed()
        didSelectActionSubject.send(.username)
    }

    @objc private func cameraDidPressed() {
        delegate?.cameraDidPressed()
        didSelectActionSubject.send(.camera)
    }
}
