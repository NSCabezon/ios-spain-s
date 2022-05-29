//
//  CardBoardingWelcomeCell.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 12/11/2020.
//

import Foundation
import UI
import CoreFoundationLib

class CardBoardingWelcomeCell: UICollectionViewCell {
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.offerImageView?.image = nil
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }
    
    func setImageWithUrl(_ url: String?) {
        guard let urlUnwrapped = url else { return }
        self.offerImageView.loadImage(urlString: urlUnwrapped)
    }
    
    func setAccesibilityIdentifier(index: Int) {
        self.accessibilityIdentifier = "imgCarousel" + "\(index)"
    }
}

private extension CardBoardingWelcomeCell {
    
    func configureCell() {
        self.layer.masksToBounds = false
        self.viewContainer.drawBorder(cornerRadius: 6.0, color: .mediumSkyGray, width: 1.5)
        self.drawShadow(offset: (x: 0, y: 2), opacity: 0.9, color: .lightSanGray, radius: 3.0)
        self.contentView.backgroundColor = UIColor.clear
        self.viewContainer.clipsToBounds = true
    }
}
