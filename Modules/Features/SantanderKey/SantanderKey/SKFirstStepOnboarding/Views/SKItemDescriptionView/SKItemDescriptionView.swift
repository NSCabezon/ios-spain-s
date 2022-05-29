//
//  SKItemDescriptionView.swift
//  Alamofire
//
//  Created by Ali Ghanbari Dolatshahi on 7/2/22.
//

import UIKit
import UI
import CoreFoundationLib

public struct SkItemAccesibilityModel {
    var label: String?
    var image: String?
}

public final class SKItemDescriptionView: XibView {
    public enum IconSize: CGFloat {
        case small = 16
        case medium = 26
    }
    
    @IBOutlet private weak var itemImageview: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configView(image: UIImage?, text: String?, iconSize: IconSize = .medium, accesibilityModel: SkItemAccesibilityModel) {
        setupView(image, text, iconSize: iconSize)
        setAccessibilityIds(accesibilityModel: accesibilityModel)
    }
}

private extension SKItemDescriptionView {
    
    func setupView(_ image: UIImage?, _ text: String?, iconSize: SKItemDescriptionView.IconSize) {
        self.itemImageview.image = image
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14))
        self.itemLabel.configureText(withKey: text ?? "",
                                     andConfiguration: configuration)
        self.itemLabel.textColor = .lisboaGray
        self.iconHeightConstraint.constant = iconSize.rawValue
    }
    
    func setAccessibilityIds(accesibilityModel: SkItemAccesibilityModel) {
        self.itemLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.SkHeaderView.titleLabel
        self.itemImageview.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.SkHeaderView.imageView
    }
}
