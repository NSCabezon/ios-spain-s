//
//  BizumSummarySharingByWhatsappSingleView.swift
//  Bizum
//
//  Created by Ignacio González Miró on 9/12/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidTapInSharingByWhatsappSinglePillDelegate: class {
    func didTapInSharingByWhatsappSinglePill()
}

final class BizumSummarySharingByWhatsappSingleView: UIDesignableView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var circleView: UIView!
    @IBOutlet private weak var initialLabels: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var disclaimerImage: UIImageView!
    @IBOutlet weak private var thumbnailImageView: UIImageView!

    weak var delegate: DidTapInSharingByWhatsappSinglePillDelegate?
    
    override func getBundleName() -> String {
        return "Bizum"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }

    func configure(_ bizumContactEntity: BizumContactEntity) {
        if let imageData = bizumContactEntity.thumbnailData {
            self.thumbnailImageView.image = UIImage(data: imageData)
            self.thumbnailImageView.isHidden = false
            self.initialLabels.isHidden = true
        } else {
            self.initialLabels.isHidden = false
            self.thumbnailImageView.isHidden = true
            let colorsEngine = ColorsByNameEngine()
            let colorType = colorsEngine.get(bizumContactEntity.alias ?? "")
            let colorModel = ColorsByNameViewModel(colorType)
            self.circleView.backgroundColor = colorModel.color
            self.initialLabels.text = bizumContactEntity.name?.nameInitials
        }
        self.titleLabel.text = bizumContactEntity.name
        self.phoneLabel.text = bizumContactEntity.phone.tlfFormatted()
    }
}

private extension BizumSummarySharingByWhatsappSingleView {
    func setupView() {
        self.setTapGestureRecognizer()
        self.setAppeareance()
        self.setAccessibilityIds()
    }
    
    func setTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInShareByWhatsappSinglePill))
        self.containerView.addGestureRecognizer(tap)
    }
    
    func setAppeareance() {
        self.backgroundColor = .clear
        let shadowConfiguration = ShadowConfiguration(color: .shadesWhite, opacity: 1, radius: 5, withOffset: 1, heightOffset: 1.5)
        self.containerView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 5, borderColor: .lightSkyBlue, borderWith: 1)
        self.circleView.backgroundColor = UIColor.botonRedLight
        self.circleView.layer.cornerRadius = circleView.frame.size.width/2
        self.circleView.clipsToBounds = true
        self.setLabels()
        self.disclaimerImage.image = Assets.image(named: "icnArrowRight")
    }
    
    func setLabels() {
        self.initialLabels.font = UIFont.santander(family: .text, type: .bold, size: 18)
        self.initialLabels.textAlignment = .center
        self.initialLabels.textColor = .lisboaGray
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = .lisboaGray
        self.phoneLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.phoneLabel.textAlignment = .left
        self.phoneLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIds() {
        self.containerView.accessibilityIdentifier = AccessibilitySharingByWhatsapp.singlePill
    }
    
    @objc func didTapInShareByWhatsappSinglePill() {
        delegate?.didTapInSharingByWhatsappSinglePill()
    }
}
