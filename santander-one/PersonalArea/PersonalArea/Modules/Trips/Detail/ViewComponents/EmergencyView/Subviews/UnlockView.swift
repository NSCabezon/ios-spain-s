//
//  UnlockView.swift
//  PersonalArea
//
//  Created by alvola on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class UnlockView: DesignableView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private var title: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setTitle(_ title: String, image: String) {
        self.title = title
        titleLabel.configureText(withKey: title)
        iconImageView.image = Assets.image(named: image)
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabel()
    }
    
    private func configureView() {
        contentView?.backgroundColor = UIColor.white
        contentView?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSky, widthOffSet: 1, heightOffSet: 2)
        iconImageView?.contentMode = .scaleAspectFill
    }
    
    private func configureLabel() {
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(type: .light, size: 16.0)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }
}
