//
//  FeatureOfferView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol FeatureOfferDelegate: AnyObject {
    func didSelectOffer(offer: OfferEntity?)
    func didUpdateImageRatio(_ ratio: CGFloat)
}

class FeatureOfferView: XibView {
    private var offer: OfferEntity?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var offerImageView: UIImageView!
    weak var delegate: FeatureOfferDelegate?
    var downloadImageTask: CancelableTask?

    func setViewModel(_ viewModel: FeatureOfferViewModel, state: FeatureViewModelState) {
        self.offer = viewModel.entity
        self.setView(viewModel: viewModel, state: state)
    }
    
    func prepareForReuse() {
        self.updateImageHeight(to: 0)
        self.offerImageView.image = nil
        self.downloadImageTask?.cancel()
    }
    
    func updateImageHeight(to height: CGFloat) {
        self.offerImageView.constraints.filter({ $0.firstAttribute == .height }).forEach(self.offerImageView.removeConstraint)
        self.offerImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
    
    @IBAction func offerButtonPressed(_ sender: Any) {
        self.delegate?.didSelectOffer(offer: self.offer)
    }
}

private extension FeatureOfferView {
    
    func setView(viewModel: FeatureOfferViewModel, state: FeatureViewModelState) {
        switch state {
        case .initial:
            self.offerImageView.image = nil
            self.updateImageHeight(to: 0)
            guard let imageUrl = viewModel.previewImageUrl else { return }
            self.downloadImageTask = self.offerImageView.loadImage(urlString: imageUrl) { [weak self] in
                self?.setViewWithImage()
            }
        case .withoutOffer:
            self.offerImageView.image = nil
            self.updateImageHeight(to: 0)
        case .offerLoaded(ratio: let ratio):
            guard let imageUrl = viewModel.previewImageUrl else { return }
            self.offerImageView.loadImage(urlString: imageUrl)
            self.updateImageAspecRatio(CGFloat(ratio))
            if !self.offerImageView.isRightAspectRatio() {
                self.setViewWithImage()
            }
        }
    }
    
    func setViewWithImage() {
        guard let image = self.offerImageView.image else { return }
        let ratio = image.size.height / image.size.width
        self.updateImageAspecRatio(ratio)
        self.delegate?.didUpdateImageRatio(ratio)
    }
    
    func updateImageAspecRatio(_ ratio: CGFloat) {
        self.offerImageView.constraints.filter({ $0.firstAttribute == .height }).forEach(self.offerImageView.removeConstraint)
        self.offerImageView.heightAnchor.constraint(equalTo: self.offerImageView.widthAnchor, multiplier: ratio).isActive = true
    }
}
