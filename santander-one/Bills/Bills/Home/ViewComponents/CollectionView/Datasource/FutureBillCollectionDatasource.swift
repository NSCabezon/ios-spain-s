//
//  FutureBillCollectionDatasource.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import CoreFoundationLib

protocol FutureBillCollectionDatasourceDelegate: AnyObject {
    func didSelectTimeLine()
    func scrollViewDidEndDecelerating()
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel)
}

final class FutureBillCollectionDatasource: NSObject, UICollectionViewDataSource {
    private var state: ViewState<[FutureBillViewModel]> = .loading
    weak var datasourceDelegate: FutureBillCollectionDatasourceDelegate?
    private let timeLineSection = 1
    var numberOfSections = 2
    
    func didStateChanged(_ state: ViewState<[FutureBillViewModel]>) {
        self.state = state
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != timeLineSection else { return 1 }
        guard case let .filled(viewModels) = state else { return 1 }
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == timeLineSection {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: TimeLineCollectionViewCell.identifier, for: indexPath)
        } else {
            return self.collectionViewCell(for: collectionView, at: indexPath)
        }
    }
    
    private func collectionViewCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        switch state {
        case .loading:
            return collectionView.dequeueReusableCell(withReuseIdentifier:
                FutureLoadingCollectionViewCell.identifier, for: indexPath)
        case .empty:
            return collectionView.dequeueReusableCell(withReuseIdentifier:
                FutureEmptyCollectionViewCell.identifier, for: indexPath)
        case let .filled(viewModels):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                FutureCollectionViewCell.identifier, for: indexPath)
            let viewModel = viewModels[indexPath.row]
            (cell as? FutureCollectionViewCell)?.setViewModel(viewModel)
            return cell
        }
    }
}

extension FutureBillCollectionDatasource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != timeLineSection else { self.datasourceDelegate?.didSelectTimeLine(); return }
        guard case let .filled(viewModels) = state else { return }
        self.datasourceDelegate?.didSelectFutureBill(viewModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard case .loading = self.state else { return true }
        guard indexPath.section != timeLineSection else { return true }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        guard section == timeLineSection else {
          return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
    }
}

extension FutureBillCollectionDatasource: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        datasourceDelegate?.scrollViewDidEndDecelerating()
    }
}
