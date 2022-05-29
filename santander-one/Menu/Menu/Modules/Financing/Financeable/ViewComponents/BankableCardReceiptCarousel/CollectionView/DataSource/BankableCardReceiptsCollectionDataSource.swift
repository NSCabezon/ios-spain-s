//
//  BankableCardReceiptsCollectionDataSource.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 13/1/22.
//

import Foundation

protocol BankableCardReceiptsCollectionDataSourceDelegate: AnyObject {
    func didSelectCell(_ viewModel: BankableCardReceiptViewModel)
}

final class BankableCardReceiptsCollectionDataSource: NSObject {
    
    // MARK: Variables
    
    private var viewModels: [BankableCardReceiptViewModel] = []
    weak var dataSourceDelegate: BankableCardReceiptsCollectionDataSourceDelegate?
    
    func setViewModels(_ viewModels: [BankableCardReceiptViewModel]) {
        self.viewModels = viewModels
    }
}

extension BankableCardReceiptsCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = viewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BankableCardReceiptsCollectionViewCell.identifier,
            for: indexPath
        ) as? BankableCardReceiptsCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configView(viewModel)
        return cell
        
    }
}

extension BankableCardReceiptsCollectionDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.row]
        dataSourceDelegate?.didSelectCell(viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 16, bottom: 11, right: 16)
    }
}
