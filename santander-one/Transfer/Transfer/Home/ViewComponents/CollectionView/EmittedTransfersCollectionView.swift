//
//  EmittedTransfersCollectionView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UIKit
import UI
import CoreFoundationLib

protocol EmittedTransfersCollectionViewDelegate: AnyObject {
    func didSelectTransfer(_ viewModel: TransferViewModel)
    func didSwipe()
}

final class EmittedTransfersCollectionView: UICollectionView {
    private var viewModels: [TransferViewModel] = []
    private let identifier = "EmittedTransferCollectionViewCell"
    weak var transferDelegate: EmittedTransfersCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.configureLayout()
        self.registerCell()
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
    
    private func configureLayout() {
        guard let flowloyout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowloyout.itemSize = CGSize(width: 120, height: 133)
        flowloyout.minimumLineSpacing = 8
        flowloyout.minimumInteritemSpacing = 8
        flowloyout.scrollDirection = .horizontal
        flowloyout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func setViewModels(_ viewModels: [TransferViewModel]) {
        self.viewModels = viewModels
        self.reloadData()
    }
}

extension EmittedTransfersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? EmittedTransferCollectionViewCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.configure(viewModel)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.row]
        self.transferDelegate?.didSelectTransfer(viewModel)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.transferDelegate?.didSwipe()
    }
}
