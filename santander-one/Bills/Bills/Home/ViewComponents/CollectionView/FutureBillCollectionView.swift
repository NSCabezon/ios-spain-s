//
//  FutureBillCollectionView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import CoreFoundationLib

final class FutureBillCollectionView: UICollectionView {
    let futureBillDatasource = FutureBillCollectionDatasource()
    let cellIdentifiers = [
        FutureLoadingCollectionViewCell.identifier,
        FutureEmptyCollectionViewCell.identifier,
        FutureCollectionViewCell.identifier,
        TimeLineCollectionViewCell.identifier
    ]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func didStateChanged(_ state: ViewState<[FutureBillViewModel]>) {
        self.futureBillDatasource.didStateChanged(state)
        self.reloadData()
    }
    
    func setDelegate(delegate: FutureBillCollectionDatasourceDelegate?) {
        self.futureBillDatasource.datasourceDelegate = delegate
    }
    
    func registerCells() {
        self.cellIdentifiers.forEach {
            self.register(UINib(nibName: $0, bundle: .module), forCellWithReuseIdentifier: $0)
        }
    }
    
    func disableTimeLine() {
        self.futureBillDatasource.numberOfSections = 1
    }
}

private extension FutureBillCollectionView {
    func setupView() {
        self.registerCells()
        self.configureLayout()
        self.dataSource = self.futureBillDatasource
        self.delegate = self.futureBillDatasource
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
    
    func configureLayout() {
        guard let flowloyout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowloyout.itemSize = CGSize(width: 208, height: 120)
        flowloyout.minimumLineSpacing = 8
        flowloyout.minimumInteritemSpacing = 8
        flowloyout.scrollDirection = .horizontal
    }
}
