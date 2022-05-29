//
//  PendingRequestCollectionView.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 09/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol PendingRequestCollectionViewDelegate: AnyObject {
    func pendingRequestIsHidden(_ isHidden: Bool)
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel)
}

final class PendingRequestCollectionView: UICollectionView {
    
    private let cellIndentifier = "PendingRequestCollectionViewCell"
    private let layout = ZoomAndSnapFlowLayout()
    private var viewModels: [StickyButtonCarrouselViewModelProtocol] = []
    weak var pendingRequestDelegate: PendingRequestCollectionViewDelegate?
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [StickyButtonCarrouselViewModelProtocol]) {
        self.viewModels = viewModels
        self.reloadData()
        pendingRequestDelegate?.pendingRequestIsHidden(viewModels.isEmpty)
    }
}

private extension PendingRequestCollectionView {
    
    func setupView() {
        self.registerCell()
        self.addLayout()
        self.backgroundColor = .clear
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: 100))
        self.layout.setMinimumLineSpacing(16)
        self.layout.setZoom(0)
        self.layout.setEdgeInsets(UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28))
        self.collectionViewLayout = self.layout
    }

    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIndentifier, bundle: Bundle(for: PendingRequestCollectionViewCell.self))
        self.register(nib, forCellWithReuseIdentifier: cellIndentifier)
    }
}

extension PendingRequestCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewModel = self.viewModels[indexPath.row] as? PendingSolicitudeViewModel {
            self.pendingRequestDelegate?.pendingRequestSelected(viewModel)
        }
    }
}

extension PendingRequestCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIndentifier, for: indexPath) as? PendingRequestCollectionViewCell
        if let viewModel = self.viewModels[indexPath.row] as? PendingSolicitudeViewModel {
            cell?.configure(viewModel)
        }
        cell?.accessibilityIdentifier = "areaCarousel\(indexPath.row + 1)"
        return cell ?? UICollectionViewCell()
    }
}
