//
//  BizumSelectedNGOCollectionDataSource.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 15/02/2021.
//

import Foundation

protocol BizumSelectedNGOCollectionDataSourceDelegate: class {
    func didSelectBizumSelectedNGO(_ ngo: BizumNGOCollectionViewCellViewModel)
}

final class BizumSelectedNGOCollectionDataSource: NSObject {
    private var viewModels: [BizumNGOCollectionViewCellViewModel] = []
    weak var dataSourceDelegate: BizumSelectedNGOCollectionDataSourceDelegate?
    
    func setViewModels(_ viewModels: [BizumNGOCollectionViewCellViewModel]) {
        self.viewModels = viewModels
    }
}

extension BizumSelectedNGOCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BizumSelectedNGOCollectionViewCell.identifier, for: indexPath
            ) as? BizumSelectedNGOCollectionViewCell else { return UICollectionViewCell() }
        cell.setViewModel(viewModels[indexPath.row])
        return cell
    }
}

extension BizumSelectedNGOCollectionDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataSourceDelegate?.didSelectBizumSelectedNGO(self.viewModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 16, bottom: 11, right: 16)
    }
}
