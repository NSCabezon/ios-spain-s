//
//  CommercialOffersBannerPillView.swift
//  Menu
//
//  Created by Ignacio González Miró on 23/12/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CommercialOffersBannerPillView: XibView {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var bannerImageView: UIImageView!
    
    private var viewModel: OfferEntityViewModel?
    private weak var delegate: CommercialOffersPillViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: OfferEntityViewModel, delegate: CommercialOffersPillViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        setImageWithUrl(
            viewModel.url,
            on: self.bannerImageView
        )
    }
}

private extension CommercialOffersBannerPillView {
    func setupView() {
        backgroundColor = .clear
        setBaseView()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setBaseView() {
        let shadowConfiguration = ShadowConfiguration(
            color: UIColor.lisboaGray.withAlphaComponent(0.33),
            opacity: 0.7,
            radius: 3.0,
            withOffset: 1,
            heightOffset: 2
        )
        baseView.drawRoundedBorderAndShadow(
            with: shadowConfiguration,
            cornerRadius: 6.0,
            borderColor: .white,
            borderWith: 0
        )
        baseView.backgroundColor = .white
    }
    
    func setAccessibilityIds() {
        baseView.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.bannerView
        bannerImageView.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.bannerImage
    }
    
    func setImageWithUrl(_ url: String?, on imageView: UIImageView) {
        guard let urlUnwrapped = url else { return }
        imageView.loadImage(urlString: urlUnwrapped) {
            guard let image = imageView.image else {return}
            let ratioWidth = Double(image.size.width)
            let ratioHeight = Double(image.size.height)
            let ratio = ratioHeight / ratioWidth
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
        }
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInCommercialOffer))
        baseView.addGestureRecognizer(tap)
    }
    
    @objc func didTapInCommercialOffer() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didTapInOffer(viewModel)
    }
}
