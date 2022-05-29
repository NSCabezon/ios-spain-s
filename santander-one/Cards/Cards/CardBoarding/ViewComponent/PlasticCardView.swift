//
//  CardView.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 06/10/2020.
//

import UI
import CoreFoundationLib

final class PlasticCardView: UIDesignableView {
    
    @IBOutlet weak private var cardImageView: UIImageView!
    @IBOutlet weak private var shadowImageView: UIImageView!
    @IBOutlet weak private var panLabel: UILabel!
    @IBOutlet weak private var ownerLabel: UILabel!
    @IBOutlet weak private var expiryLabel: UILabel!
    
    private lazy var defaultImage: UIImage? = {
        return Assets.image(named: "defaultCard")
    }()
    private var currentTask: CancelableTask?
    private var viewModel: PlasticCardViewModel? {
        didSet {
            self.updateCardInformation()
        }
    }
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupUI()
    }
    
    func setViewModel(_ viewModel: PlasticCardViewModel) {
        self.viewModel = viewModel
    }
    func increaseFontScaleBy(_ scale: CGFloat) {
        let scaledPanFontSize = self.panLabel.font.pointSize * (scale + 0.5)
        let scaledOwnerFontSize = self.ownerLabel.font.pointSize * scale
        let scaledExpiryLabelFontSize = self.expiryLabel.font.pointSize * scale
        
        self.changeFontScaleForLabel(&self.panLabel, withScale: scaledPanFontSize)
        self.changeFontScaleForLabel(&self.ownerLabel, withScale: scaledOwnerFontSize)
        self.changeFontScaleForLabel(&self.expiryLabel, withScale: scaledExpiryLabelFontSize)
    }
    
    deinit {
        self.currentTask = nil
    }
}

private extension PlasticCardView {
    func setupUI() {
        self.shadowImageView.image = Assets.image(named: "shadowCard")
        self.shadowImageView.accessibilityIdentifier = AccessibilityCardBoarding.Alias.shadowCardImage
        self.cardImageView.accessibilityIdentifier = AccessibilityCardBoarding.Alias.PlasticCard.image
        self.panLabel.accessibilityIdentifier = AccessibilityCardBoarding.Alias.PlasticCard.pan
        self.expiryLabel.accessibilityIdentifier = AccessibilityCardBoarding.Alias.PlasticCard.expiration
        self.ownerLabel.accessibilityIdentifier = AccessibilityCardBoarding.Alias.PlasticCard.ownerName
        self.panLabel.setHalterRegularTextFont(size: 10.0)
        self.ownerLabel.setHalterRegularTextFont(size: 8.0)
        self.expiryLabel.setHalterRegularTextFont(size: 7.0)
        let expiryLabeltopConstraint = NSLayoutConstraint(item: self.expiryLabel as Any,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self.cardImageView,
                                               attribute: .bottom,
                                               multiplier: 0.71,
                                               constant: 0)
        expiryLabeltopConstraint.priority = .required
        expiryLabeltopConstraint.isActive = true
        self.hideAllUIComponents(true)
    }
    
    func updateCardInformation() {
        guard let viewModel = self.viewModel, let plasticUrl = viewModel.fullCardImageStringUrl, let placeHolderImage = self.defaultImage else { return }
        self.currentTask = self.cardImageView.loadImage(urlString: plasticUrl, placeholder: placeHolderImage, completion: { [weak self] in
            self?.setCardInformation()
        })
    }
    
    func changeFontScaleForLabel(_ label: inout UILabel, withScale scale: CGFloat) {
        let scaledFont =  label.font.withSize(scale)
        label.font = scaledFont
    }
    
    func setCardInformation() {
        guard let viewModel = self.viewModel, let defaultImage = self.defaultImage else { return }
        self.hideAllUIComponents(false)
        if self.cardImageView.image == defaultImage {
            self.expiryLabel.textColor = .white
            self.ownerLabel.textColor = .white
            self.panLabel.textColor = .white
        } else {
            self.expiryLabel.textColor = viewModel.tintColor
            self.ownerLabel.textColor = viewModel.tintColor
            self.panLabel.textColor = viewModel.tintColor
        }
        self.ownerLabel.text = viewModel.ownerDisplayName ?? ""
        self.panLabel.text = viewModel.pan ?? ""
        self.expiryLabel.text = viewModel.expirationDateFormatted ?? ""
    }
    
    func hideAllUIComponents(_ hidden: Bool) {
        guard let contentview = self.subviews.first else {
            return
        }
        contentview.subviews.forEach({$0.isHidden = hidden})
    }
}
