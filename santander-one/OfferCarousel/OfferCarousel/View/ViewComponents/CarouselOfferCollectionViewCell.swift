//
//  CarouselOfferCollectionViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 08/02/2021.
//
import UIKit
import UI
import CoreFoundationLib

protocol CarouselOfferCollectionViewCellDelegate: class {
    func pullOfferCloseDidPressed(_ elem: Any?)
    func pullOfferResizeTo(_ size: CGFloat, _ elem: Any?)
}

final class CarouselOfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var offerImage: UIImageView!
    private var offer: Any?
    private var height: CGFloat = 40.0
    private var currentTask: CancelableTask?
    weak var delegate: CarouselOfferCollectionViewCellDelegate?
    public var viewIdentifier = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.skyGray
        self.layer.cornerRadius = 5.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        offer = nil
        offerImage?.image = nil
        currentTask?.cancel()
    }
    
    func setOffer(_ offer: CarouselOfferViewModel) {
        guard let image = offer.imgURL else { return }
        self.offer = offer.elem
        currentTask = offerImage?.loadImage(urlString: image)
        self.accessibilityIdentifier = self.viewIdentifier
    }
    
    func setCellDelegate(_ delegate: CarouselOfferCollectionViewCellDelegate?) {
        self.delegate = delegate
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: height)
    }
}
