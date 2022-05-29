//
//  AccountFinanceableTransactionsCollectionView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation

final class AccountFinanceableTransactionsCollectionView: UICollectionView {
    let accountTransactionsDataSource = AccountFinanceableTransactionsCollectionDataSource()
    let cellIdentifiers = [
        AccountFinanceableTransactionCollectionViewCell.identifier
    ]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setCollectionViewData(_ viewModels: [AccountFinanceableTransactionViewModel]) {
        self.accountTransactionsDataSource.setViewModels(viewModels)
    }
    
    func setDelegate(delegate: AccountFinanceableTransactionsCollectionDataSourceDelegate?) {
        self.accountTransactionsDataSource.dataSourceDelegate = delegate
    }
}

private extension AccountFinanceableTransactionsCollectionView {
    func setupView() {
        self.registerCells()
        self.setupCollectionView()
        self.configureLayout()
    }
    
    func setupCollectionView() {
        self.dataSource = self.accountTransactionsDataSource
        self.delegate = self.accountTransactionsDataSource
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
    
    func registerCells() {
        self.cellIdentifiers.forEach {
            self.register(UINib(nibName: $0, bundle: .module), forCellWithReuseIdentifier: $0)
        }
    }
    
    func configureLayout() {
        guard let flowloyout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowloyout.itemSize = CGSize(width: 208, height: 120)
        flowloyout.minimumLineSpacing = 8
        flowloyout.minimumInteritemSpacing = 8
        flowloyout.scrollDirection = .horizontal
    }
}
