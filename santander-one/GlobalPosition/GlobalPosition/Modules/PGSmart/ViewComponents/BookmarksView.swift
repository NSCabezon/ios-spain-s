//
//  TimeLineView.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 20/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class BookmarksView: DesignableView, GeneralPGCellProtocol {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    private weak var delegate: PGBookmarkTableViewCellDelegate?
    private var collectionController: GlobalPositionCollectionController?
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGBookmarkTableViewModel,
              let collectionController = collectionController
        else { return }
        collectionController.updateInfo(info)
        configurePageControl(with: collectionController.itemsCount)
    }
    
    override func commonInit() {
        super.commonInit()
        collectionController = GlobalPositionCollectionController(
            collectionView: collectionView,
            delegate: self,
            loanDelegate: self
        )
        backgroundColor = .lightGray40
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 480)
    }
}

private extension BookmarksView {
    func configurePageControl(with itemsCount: Int) {
        pageControl.hidesForSinglePage = true
        pageControl.isHidden = itemsCount <= 1
        pageControl.numberOfPages = itemsCount
        pageControl.pageIndicatorTintColor = .silverDark
        pageControl.currentPageIndicatorTintColor = .botonRedLight
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
}

extension BookmarksView: BookmarkPGCellProtocol {
    func setDelegate(_ delegate: PGBookmarkTableViewCellDelegate) {
        self.delegate = delegate
    }
}

extension BookmarksView: LoanSimulatorCollectionViewCellProtocol {
    func circularSliderDidStart() {
        collectionView.isScrollEnabled = false
        delegate?.circularSliderDidStart()
    }
    
    func circularSliderDidStop() {
        collectionView.isScrollEnabled = true
        delegate?.circularSliderDidStop()
    }
}

extension BookmarksView: CollectionControllerDelegate {
    func didEndedScroll() {
        delegate?.didEndedScroll()
    }
    
    func timelineSelected() {
        delegate?.didSelectTimeLine()
    }
    
    func timelineOfferSelected() {
        delegate?.didSelectTimeLineOffer()
    }
    
    func didSelectedSizeOffer(_ offer: OfferEntity) {
        delegate?.didSelectedSizeOffer(offer)
    }
    
    func didScrollTo(index: Int) {
        pageControl.currentPage = index
    }
}
