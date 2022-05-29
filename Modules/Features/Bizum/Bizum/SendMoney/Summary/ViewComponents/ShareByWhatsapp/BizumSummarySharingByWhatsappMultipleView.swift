//
//  BizumSummarySharingByWhatsappMultipleView.swift
//  Bizum
//
//  Created by Ignacio González Miró on 9/12/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol DidTapInSharingByWhatsappMultiplePillDelegate: class {
    func didTapInSharingByWhatsappMultiplePill()
}

final class BizumSummarySharingByWhatsappMultipleView: UIDesignableView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var seeMoreLabel: UILabel!
    @IBOutlet private weak var disclaimerImage: UIImageView!
    @IBOutlet private weak var stackViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var thumbnailImageView: UIImageView!

    weak var delegate: DidTapInSharingByWhatsappMultiplePillDelegate?
    
    override func getBundleName() -> String {
        return "Bizum"
    }

    override func commonInit() {
        super.commonInit()
        self.seeMoreLabel.isHidden = true
        self.setupView()
    }
    
    func configure(_ contacts: [BizumContactEntity]) {
        let maxContacts = Array(contacts.prefix(4))
        self.loadItemsInStackView(maxContacts)
        self.loadSeeMoreLabel(contacts)
        self.updateStackViewWidth(contacts)
    }
}

private extension BizumSummarySharingByWhatsappMultipleView {
    func setupView() {
        self.setTapGestureRecognizer()
        self.setAppeareance()
        self.setAccessibilityIds()
    }
    
    func setTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInShareByWhatsappMultiplePill))
        self.containerView.addGestureRecognizer(tap)
    }
    
    func setAppeareance() {
        let shadowConfiguration = ShadowConfiguration(color: .shadesWhite, opacity: 1, radius: 5, withOffset: 1, heightOffset: 1.5)
        self.containerView.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 5, borderColor: .lightSkyBlue, borderWith: 1)
        self.disclaimerImage.image = Assets.image(named: "icnArrowRight")
        self.backgroundColor = .clear
    }
    
    func setAccessibilityIds() {
        self.containerView.accessibilityIdentifier = AccessibilitySharingByWhatsapp.multiplePill
    }
    
    func loadItemsInStackView(_ contacts: [BizumContactEntity]) {
        let colorsEngine = ColorsByNameEngine()
        contacts.forEach { (item) in
            self.loadCircleWithInitialsLabel(item, colorsEngine: colorsEngine)
        }
    }
    
    func loadCircleWithInitialsLabel(_ item: BizumContactEntity, colorsEngine: ColorsByNameEngine) {
        let colorType = colorsEngine.get(item.alias ?? "")
        let colorModel = ColorsByNameViewModel(colorType)
        let frameCircle = CGRect(origin: .zero, size: CGSize(width: 31, height: 31))
        let circleView = UIView(frame: frameCircle)
        circleView.layer.cornerRadius = frameCircle.size.height / 2
        circleView.clipsToBounds = true
        if let imageData = item.thumbnailData {
            let imageView = UIImageView(frame: circleView.frame)
            let contactImage = UIImage(data: imageData)
            imageView.image = contactImage
            circleView.addSubview(imageView)
        } else {
            circleView.backgroundColor = colorModel.color
            let initialsNameLabel = UILabel(frame: circleView.frame)
            initialsNameLabel.font = UIFont.santander(family: .text, type: .bold, size: 13)
            initialsNameLabel.textAlignment = .center
            initialsNameLabel.textColor = .white
            initialsNameLabel.text = item.name?.nameInitials ?? ""
            circleView.addSubview(initialsNameLabel)
        }
        self.stackView.addArrangedSubview(circleView)
    }
    
    func loadSeeMoreLabel(_ contacts: [BizumContactEntity]) {
        let isSeeMoreLabelHidden = contacts.count > 4
        let numberOfContacts = contacts.count - 4
        self.seeMoreLabel.isHidden = !isSeeMoreLabelHidden
        self.seeMoreLabel.setSantanderTextFont(type: .regular, size: 16, color: .lisboaGray)
        self.seeMoreLabel.set(localizedStylableText: localized("bizum_label_andMore", [StringPlaceholder(.number, "\(numberOfContacts)")]))
        self.seeMoreLabel.textAlignment = .left
    }
    
    func updateStackViewWidth(_ contacts: [BizumContactEntity]) {
        let numberOfMargings = CGFloat(self.stackView.arrangedSubviews.count - 1)
        let updatedStackViewMarginsWidth = self.stackView.spacing * numberOfMargings
        let updatedStackViewWidth = self.getStackViewWidth()
        let newStackViewWidth = updatedStackViewWidth + updatedStackViewMarginsWidth
        self.stackViewWidth.constant = newStackViewWidth
        self.stackView.layoutIfNeeded()
    }
    
    func getStackViewWidth() -> CGFloat {
        var stackViewWidth: CGFloat = 0
        self.stackView.arrangedSubviews.forEach { (item) in
            stackViewWidth += item.frame.size.width
        }
        return stackViewWidth
    }
    
    @objc func didTapInShareByWhatsappMultiplePill() {
        delegate?.didTapInSharingByWhatsappMultiplePill() 
    }
}
