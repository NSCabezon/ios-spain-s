//
//  OfferCollectionViewCell.swift
//  GlobalPosition
//
//  Created by Victor Carrilero García on 11/03/2020.
//

import UIKit
import CoreFoundationLib

final class OfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    private var currentTask: CancelableTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentTask?.cancel()
    }
    
    func setImageSource(_ url: String?) {
        if let urlUnwrapped = url {
            self.currentTask = self.imageView.loadImage(urlString: urlUnwrapped)
        } else {
            self.imageView.image = nil
        }
    }
}
