//
//  DigitalProfileHeader.swift
//  PersonalArea
//
//  Created by alvola on 05/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

enum AccessibilityDigitalProfileHeader {
    static let userNameLabel = "digitalProfile_user_name"
    static let cadetLabel = "digitalProfile_label_cadet"
    static let completedPercentageLabel = "generic_label_percentage"
    static let digitalprofileImage = "personalAreaBtnUser"
    static let digitalProfileMedalImage = "digitalProfileMedalImage"
    static let digitalprofileInitials = "digitalProfile_progress_initials_label"
    static let digitalprofileProggressCircle = "digitalProfile_progress_circle"
}

class DigitalProfileHeader: DesignableView {
    @IBOutlet weak var userImage: UIImageView?
    @IBOutlet weak var userImageBg: UIView?
    @IBOutlet weak var noNameLabel: UILabel?
    @IBOutlet weak var medalImage: UIImageView?
    @IBOutlet weak var usernameLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var progressLabel: UILabel?
    @IBOutlet weak var separationView: UIView?
    private var circleLayer: CAShapeLayer?
    private var circleShadowLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setInfo(_ info: DigitalProfileModelWithUser) {
        medalImage?.image = Assets.image(named: info.digitalProfile.medal())
        usernameLabel?.text = info.username.capitalized + " " + info.userLastname.capitalized
        noNameLabel?.text = (info.username).prefix(1).uppercased() + (info.userLastname).prefix(1).uppercased()
        statusLabel?.configureText(withKey: info.digitalProfile.name(),
                                   andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16.0)))
        progressLabel?.text = String(Int(info.percentage)) + "%"
        if let data = info.userImage {
            userImage?.image = UIImage(data: data)
        }
        noNameLabel?.isHidden = info.userImage != nil
        drawCircleShadow(info.percentage)
    }

    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabels()
        configureUserImage()
        setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        contentView?.backgroundColor = UIColor.skyGray
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureLabels() {
        noNameLabel?.font = UIFont.santander(family: .headline, type: .regular, size: 29.0)
        noNameLabel?.textColor = UIColor.santanderRed
        noNameLabel?.isHidden = true
        usernameLabel?.font = UIFont.santander(family: .text, type: .bold, size: 19.0)
        usernameLabel?.textColor = UIColor.lisboaGray
        statusLabel?.textColor = UIColor.lisboaGray
        progressLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        progressLabel?.textColor = UIColor.darkTorquoise
    }
    
    private func configureUserImage() {
        userImage?.layer.cornerRadius = (userImage?.bounds.height ?? 0.0) / 2.0
        userImage?.layer.borderColor = UIColor.white.cgColor
        userImage?.layer.borderWidth = 3.5
        userImage?.backgroundColor = UIColor.paleSanGray
        userImage?.clipsToBounds = true
    }
    
    private func drawCircleShadow(_ percentage: Double) {
        guard let userImage = userImageBg else { return }
        self.circleLayer?.removeFromSuperlayer()
        let start: CGFloat = 3.0 * .pi / 2.0
        let end = start + (CGFloat(percentage) * 2.0 * .pi / 100.0)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: userImage.frame.size.width / 2.0, y: userImage.frame.size.height / 2.0),
                                      radius: (userImage.frame.size.width + 7) / 2.0,
                                      startAngle: start,
                                      endAngle: end,
                                      clockwise: true)
        
        let circleLayer = CAShapeLayer()
        let animate = self.circleLayer == nil
        self.circleLayer = circleLayer
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.darkTorquoise.cgColor
        circleLayer.lineWidth = 3.5
        circleLayer.strokeEnd = animate ? 0.0 : 1.0
        addCircleShadow()
        userImage.layer.addSublayer(circleLayer)
        animateCircle()
    }
    
    private func addCircleShadow() {
        guard let userImage = userImageBg else { return }
        self.circleShadowLayer?.removeFromSuperlayer()
        let circleShadowLayer = CAShapeLayer()
        self.circleShadowLayer = circleShadowLayer
        circleShadowLayer.path = UIBezierPath(arcCenter: CGPoint(x: userImage.frame.size.width / 2.0, y: userImage.frame.size.height / 2.0),
                                              radius: (userImage.frame.size.width + 7) / 2.0,
                                              startAngle: 0.0,
                                              endAngle: 2 * .pi,
                                              clockwise: true).cgPath
        circleShadowLayer.fillColor = UIColor.clear.cgColor
        circleShadowLayer.strokeColor = UIColor.lightSanGray.cgColor
        circleShadowLayer.lineWidth = 3.5
        circleShadowLayer.strokeEnd = 1.0
        userImage.layer.addSublayer(circleShadowLayer)
    }
    
    private func animateCircle() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        self.circleLayer?.strokeEnd = 1.0
        self.circleLayer?.add(animation, forKey: "animateCircle")
    }
    
    private func setAccessibilityIdentifiers() {
        usernameLabel?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.userNameLabel
        noNameLabel?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.digitalprofileInitials
        statusLabel?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.cadetLabel
        progressLabel?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.completedPercentageLabel
        userImage?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.digitalprofileImage
        medalImage?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.digitalProfileMedalImage
        userImageBg?.accessibilityIdentifier = AccessibilityDigitalProfileHeader.digitalprofileProggressCircle
    }
}
