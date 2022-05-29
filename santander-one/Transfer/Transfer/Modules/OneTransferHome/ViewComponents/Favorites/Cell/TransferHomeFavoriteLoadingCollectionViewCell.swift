//
//  TransferHomeFavoriteLoadingCollectionViewCellCellCollectionViewCell.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import UIKit

final class TransferHomeFavoriteLoadingCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var loadingView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingView.setNewJumpingLoader()
    }
}
