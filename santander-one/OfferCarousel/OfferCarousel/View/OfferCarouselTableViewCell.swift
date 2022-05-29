//
//  OfferCarouselTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 08/02/2021.
//

import UIKit
import UI
import CoreFoundationLib

public protocol OfferCarouselTableViewCellDelegate: class {
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?)
    func didSelectPullOffer(_ info: ExpirableOfferEntity)
    func getPage() -> String
    func getIdentifiers() -> [String: String]
    var enableSwipeTracking: Bool { get }
}

public protocol OfferCarouselTableViewCellProtocol {
    func topCarouselInit(delegate: OfferCarouselTableViewCellDelegate, dependenciesResolver: DependenciesResolver, gpType: String)
    func reduceIndex()
    func resetNextIndex()
    func setCellInfo(_ viewModel: OfferCarouselViewModel?)
}

final class OfferCarouselTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var leftScrollButton: UIButton!
    @IBOutlet private weak var rightScrollButton: UIButton!
    
    // MARK: - Attributes
    
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    weak var delegate: OfferCarouselTableViewCellDelegate?
    var dependenciesResolver: DependenciesResolver?
    var gpType: String = ""
    private var cells: [OfferCarouselViewModelType] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    private lazy var nextIdx: IndexPath = {
        return IndexPath(row: self.cells.count * self.cellsMultiplier, section: 0)
    }() {
        didSet {
            if nextIdx.row < 0 {
                nextIdx.row = 0
            }}
    }
    private let cellsMultiplier = 100
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 48)
    }
    
    // MARK: - Actions
    
    @IBAction func scrollToLeft(_ sender: Any) {
        guard let min = collectionView.indexPathsForVisibleItems.min() else { return }
        self.collectionView.scrollToItem(at: min, at: .centeredHorizontally, animated: true)
        updateNextIndex(IndexPath(row: min.row + 1, section: min.section))
    }
    
    @IBAction func scrollToRight(_ sender: Any) {
        guard let max = collectionView.indexPathsForVisibleItems.max() else { return }
        self.collectionView.scrollToItem(at: max, at: .centeredHorizontally, animated: true)
        updateNextIndex(IndexPath(row: max.row + 1, section: max.section))
    }
}

private extension OfferCarouselTableViewCell {
    func commonInit() {
        self.configureView()
        self.configureCollectionView()
        self.setAccessibilityIds()
    }
    
    func configureView() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configureCollectionView() {
        self.collectionView?.register(UINib(nibName: "PregrantedOfferCollectionViewCell",
                                       bundle: BundleHelper.bundle),
                                 forCellWithReuseIdentifier: "PregrantedOfferCollectionViewCell")
        self.collectionView?.register(UINib(nibName: "CarouselOfferCollectionViewCell",
                                       bundle: BundleHelper.bundle),
                                 forCellWithReuseIdentifier: "CarouselOfferCollectionViewCell")
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.clipsToBounds = false
        self.collectionView?.decelerationRate = .fast
        self.addLayout()
    }
    
    func addLayout() {
        self.layout.setItemSize(CGSize(width: UIScreen.main.bounds.size.width - 32,
                                  height: 40.0))
        self.layout.setMinimumLineSpacing(6)
        self.layout.setZoom(0)
        self.collectionView?.collectionViewLayout = layout
    }
    
    func autoscroll() {
        guard self.nextIdx.section < self.collectionView.numberOfSections,
              self.nextIdx.row < self.collectionView.numberOfItems(inSection: self.nextIdx.section) else { return }
        self.collectionView.scrollToItem(at: self.nextIdx,
                                         at: .centeredHorizontally,
                                         animated: true)
        self.updateNextIndex(nextIdx)
    }
    
    func updateNextIndex(_ idx: IndexPath) {
        self.nextIdx.row = idx.row + 1
    }
    
    func removeOfferAt(_ index: Int) {
        if index == self.cells.count - 1 {
            self.nextIdx = IndexPath(row: 0, section: 0)
        }
        self.reduceIndex()
        let idToRemove: String?
        let cell = self.cells[index % self.cells.count]
        switch cell {
        case let .pregranted(viewModel):
            idToRemove = viewModel.expirableOfferEntity?.id
        case let .offer(viewModel):
            idToRemove = (viewModel.elem as? ExpirableOfferEntity)?.id
        }
        self.filterOffersWithOfferId(idToRemove)
    }
    
    func filterOffersWithOfferId(_ offerToRemove: String?) {
        self.cells = self.cells.filter {
            switch $0 {
            case let .pregranted(viewModel):
                return viewModel.expirableOfferEntity?.id != offerToRemove
            case let .offer(viewModel):
                guard let offerId = (viewModel.elem as? ExpirableOfferEntity)?.id else {
                    return false
                }
                return offerId != offerToRemove
            }
        }
    }
    
    func fullyVisibleCells() -> [IndexPath] {
        return self.collectionView.visibleCells
            .lazy
            .filter({ cell in
                let cellRect = self.collectionView.convert(cell.frame, to: self.collectionView.superview)
                return self.collectionView.frame.contains(cellRect)
            })
            .compactMap {
                guard let idx = self.collectionView.indexPath(for: $0) else { return nil }
                return idx
            }
    }
    
    func trackEventWithCell(_ action: OfferCarouselPage.Action, cell: OfferCarouselViewModelType) {
        switch cell {
        case let .pregranted(viewModel):
            self.trackEvent(action, parameters: ["tipo_pg": self.gpType, "id_oferta": viewModel.expirableOfferEntity?.id ?? ""])
        case let .offer(viewModel):
            guard let offer = viewModel.elem as? ExpirableOfferEntity else { return }
            self.trackEvent(action, parameters: ["tipo_pg": self.gpType, "id_oferta": offer.id ?? ""])
        }
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = "gpCarouselViewItem"
        self.contentView.isAccessibilityElement = true
        accessibilityElements = [contentView, leftScrollButton, rightScrollButton]
        leftScrollButton.accessibilityIdentifier = "gpCarouselPreviousOffer"
        rightScrollButton.accessibilityIdentifier = "gpCarouselNextOffer"
    }
}

extension OfferCarouselTableViewCell: (UICollectionViewDataSource &
                                       UICollectionViewDelegate &
                                       UICollectionViewDelegateFlowLayout) {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.cells.count > 1 {
            return Int(Int16.max)
        } else {
            return self.cells.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch self.cells[indexPath.row % self.cells.count] {
        case let .pregranted(viewModel):
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PregrantedOfferCollectionViewCell", for: indexPath)
            (cell as? PregrantedOfferCollectionViewCell)?.viewIdentifier = self.delegate?.getIdentifiers()["pregranted"] ?? ""
            (cell as? PregrantedOfferCollectionViewCell)?.setViewModel(viewModel)
        case let .offer(viewModel):
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselOfferCollectionViewCell", for: indexPath)
            (cell as? CarouselOfferCollectionViewCell)?.viewIdentifier = self.delegate?.getIdentifiers()["pullOffer"] ?? ""
            (cell as? CarouselOfferCollectionViewCell)?.setOffer(viewModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.cells[indexPath.row % self.cells.count]
        self.trackEventWithCell(.selectContent, cell: cell)
        switch cell {
        case let .pregranted(viewModel):
            if viewModel.expirableOfferEntity?.expiresOnClick ?? false {
                self.removeOfferAt(indexPath.row)
            }
            self.delegate?.didSelectPregrantedBanner(viewModel.expirableOfferEntity)
        case let .offer(viewModel):
            guard let offer = viewModel.elem as? ExpirableOfferEntity else { return }
            self.delegate?.didSelectPullOffer(offer)
            if offer.expiresOnClick {
                self.removeOfferAt(indexPath.row)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let focused = self.fullyVisibleCells().first else { return }
        self.updateNextIndex(focused)
        if self.delegate?.enableSwipeTracking ?? false {
            self.trackEvent(.swipe, parameters: ["tipo_pg": self.gpType])
        }
        self.trackEventWithCell(.viewPromotion, cell: self.cells[focused.row % self.cells.count])
    }
}

extension OfferCarouselTableViewCell: OfferCarouselTableViewCellProtocol {
    func topCarouselInit(delegate: OfferCarouselTableViewCellDelegate, dependenciesResolver: DependenciesResolver, gpType: String) {
        self.delegate = delegate
        self.dependenciesResolver = dependenciesResolver
        self.gpType = gpType
        self.accessibilityIdentifier = self.delegate?.getIdentifiers()["carousel"] ?? "pgCarouselPullOffer"
    }
    
    func reduceIndex() {
        self.nextIdx.row = max(self.nextIdx.row - 1, 0)
    }
    
    func resetNextIndex() {
        guard self.cells.count > 1 else { return }
        self.nextIdx = IndexPath(row: self.cells.count * self.cellsMultiplier, section: 0)
        self.collectionView.scrollToItem(at: self.nextIdx,
                                         at: .centeredHorizontally,
                                         animated: false)
    }
    
    func setCellInfo(_ viewModel: OfferCarouselViewModel?) {
        guard let viewModel = viewModel else { return }
        let prevElemsNum = self.cells.count
        self.cells = viewModel.elems
        self.trackEventWithCell(.viewPromotion, cell: self.cells[0])
        guard self.cells.count > 1 else { return }
        guard prevElemsNum == self.cells.count else {
            let currentIndexPath = IndexPath(row: self.cells.count * self.cellsMultiplier, section: 0)
            self.nextIdx = currentIndexPath
            self.collectionView.scrollToItem(
                at: currentIndexPath,
                at: .centeredHorizontally,
                animated: false)
            return
        }
        self.autoscroll()
    }
}

extension OfferCarouselTableViewCell: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver!.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: OfferCarouselPage {
        return OfferCarouselPage(page: self.delegate?.getPage() ?? "")
    }
}
