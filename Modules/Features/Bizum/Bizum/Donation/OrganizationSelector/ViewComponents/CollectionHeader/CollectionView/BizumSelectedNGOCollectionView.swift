//
//  BizumSelectedNGOCollectionView.swift
//  Bizum

import Foundation
import UI

final class BizumSelectedNGOCollectionView: UICollectionView {
    let bizumSelectedNgoDataSource = BizumSelectedNGOCollectionDataSource()
    let cellIdentifiers = [
        BizumSelectedNGOCollectionViewCell.identifier
    ]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setCollectionViewData(_ viewModels: [BizumNGOCollectionViewCellViewModel]) {
        self.bizumSelectedNgoDataSource.setViewModels(viewModels)
    }
    
    func setDelegate(delegate: BizumSelectedNGOCollectionDataSourceDelegate?) {
        self.bizumSelectedNgoDataSource.dataSourceDelegate = delegate
    }
}

private extension BizumSelectedNGOCollectionView {
    func setupView() {
        self.registerCells()
        self.setupCollectionView()
        self.configureLayout()
    }
    
    func setupCollectionView() {
        self.dataSource = self.bizumSelectedNgoDataSource
        self.delegate = self.bizumSelectedNgoDataSource
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
        flowloyout.itemSize = CGSize(width: 136, height: 120)
        flowloyout.minimumLineSpacing = 8
        flowloyout.minimumInteritemSpacing = 8
        flowloyout.scrollDirection = .horizontal
    }
}
