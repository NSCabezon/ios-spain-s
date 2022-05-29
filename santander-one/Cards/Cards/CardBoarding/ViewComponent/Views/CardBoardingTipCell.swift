//
//  CardBoardingTipCell.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

class CardBoardingTipCell: UICollectionViewCell {
    static let identifier = "CardBoardingTipCell"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var offerImageView: UIImageView!
    private var currentTask: CancelableTask?
    private var viewModel: OfferTipViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.offerImageView?.image = nil
        self.currentTask = nil
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }
    
    private func configureCell() {
        self.layer.masksToBounds = false
        self.viewContainer.drawBorder(cornerRadius: 6.0, color: .mediumSkyGray, width: 1.5)
        self.drawShadow(offset: (x: 0, y: 2), opacity: 0.9, color: .lightSanGray, radius: 3.0)        
        self.contentView.backgroundColor = UIColor.clear
        self.viewContainer.clipsToBounds = true
    }
    
    func configureCellWithModel(_ model: OfferTipViewModel) {
        guard let imageUrl = model.imageUrl else { return }
        self.currentTask =  self.offerImageView.loadImage(urlString: imageUrl)
    }
    func setAccesibilityIdentifier(index: Int) {
        self.accessibilityIdentifier = "imgCarousel" + "\(index)"
    }
}
