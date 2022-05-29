//
//  CollectionViewCellRepresentable.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import UIKit

public protocol CollectionViewCellRepresentable {
    func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}
