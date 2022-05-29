//
//  CollectionViewController.swift
//  GlobalPosition
//
//  Created by César González Palomino on 24/04/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol CollectionControllerDelegate: AnyObject {
    func timelineSelected()
    func timelineOfferSelected()
    func didScrollTo(index: Int)
    func didEndedScroll()
    func didSelectedSizeOffer(_ offer: OfferEntity)
}

final class GlobalPositionCollectionController: NSObject {
    private weak var dependenciesResolver: DependenciesResolver?
    private var dataSource: [BookmarkImageType] = []
    private var loanSimulatorViewModel: LoanSimulatorViewModel?
    private var timelineType: PGBookmarkTimelineTypeViewModel?
    private var sizeOfferViewModel: [SizeOfferViewModel] = []
    private var collectionView: UICollectionView?
    private weak var loanDelegate: LoanSimulatorCollectionViewCellProtocol?
    private weak var delegate: CollectionControllerDelegate?
    
    var itemsCount: Int { dataSource.count }
    
    private override init() {
        self.collectionView = UICollectionView()
        super.init()
    }
    
    init(collectionView: UICollectionView,
         delegate: CollectionControllerDelegate,
         loanDelegate: LoanSimulatorCollectionViewCellProtocol) {
        self.collectionView = collectionView
        self.loanDelegate = loanDelegate
        self.delegate = delegate
        self.collectionView?.register(TimeLineCollectionViewCell.self,
                                    forCellWithReuseIdentifier: "TimeLineCollectionViewCell")
        self.collectionView?.register(UINib(nibName: "OfferCollectionViewCell",
                                           bundle: Bundle(for: OfferCollectionViewCell.self)),
                                     forCellWithReuseIdentifier: "OfferCollectionViewCell")
        self.collectionView?.register(UINib(nibName: "SizeOffersCollectionViewCell",
                                           bundle: Bundle(for: SizeOffersCollectionViewCell.self)),
                                     forCellWithReuseIdentifier: "SizeOffersCollectionViewCell")
        collectionView.register(LoanSimulatorCollectionViewCell.self,
                                forCellWithReuseIdentifier: "LoanSimulatorCollectionViewCell")
        collectionView.delaysContentTouches = false
    }

    func updateInfo(_ info: PGBookmarkTableViewModel) {
        collectionView?.dataSource = self
        collectionView?.delegate = self
        dependenciesResolver = info.resolver
        loanSimulatorViewModel = info.loanViewModel
        timelineType = info.timelineType
        sizeOfferViewModel = info.sizeOfferViewModel
        updateDataSource()
        collectionView?.reloadData()
    }
    
    func scrollToPregrantedLoans() {
        guard let index = dataSource.firstIndex(where: { $0 == .pregrantedLoans }) else { return }
        self.collectionView?.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}

private extension GlobalPositionCollectionController {
    struct Insets {
        private init() {}
        static let defaultInset: CGFloat = 16.0
    }
    
    func widthPerItem() -> CGFloat {
        let itemsPerRow: CGFloat = 1.1
        let paddingSpace = Insets.defaultInset * (itemsPerRow + 1)
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return widthPerItem
    }
    
    func currentPage(_ scrollView: UIScrollView) -> CGFloat {
        if self.dataSource.count > 1 {
            let itemWidth: CGFloat = self.widthPerItem()
            let pageWidth: CGFloat = itemWidth + Insets.defaultInset * 2
            let currentOffset = scrollView.contentOffset.x
            return round(currentOffset / pageWidth)
        } else {
            return round(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    func updateDataSource() {
        self.dataSource = []
        if let timelineType = self.timelineType {
            switch timelineType {
            case .timeline:
                self.dataSource.append(.timeline)
            case .offer:
                if case .offer(let url) = self.timelineType, url != nil {
                    self.dataSource.append(.timelineOffer)
                }
            }
        }
        if self.loanSimulatorViewModel != nil {
            self.dataSource.append(.pregrantedLoans)
        }
        if self.sizeOfferViewModel.count > 0 {
            sizeOfferViewModel.forEach { _ in self.dataSource.append(.sizeOffer) }
        }
    }
}

extension GlobalPositionCollectionController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        if indexPath.row > dataSource.count - 1 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "SizeOffersCollectionViewCell", for: indexPath) as? SizeOffersCollectionViewCell ?? UICollectionViewCell()
        }
        let type = dataSource[indexPath.row]
        switch type {
        case .pregrantedLoans:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoanSimulatorCollectionViewCell",
                                                      for: indexPath) as? LoanSimulatorCollectionViewCell
            if let loanCell = cell as? LoanSimulatorCollectionViewCell,
               let viewModel = loanSimulatorViewModel,
                let resolver = dependenciesResolver {
                loanCell.configureWith(viewModel: viewModel, resolver: resolver)
                if loanCell.delegate == nil { loanCell.delegate = loanDelegate }
            }
        case .timeline:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeLineCollectionViewCell",
                                                      for: indexPath) as? TimeLineCollectionViewCell
            if let timeLineCell = cell as? TimeLineCollectionViewCell,
               let resolver = dependenciesResolver {
                timeLineCell.configureImageWith(resolver: resolver)
            }
        case .timelineOffer:
            let offerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell",
                                                                             for: indexPath) as? OfferCollectionViewCell
            if case .offer(let url) = self.timelineType {
                offerCollectionViewCell?.setImageSource(url)
            } else {
                offerCollectionViewCell?.setImageSource(nil)
            }
            cell = offerCollectionViewCell
        case .sizeOffer:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeOffersCollectionViewCell", for: indexPath) as? SizeOffersCollectionViewCell
            let firstIndex = dataSource.firstIndex(of: .sizeOffer) ?? 0
            (cell as? SizeOffersCollectionViewCell)?.setCellInfo(sizeOfferViewModel[indexPath.row - firstIndex], delegate: self.delegate)
        }
        return cell ?? UICollectionViewCell()
    }
}

extension GlobalPositionCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard dataSource.count != 1  else {
            let inset = Insets.defaultInset * 2
            return CGSize(width: UIScreen.main.bounds.width - inset, height: collectionView.frame.size.height)
        }
        let widthPerItem = self.widthPerItem()
        return CGSize(width: widthPerItem, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = self.dataSource.count > 1 ? Insets.defaultInset * 2: Insets.defaultInset
        return UIEdgeInsets(top: 0,
                            left: insets,
                            bottom: 0,
                            right: insets)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Insets.defaultInset
    }
}

extension GlobalPositionCollectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        switch type {
        case .timeline:
            delegate?.timelineSelected()
        case .timelineOffer:
            delegate?.timelineOfferSelected()
        case .pregrantedLoans:
            break
        case .sizeOffer:
            break
        }
    }
}

extension GlobalPositionCollectionController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int(self.currentPage(scrollView))
        delegate?.didScrollTo(index: currentIndex)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard self.dataSource.count > 1 else { return }
        let itemWidth: CGFloat = self.widthPerItem()
        let pageWidht: CGFloat = itemWidth + Insets.defaultInset * 2
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = CGFloat(targetContentOffset.pointee.x)
        var newTargetOffset: CGFloat = 0.0
        let page: CGFloat
        if targetOffset > currentOffset {
            page = CGFloat(ceilf(Float(currentOffset / pageWidht)))
        } else {
            page = CGFloat(floorf(Float(currentOffset / pageWidht)))
        }
        newTargetOffset =  page * ( itemWidth + Insets.defaultInset )
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if newTargetOffset > scrollView.contentSize.width {
            newTargetOffset = scrollView.contentSize.width
        }
        targetContentOffset.pointee = CGPoint(x: newTargetOffset, y: 0.0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didEndedScroll()
    }
}
