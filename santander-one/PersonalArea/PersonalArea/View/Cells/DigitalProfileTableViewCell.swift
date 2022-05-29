//
//  DigitalProfileTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class DigitalProfileTableViewCell: UITableViewCell {
    @IBOutlet private weak var frameView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var medalImage: UIImageView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separationView: UIView!
    @IBOutlet private weak var descriptionLabelHeight: NSLayoutConstraint!
    
    private var percentage: Float = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetView()
    }
}

extension DigitalProfileTableViewCell: GeneralPersonalAreaCellProtocol {
    func setCellInfo(_ info: Any?) {
        guard let info = info as? DigitalProfileModel else { return }
        self.setDescriptionLabel(info.percentage)
        self.medalImage.image = Assets.image(named: info.type.medal())
        self.progressLabel.text = String(Int(info.percentage)) + "%"
        self.progressView.progressTintColor = .darkTorquoise
        self.progressView.trackTintColor = .lightSanGray
        self.progressView.setContentHuggingPriority(.required, for: .horizontal)
        self.percentage = Float(info.percentage) / 100
        self.setAccessibilityIdentifiers(info)
    }
    
    func setAccessibilityIdentifiers(_ info: DigitalProfileModel) {
        self.titleLabel.accessibilityIdentifier = info.titleAccessibilityIdentifier
        self.progressView.accessibilityIdentifier = info.progressBarAccessibilityIdentifier
        self.progressLabel.accessibilityIdentifier = info.progressPercentageAccessibilityIdentifier
        self.descriptionLabel.accessibilityIdentifier = info.descriptionAccessibilityIdentifier
        self.medalImage.accessibilityIdentifier = info.badgeIconAccessibilityIdentifier
    }
}

extension DigitalProfileTableViewCell: WillDisplayCellActionble {
    func willDisplay() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn) {
            self.progressView.setProgress(self.percentage, animated: true)
        }
    }
}

private extension DigitalProfileTableViewCell {
    func commonInit() {
        self.resetView()
        self.configureView()
        self.configureLabels()
    }
    
    func configureView() {
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.frameView.layer.cornerRadius = 6.0
        self.frameView.layer.borderWidth = 1.0
        self.frameView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.frameView.backgroundColor = UIColor.white
        self.frameView.layer.masksToBounds = false
        self.frameView.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.frameView.layer.shadowRadius = 3
        self.frameView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.frameView.layer.shadowOpacity = 0.7
        self.separationView.backgroundColor = UIColor.mediumSky
    }
    
    func configureLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.text = localized("personalArea_label_digitalProfile")
        self.descriptionLabel.textColor = UIColor.lisboaGray
        self.descriptionLabel.text = ""
        self.progressLabel.font = UIFont.santander(family: .text, type: .bold, size: 13.0)
        self.progressLabel.textColor = UIColor.lisboaGray
        self.progressLabel.text = ""
    }

    func resetView() {
        self.progressView.setProgress(0, animated: false)
        self.progressLabel.text = ""
        self.descriptionLabel.text = ""
        self.medalImage.image = nil
    }
    
    func setDescriptionLabel(_ percentage: Double) {
        let localizedText: LocalizedStylableText = percentage == 100
            ? localized("personalArea_text_topDigitalProfile")
            : localized("personalArea_text_superDigitalProfile")
        self.descriptionLabel.configureText(withLocalizedString: localizedText,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16.0)))
    }
}
