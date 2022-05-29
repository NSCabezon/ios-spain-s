//
//  PendingSolicitudesUICollectionView.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import UIKit
import UI
import CoreFoundationLib

final class PendingSolicitudesUICollectionView: UICollectionView {
    private let cellIndentifier = "PendingSolicitudeUICollectionCell"
    private let layout = ZoomAndSnapFlowLayout()
    private var viewModels: [PendingSolicitudeInboxViewModel] = []
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.registerCell()
        self.addLayout()
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    private func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        layout.setItemSize(CGSize(width: itemWidth, height: 149))
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        layout.setEdgeInsets(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        self.collectionViewLayout = layout
    }

    private func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    private func registerCell() {
        let nib = UINib(nibName: cellIndentifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: cellIndentifier)
    }
    
    public func setViewModels(_ viewModels: [PendingSolicitudeInboxViewModel]) {
        self.viewModels = viewModels
        self.reloadData()
    }
}

extension PendingSolicitudesUICollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.row]
        let offer = viewModel.offer
        viewModel.action?(offer)
    }
}

extension PendingSolicitudesUICollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIndentifier, for: indexPath) as? PendingSolicitudeUICollectionCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.configure(viewModel)
        return cell ?? UICollectionViewCell()
    }
}
