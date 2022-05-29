//
//  PendingSolicitudesUICollectionView.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol PendingSolicitudesCollectionViewDelegate: AnyObject {
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel)
    func pendingSolicitudeSelected(_ viewModel: PendingSolicitudeViewModel)
    func offerSelected(_ offer: OfferEntity)
}

final class PendingSolicitudesCollectionView: UICollectionView {
    
    private let pendingIndentifier = "PendingSolicitudeCollectionViewCell"
    private let recoveryIndentifier = "RecoveryExpandedView"
    private let layout = ZoomAndSnapFlowLayout()
    private var viewModels: [StickyButtonCarrouselViewModelProtocol] = []
    weak var pendingSolicitudesDelegate: PendingSolicitudesCollectionViewDelegate?
    
    private enum Constants {
        static let horizontalMargin: CGFloat = 28.0
        static let lineSpacing: CGFloat = 8.0
        static let itemHeigth: CGFloat = 104.0
    }
    
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.highlightCenterCell()
        }
    }
}

private extension PendingSolicitudesCollectionView {
    
    func setupView() {
        self.registerCell()
        self.addLayout()
        self.backgroundColor = .whitesmokes
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: Constants.itemHeigth))
        self.layout.setMinimumLineSpacing(Constants.lineSpacing)
        self.layout.setZoom(0)
        self.layout.setEdgeInsets(UIEdgeInsets(top: 0,
                                               left: Constants.horizontalMargin,
                                               bottom: 0,
                                               right: Constants.horizontalMargin))
        self.collectionViewLayout = self.layout
    }

    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width - (2.0 * Constants.horizontalMargin)
    }
    
    func registerCell() {
        let nib = UINib(nibName: pendingIndentifier, bundle: Bundle(for: PendingSolicitudesCollectionView.self))
        self.register(nib, forCellWithReuseIdentifier: pendingIndentifier)
        self.register(RecoveryExpandedView.self, forCellWithReuseIdentifier: recoveryIndentifier)
    }
    
    func pendingCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        guard let viewModel = self.viewModels[indexPath.row] as? PendingSolicitudeViewModel else { return nil }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pendingIndentifier,
                                                            for: indexPath) as? PendingSolicitudeCollectionViewCell else { return nil }
        cell.configure(viewModel)
        cell.delegate = self
        cell.accessibilityIdentifier = "areaCarousel\(indexPath.row + 1)"
        return cell
    }
    
    func recoveryCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        guard let viewModel = self.viewModels[indexPath.row] as? RecoveryViewModel else { return nil }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recoveryIndentifier,
                                                            for: indexPath) as? RecoveryExpandedView else { return nil }
        cell.setInfo(viewModel)
        cell.accessibilityIdentifier = "areaCarousel\(indexPath.row + 1)"
        return cell
    }
    
    func highlightCenterCell() {
        for visibleCell in self.visibleCells {
            let cell = visibleCell as? PendingSolicitudeCollectionViewCell
            cell?.setBackgroundColor(.oneSkyGray)
            cell?.setBorderColor(.oneBrownGray, shadowColor: .clear)
        }
        guard let highlightCell = self.visibleCells.filter { cell in
            let cellRect = self.convert(cell.frame, to: self.superview)
            return self.frame.contains(cellRect)
        }.first as? PendingSolicitudeCollectionViewCell
        else { return }
        highlightCell.setBackgroundColor(.oneWhite)
        highlightCell.setBorderColor(.oneMediumSkyGray, shadowColor: .oneLightSanGray)
    }
}

extension PendingSolicitudesCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewModel = self.viewModels[indexPath.row] as? PendingSolicitudeViewModel {
            self.pendingSolicitudesDelegate?.pendingSolicitudeSelected(viewModel)
        } else if let viewModel = self.viewModels[indexPath.row] as? StickyButtonCarrouselViewModelProtocol,
            let offer = viewModel.offer {
            self.pendingSolicitudesDelegate?.offerSelected(offer)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.highlightCenterCell()
    }
}

extension PendingSolicitudesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let pendingCell = pendingCell(collectionView, indexPath: indexPath) {
            return pendingCell
        } else if let recoveryCell = recoveryCell(collectionView, indexPath: indexPath) {
            return recoveryCell
        }
        return UICollectionViewCell()
    }
}

extension PendingSolicitudesCollectionView: PendingSolicitudeCollectionViewCellDelegate {
    
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel) {
        self.pendingSolicitudesDelegate?.pendingSolicitudeClosed(viewModel)
    }
}
