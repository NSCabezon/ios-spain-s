//
//  CardFinanceableTransactionsCollectionDataSource.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 25/06/2020.
//

import Foundation

protocol CardFinanceableTransactionsCollectionDataSourceDelegate: AnyObject {
    func didSelectCardFinanceableTransaction(_ transaction: CardFinanceableTransactionViewModel)
}

final class CardFinanceableTransactionsCollectionDataSource: NSObject {
    private var viewModels: [CardFinanceableTransactionViewModel] = []
    weak var dataSourceDelegate: CardFinanceableTransactionsCollectionDataSourceDelegate?
    
    func setViewModels(_ viewModels: [CardFinanceableTransactionViewModel]) {
        self.viewModels = viewModels
    }
}

extension CardFinanceableTransactionsCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardFinanceableTransactionCollectionViewCell.identifier, for: indexPath
            ) as? CardFinanceableTransactionCollectionViewCell else { return UICollectionViewCell() }
        cell.setViewModel(viewModels[indexPath.row])
        return cell
    }
}

extension CardFinanceableTransactionsCollectionDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataSourceDelegate?.didSelectCardFinanceableTransaction(viewModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 16, bottom: 11, right: 16)
    }
}
