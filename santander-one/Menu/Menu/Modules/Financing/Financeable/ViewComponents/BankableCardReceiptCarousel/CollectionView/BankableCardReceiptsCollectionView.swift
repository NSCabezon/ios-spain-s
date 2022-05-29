//
//  BankableCardReceiptsCollectionView.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 13/1/22.
//

import Foundation

final class BankableCardReceiptsCollectionView: UICollectionView {
    
    // MARK: Constants
    
    private let itemSize = CGSize(width: 196, height: 123)
    private let spacing: CGFloat = 8
    private let bankableCardReceiptsDataSource = BankableCardReceiptsCollectionDataSource()
    private let cellIdentifiers = [
        BankableCardReceiptsCollectionViewCell.identifier,
        BankableCardReceiptSeeMoreCollectionViewCell.identifier
    ]
    
    // MARK: Initialization
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: Set delegates
    
    func setCollectionViewData(_ viewModels: [BankableCardReceiptViewModel]) {
        bankableCardReceiptsDataSource.setViewModels(viewModels)
    }

    func setDelegate(delegate: BankableCardReceiptsCollectionDataSourceDelegate?) {
        bankableCardReceiptsDataSource.dataSourceDelegate = delegate
    }
}

// MARK: Private extension

private extension BankableCardReceiptsCollectionView {
    func setupView() {
        registerCells()
        setupCollectionView()
        configureLayout()
    }
    
    func setupCollectionView() {
        dataSource = self.bankableCardReceiptsDataSource
        delegate = self.bankableCardReceiptsDataSource
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
    }
    
    func registerCells() {
        cellIdentifiers.forEach {
            register(UINib(nibName: $0, bundle: .module), forCellWithReuseIdentifier: $0)
        }
    }
    
    func configureLayout() {
        guard let flowlayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowlayout.itemSize = itemSize
        flowlayout.minimumLineSpacing = spacing
        flowlayout.minimumInteritemSpacing = spacing
        flowlayout.scrollDirection = .horizontal
    }
}
