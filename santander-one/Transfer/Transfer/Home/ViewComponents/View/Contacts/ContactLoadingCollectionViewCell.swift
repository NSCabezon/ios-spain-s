//
//  ContactLoadingCollectionViewCell.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 06/02/2020.
//

import UIKit

final class ContactLoadingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingImage: UIImageView!
    
    // MARK: - Public
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func prepareForReuse() {
        self.setupView()
    }
    
    // MARK: - Private
    
    private func setupView() {
        self.loadingImage.setPointsLoader()
    }
}
