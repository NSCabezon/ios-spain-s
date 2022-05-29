//
//  ReportCard.swift
//  PersonalArea
//
//  Created by alvola on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ReportCard: DesignableView {

    @IBOutlet weak var frameView: UIView?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var cornerImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var dotView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.layoutSubviews()
        frameView?.layoutSubviews()
        titleLabel?.refreshFont(force: true)
        titleLabel?.configureText(withKey: "yourTrips_button_theftOrLoss",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .light, size: 20.0),
                                                                                       lineHeightMultiple: 0.85))
        titleLabel?.numberOfLines = 0
        titleLabel?.sizeToFit()
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureImages()
        configureLabels()
        configureDot()
    }
    
    private func configureView() {
        backgroundColor = .clear
        contentView?.backgroundColor = UIColor.clear
        frameView?.layer.cornerRadius = 4.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        frameView?.layer.borderWidth = 1.0
        frameView?.drawShadow(offset: (1, 2), color: UIColor(white: 213.0 / 255.0, alpha: 0.3))
    }
    
    private func configureImages() {
        cornerImageView?.image = Assets.image(named: "icnCornerPhone")
        iconImageView?.image = Assets.image(named: "icnBlockCard")
        iconImageView?.contentMode = .scaleAspectFill
    }
    
    private func configureLabels() {
        titleLabel?.textColor = UIColor.lisboaGray
        titleLabel?.minimumScaleFactor = 0.6
        subtitleLabel?.textColor = UIColor.lisboaGray
        subtitleLabel?.configureText(withKey: "generic_label_24h",
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .light, size: 14.0)))
        subtitleLabel?.numberOfLines = 1
        subtitleLabel?.adjustsFontSizeToFitWidth = true
        subtitleLabel?.minimumScaleFactor = 0.5
    }
    
    private func configureDot() {
        dotView?.backgroundColor = UIColor.limeGreen
        dotView?.layer.cornerRadius = (dotView?.bounds.height ?? 0.0) / 2.0
    }
}
