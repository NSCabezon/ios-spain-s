//
//  AccountFinanceableTransactionsCollectionDataSource.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation

protocol AccountFinanceableTransactionsCollectionDataSourceDelegate: AnyObject {
    func didSelectAccountFinanceableTransaction(_ transaction: AccountFinanceableTransactionViewModel)
}

final class AccountFinanceableTransactionsCollectionDataSource: NSObject {
    private var viewModels: [AccountFinanceableTransactionViewModel] = []
    weak var dataSourceDelegate: AccountFinanceableTransactionsCollectionDataSourceDelegate?
    
    func setViewModels(_ viewModels: [AccountFinanceableTransactionViewModel]) {
        self.viewModels = viewModels
    }
}

extension AccountFinanceableTransactionsCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountFinanceableTransactionCollectionViewCell.identifier, for: indexPath
            ) as? AccountFinanceableTransactionCollectionViewCell else { return UICollectionViewCell() }
        cell.setViewModel(viewModels[indexPath.row])
        return cell
    }
}

extension AccountFinanceableTransactionsCollectionDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataSourceDelegate?.didSelectAccountFinanceableTransaction(viewModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 16, bottom: 11, right: 16)
    }
}
