//
//  SizeOffersCollectionViewCell.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 24/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class SizeOffersCollectionViewCell: UICollectionViewCell {    

    @IBOutlet private weak var roundedView: RoundedView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var favoriteIconImageView: UIImageView!
    @IBOutlet private weak var firstSizeView: UIView!
    @IBOutlet private weak var secondSizeView: UIView!
    @IBOutlet private weak var thirdSizeView: UIView!
    @IBOutlet private var sizeImageViews: [UIImageView]!
    
    private var currentsTasks = [CancelableTask?]()
    private var cellInfo: SizeOfferViewModel?
    private weak var delegate: CollectionControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sizeImageViews.forEach { $0.image = nil }
        currentsTasks.forEach { $0?.cancel() }
        titleLabel.text = ""
    }
    
    func setCellInfo(_ info: SizeOfferViewModel, delegate: CollectionControllerDelegate?) {
        self.cellInfo = info
        self.delegate = delegate
        titleLabel.text = info.title
        hideSizeViews()
        setImages()
        setAccessibilityLabel()
    }
}

private extension SizeOffersCollectionViewCell {
    func commonInit() {
        configureElements()
        configureView()
    }
    
    func configureElements() {
        titleLabel.font = .santander(family: .text, type: .regular, size: 20.0)
        favoriteIconImageView.image = Assets.image(named: "iconMarker")
    }
    
    func configureView() {
        self.roundedView.frameBackgroundColor = UIColor.blueAnthracita.cgColor
        self.roundedView.backgroundColor = .clear
        self.roundedView.roundTopCorners()
        self.drawRoundedAndShadowedNew(borderColor: .mediumSkyGray)
        self.layer.masksToBounds = true
    }
    
    func hideSizeViews() {
        guard let size = cellInfo?.size else { return }
        thirdSizeView.isHidden = size < 3
        secondSizeView.isHidden = size < 2
    }
    
    func setImages() {
        guard let size = cellInfo?.size else { return }
        let urlImages = cellInfo?.offers.compactMap({ $0.banner?.url })
        urlImages?.enumerated().forEach { (position, urlImage) in
            guard size > position else { return }
            currentsTasks.append(sizeImageViews[position].loadImage(urlString: urlImage))
            sizeImageViews[position].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedOffer(_:))))
            sizeImageViews[position].isUserInteractionEnabled = true
        }
    }
    
    @objc func didPressedOffer(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView,
            let index = sizeImageViews.firstIndex(of: view),
            let offers = cellInfo?.offers,
            offers.count > index,
            let offer = cellInfo?.offers[index] else { return }
        delegate?.didSelectedSizeOffer(offer)
    }
    
    func setAccessibilityLabel() {
        let titleValue = self.titleLabel.text ?? ""
        self.accessibilityLabel = localized(titleValue)
        self.accessibilityValue = localized("voiceover_commercialOffer")
        self.accessibilityTraits = .button
        self.titleLabel.isAccessibilityElement = false
        self.isAccessibilityElement = true
    }
}

struct SizeOfferViewModel {
    let title: String
    let size: Int?
    let offers: [OfferEntity]
}
