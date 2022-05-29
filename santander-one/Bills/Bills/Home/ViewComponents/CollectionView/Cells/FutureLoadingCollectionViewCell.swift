//
//  FutureLoadingCollectionViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import UIKit

class FutureLoadingCollectionViewCell: UICollectionViewCell {
    static let identifier = "FutureLoadingCollectionViewCell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
    }
    
    func appearance() {
        self.containerView.backgroundColor = .skyGray
        self.containerView.drawBorder(cornerRadius: 5, color: .skyGray, width: 1)
        self.loadingImageView.setPointsLoader()
    }
}
