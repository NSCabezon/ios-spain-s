//
//  CarrouselCollectionRezisable.swift
//  UI
//
//  Created by Hernán Villamil on 6/4/22.
//

import UIKit

public protocol CarrouselCollectionRezisableCell {
    var width: CGFloat { get }
    func getCellHeight(_ cell: UICollectionViewCell, collectionVIew: UICollectionView) -> CGFloat
}

extension CarrouselCollectionRezisableCell {
    public func getCellHeight(_ cell: UICollectionViewCell, collectionVIew collectionView: UICollectionView) -> CGFloat {
        let height: CGFloat = 0
        let targetSize = CGSize(width: width, height: height)
        let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)
        return size.height
    }
}
