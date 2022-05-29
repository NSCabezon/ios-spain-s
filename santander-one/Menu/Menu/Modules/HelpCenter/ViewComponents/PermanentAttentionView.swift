//
//  PermanentAttentionView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 8/6/20.
//

import Foundation
import CoreFoundationLib

final class PermanentAttentionView: UIView {
    let bannerImage = UIImageView()
    private var viewModel: PermanentAttentionViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.addSubview(bannerImage)
        self.bannerImage.fullFit()
        self.bannerImage.isUserInteractionEnabled = true
        self.bannerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doAction)))
        self.bannerImage.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.imgOfferAtt.rawValue
    }

    @objc func doAction() {
        self.viewModel?.action?(viewModel?.offer)
    }
    
    func setViewModel(_ viewModel: PermanentAttentionViewModel?) {
        self.viewModel = viewModel
        guard let viewModel = viewModel, let imageUrl = viewModel.imageUrl else {
            self.isHidden = true
            return
        }
        self.loadBannerImage(url: imageUrl)
    }
    
    private func loadBannerImage(url: String) {
        self.bannerImage.loadImage(urlString: url, placeholder: nil) { [weak self] in
            guard let self = self else { return }
            guard let image = self.bannerImage.image else {
                self.isHidden = true
                return
            }
            let ratio = image.size.height / image.size.width
            self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).isActive = true
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addConstraint()
    }
    
    func addConstraint() {
        guard let parentView = self.superview else { return }
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: 0)
        ])
    }
}
