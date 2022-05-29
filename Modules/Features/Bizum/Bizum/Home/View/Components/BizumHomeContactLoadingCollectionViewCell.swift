//
//  BizumHomeContactLoadingCollectionViewCell.swift
//  Bizum
//
//  Created by Victor Carrilero García on 24/09/2020.
//

import UIKit

final class BizumHomeContactLoadingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var loadingImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
}

private extension BizumHomeContactLoadingCollectionViewCell {
    func configureView() {
        self.loadingImageView.setSecondaryLoader()
    }
}
