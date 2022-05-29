//
//  PGBookmarkTableViewCell.swift
//  toTest
//
//  Created by alvola on 28/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib

enum BookmarkImageType: String {
    case timeline
    case pregrantedLoans
    case timelineOffer
    case sizeOffer
}

protocol PGBookmarkTableViewCellDelegate: AnyObject {
    func didSelectTimeLine()
    func didSelectTimeLineOffer()
    func didSelectedSizeOffer(_ offer: OfferEntity)
    func didEndedScroll()
    func circularSliderDidStart()
    func circularSliderDidStop()
}

protocol BookmarkPGCellProtocol {
    func setDelegate(_ delegate: PGBookmarkTableViewCellDelegate)
}

enum PGBookmarkTimelineTypeViewModel {
    case timeline
    case offer(url: String?)
}

struct PGBookmarkTableViewModel {
    let resolver: DependenciesResolver
    let timelineType: PGBookmarkTimelineTypeViewModel
    let loanViewModel: LoanSimulatorViewModel?
    let sizeOfferViewModel: [SizeOfferViewModel]
}

final class PGBookmarkTableViewCell: UITableViewCell, GeneralPGCellProtocol {
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBAction private func pageControlValueChanged(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }
    
    private weak var delegate: PGBookmarkTableViewCellDelegate?
    private var collectionController: GlobalPositionCollectionController?

    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGBookmarkTableViewModel,
              let collectionController = collectionController
        else { return }
        collectionController.updateInfo(info)
        configurePageControl(with: collectionController.itemsCount)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        collectionController = GlobalPositionCollectionController(collectionView: collectionView,
                                                    delegate: self,
                                                    loanDelegate: self)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.skyGray
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        setAccessibility(setViewAccessibility: self.setAccessibility)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 480)
    }
    
    func scrollToPregrantedLoans() {
        collectionController?.scrollToPregrantedLoans()
    }
}

private extension PGBookmarkTableViewCell {
    func configurePageControl(with itemsCount: Int) {
        pageControl.numberOfPages = itemsCount
        pageControl.isHidden = itemsCount <= 1
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.silverDark
        pageControl.currentPageIndicatorTintColor = UIColor.botonRedLight
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
    
    func setAccessibility() {
        self.accessibilityElements = [self.collectionView, self.pageControl]
    }
}

extension PGBookmarkTableViewCell: BookmarkPGCellProtocol {
    func setDelegate(_ delegate: PGBookmarkTableViewCellDelegate) {
        self.delegate = delegate
    }
}

extension PGBookmarkTableViewCell: LoanSimulatorCollectionViewCellProtocol {
    func circularSliderDidStart() {
        delegate?.circularSliderDidStart()
        collectionView.isScrollEnabled = false
    }
    
    func circularSliderDidStop() {
        delegate?.circularSliderDidStop()
        collectionView.isScrollEnabled = true
    }
}

extension PGBookmarkTableViewCell: CollectionControllerDelegate {
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
    
    func didEndedScroll() {
        delegate?.didEndedScroll()
    }
}

extension PGBookmarkTableViewCell: AccessibilityCapable { }
