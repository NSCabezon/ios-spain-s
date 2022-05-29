//
//  PGSimpleTableViewController.swift
//  GlobalPosition
//
//  Created by alvola on 14/10/2019.
//

import Foundation
import CoreFoundationLib
import OfferCarousel

protocol RoundedCellProtocol {
    func roundCorners()
    func roundTopCorners()
    func roundBottomCorners()
    func removeCorners()
    func onlySideFrame()
}

protocol SeparatorCellProtocol {
    func hideSeparator(_ hide: Bool)
}

protocol DiscretePGCellProtocol {
    func setDiscreteModeEnabled(_ enabled: Bool)
}

protocol PGSimpleTableViewControllerDelegate: AnyObject {
    func didSelectPullOffer(_ info: ExpirableOfferEntity)
    func didSelectInfo(_ info: ElementEntity?)
    func didSelectPullOffer(_ info: PullOfferCompleteInfo)
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?)
    func didClosePullOffer(_ pullOffer: Any)
    func resizePullOffer(_ pullOffer: Any, to height: CGFloat)
    func activateCard(_ card: Any)
    func turnOnCard(_ card: Any)
    func switchFilterHeader(_ idx: Int)
    func didPressConfigureGP()
    func didPressAvios()
    func filterDidSelect(_ filter: PGInterventionFilter)
    func didScroll()
}

private extension PGSimpleTableViewController {
    enum Constants {
        static let aviosBannerCell = "SimpleGPAviosBannerContainerTableViewCell"
    }
}

final class PGSimpleTableViewController: NSObject, PullOfferTableViewCellDelegate, CardProductTableViewCellDelegate {
    
    // MARK: - Attributes
    
    weak var controlledTableView: UITableView?
    weak var headerHeight: NSLayoutConstraint?
    weak var header: UIView?
    var maxHeight: CGFloat = 239.0
    private let minHeight: CGFloat = 155
    private let footerSectionHeight: CGFloat = 16.0
    private var lastDif: CGFloat = 0.0
    private let dependenciesResolver: DependenciesResolver
    var cellsInfo: [[PGCellInfo]] = []
    var isLoadingView: Bool = true
    var discreteModeEnabled: Bool = false
    weak var delegate: PGSimpleTableViewControllerDelegate?
    private let semaphore = DispatchSemaphore(value: 1)
    private let supportedCells = [
        "CardProductTableViewCell",
        "GeneralProductTableViewCell",
        "OldGeneralProductTableViewCell",
        "MovementsNoticesTableViewCell",
        "MovementTableViewCell",
        "OfferTableViewCell",
        "InterventionFilterHeaderTableViewCell",
        "InterventionFilterOptionTableViewCell",
        "NoResultsTableViewCell",
        "ConfigureYourGPTableViewCell",
        Constants.aviosBannerCell
    ]
    private var isTopCarouselInitialized = false
    private let isMoneyVisible: Bool
    private let isConfigureWhatYouSeeVisible: Bool
    private let yourMoneyViewHeight: CGFloat = 67

    // MARK: - Initializers

    init(tableView: UITableView?,
         header: UIView?,
         headerHeight: NSLayoutConstraint?,
         dependenciesResolver: DependenciesResolver,
         isMoneyVisible: Bool,
         isConfigureWhatYouSeeVisible: Bool) {
        self.dependenciesResolver = dependenciesResolver
        self.isMoneyVisible = isMoneyVisible
        self.isConfigureWhatYouSeeVisible = isConfigureWhatYouSeeVisible
        super.init()
        self.controlledTableView = tableView
        self.headerHeight = headerHeight
        self.header = header
        self.header?.drawShadow(offset: (x: 0, y: -1), opacity: 0, color: .coolGray, radius: 2)
        registerCells()
        tableView?.delegate = self
        tableView?.dataSource = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanHeader(_:)))
        panGesture.delegate = self
        self.header?.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Public methods
    
    func reloadAllTable() {
        semaphore.wait()
        self.isTopCarouselInitialized = false
        controlledTableView?.reloadData()
        semaphore.signal()
    }
    
    func insertInSection(_ sec: Int) {
        guard validSectionIndex(sec) else { return }
        semaphore.wait()
        controlledTableView?.beginUpdates()
        controlledTableView?.reloadSections(IndexSet(integer: sec), with: .automatic)
        controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func insertSection(at index: Int) {
        semaphore.wait()
        self.controlledTableView?.beginUpdates()
        self.controlledTableView?.insertSections(IndexSet(integer: index), with: .automatic)
        self.controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func deleteSection(at index: Int) {
        guard validSectionIndex(index) else { return }
        semaphore.wait()
        self.controlledTableView?.beginUpdates()
        self.controlledTableView?.deleteSections(IndexSet(integer: index), with: .none)
        self.controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func scrollToTop() {
        scrollTo(0)
        headerHeight?.constant = maxHeight
    }
    
    func scrollTo(_ sec: Int, at pos: UITableView.ScrollPosition = .top) {
        guard validSectionIndex(sec) else { return }
        controlledTableView?.scrollToRow(at: IndexPath(row: NSNotFound, section: sec), at: pos, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellsInfo.count
    }
    
    @objc func didPanHeader(_ sender: UIPanGestureRecognizer) {
        guard let header = header, let currentHeight = headerHeight?.constant else {
            return
        }
        let translation = sender.translation(in: header)
        
        let newValue = currentHeight + translation.y
        
        headerHeight?.constant = min(maxHeight, max(minHeight, newValue))
        header.layer.shadowRadius = (((headerHeight?.constant ?? 0.0) - minHeight) / (maxHeight - minHeight)) * 2.0
        header.layer.shadowRadius = min(2.0, max(0.0, 2.0 - header.layer.shadowRadius))
        sender.setTranslation(.zero, in: header)
    }
    
    // MARK: - privateMethods
    
    private func registerCells() {
        supportedCells.forEach {
            controlledTableView?.register(UINib(nibName: $0, bundle: Bundle(for: PGSimpleViewController.self)), forCellReuseIdentifier: $0)
        }
        // Register OfferCarousel cell from outside Bundle
        self.controlledTableView?.register(UINib(nibName: "OfferCarouselTableViewCell", bundle: BundleHelper.bundle), forCellReuseIdentifier: "OfferCarouselTableViewCell")

    }
    
    private func validSectionIndex(_ index: Int) -> Bool {
        guard let numberOfSections = controlledTableView?.numberOfSections else { return false }
        return index < numberOfSections
    }
    
    private func setAccessibilityLabel(_ cell: UITableViewCell, _ tableView: UITableView, _ indexPath: IndexPath) {
        if (cell as? GeneralPGCellProtocol != nil || cell as? CardProductTableViewCellProtocol != nil) && (cell as? BookmarkPGCellProtocol == nil) {
            let rows = String(tableView.numberOfSections)
            let indx = String(indexPath.section + 1)
            let label = localized("voiceover_position", [StringPlaceholder(.number, indx), StringPlaceholder(.number, rows)]).text
            cell.accessibilityLabel = label
        }
    }
    
    // MARK: - PullOfferTableViewCellDelegate methods
    
    func pullOfferCloseDidPressed(_ elem: Any?) {
        guard let elem = elem else { return }
        delegate?.didClosePullOffer(elem)
    }
    
    func pullOfferResizeTo(_ size: CGFloat, _ elem: Any?) {
        guard let elem = elem else { return }
        delegate?.resizePullOffer(elem, to: size)
    }
    
    // MARK: - CardProductTableViewCellDelegate methods
    
    func activateCard(_ card: Any?) {
        guard let card = card else { return }
        delegate?.activateCard(card)
    }

    func turnOnCard(_ card: Any?) {
        guard let card = card else { return }
        delegate?.turnOnCard(card)
    }
}

// MARK: - UITableViewDelegateDataSource
extension PGSimpleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsInfo[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = cellsInfo[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.cellClass, for: indexPath)
        (cell as? OfferCarouselTableViewCellProtocol)?.topCarouselInit(
            delegate: self,
            dependenciesResolver: self.dependenciesResolver,
            gpType: GlobalPositionConstants.simplePgType
        )
        if !self.isTopCarouselInitialized {
            (cell as? OfferCarouselTableViewCellProtocol)?.resetNextIndex()
        }
        (cell as? OfferCarouselTableViewCellProtocol)?.setCellInfo(cellInfo.info as? OfferCarouselViewModel)
        (cell as? PullOfferCellProtocol)?.setCellDelegate(self)
        (cell as? GeneralPGCellProtocol)?.setCellInfo(cellInfo.info)
        (cell as? PullOfferCellProtocol)?.hideFrame(true)
        (cell as? CardProductTableViewCellProtocol)?.setCellDelegate(self)
        (cell as? InterventionFilterOptionTableViewCellProtocol)?.delegate = self
        (cell as? DiscretePGCellProtocol)?.setDiscreteModeEnabled(discreteModeEnabled)
        cell.layoutIfNeeded()
        if let roundedCell = cell as? RoundedCellProtocol {
            let isFirst = indexPath.row == 0
            let isLast = cellsInfo[indexPath.section].count == (indexPath.row + 1)
            switch (isFirst, isLast) {
            case (true, true):
                roundedCell.roundCorners()
            case (true, false):
                roundedCell.roundTopCorners()
            case (false, true):
                roundedCell.roundBottomCorners()
            case (false, false):
                roundedCell.onlySideFrame()
            }
            cell.setNeedsDisplay()
        }
        self.setAccessibility { self.setAccessibilityLabel(cell, tableView, indexPath) }
        self.isTopCarouselInitialized = true
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension PGSimpleTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isConfigureWhatYouSeeVisible {
            return section >= cellsInfo.count - 2 ? 0 : footerSectionHeight
        }
        return footerSectionHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellsInfo[indexPath.section][indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if isConfigureWhatYouSeeVisible {
            return section >= cellsInfo.count - 2 ? 0 : footerSectionHeight
        }
        return footerSectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let info = cellsInfo[indexPath.section][indexPath.row].info {
            if let general = info as? ElementEntity {
                delegate?.didSelectInfo(general)
            } else if let offer = (info as? CarouselOfferViewModel)?.elem as? PullOfferCompleteInfo {
                delegate?.didSelectPullOffer(offer)
            } else if info as? PGInterventionFilterModel != nil, indexPath.row == 0 {
                delegate?.switchFilterHeader(indexPath.section)
            } else if let pregranted = (info as? PregrantedBannerViewModel)?.expirableOfferEntity {
                delegate?.didSelectPregrantedBanner(pregranted)
            }
        } else if cellsInfo[indexPath.section][indexPath.row].cellClass == "ConfigureYourGPTableViewCell" {
            self.controlledTableView?.blockingAction {
                delegate?.didPressConfigureGP()
            }
        } else if cellsInfo[indexPath.section][indexPath.row].cellClass == Constants.aviosBannerCell {
            self.controlledTableView?.blockingAction {
                delegate?.didPressAvios()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header?.layer.shadowOpacity = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
        if self.cellsInfo.count == 0 { return }
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            let newValue = ((headerHeight?.constant ?? 0.0) - footerSectionHeight) - (scrollView.contentOffset.y)
            let heightCorrection: CGFloat = isMoneyVisible ? 0 : yourMoneyViewHeight
            guard headerHeight?.constant != maxHeight || (scrollView.contentSize.height + heightCorrection) > scrollView.frame.height else { return }
            
            headerHeight?.constant = min(maxHeight, max(minHeight, newValue))
            
            var scrollViewHeight: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            if #available(iOS 11, *) {
                scrollViewHeight += (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            }
            if scrollView.contentOffset.y > scrollViewHeight && scrollView.contentOffset != CGPoint.zero {
                guard scrollView.contentSize.height > scrollView.frame.height else { return }
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollViewHeight)
            }
        }
        delegate?.didScroll()
    }
}

extension PGSimpleTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PGSimpleTableViewController: InterventionFilterOptionTableViewCellDelegate {
    func didSelectFilter(_ filter: PGInterventionFilter) {
        delegate?.filterDidSelect(filter)
    }
}

extension PGSimpleTableViewController: OfferCarouselTableViewCellDelegate {
    var enableSwipeTracking: Bool { true }

    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        delegate?.didSelectPregrantedBanner(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        delegate?.didSelectPullOffer(info)
    }

    func getPage() -> String {
        GlobalPositionConstants.carouselPageName
    }
    
    func getIdentifiers() -> [String: String] {
        ["carousel": "pgCarouselPullOffer",
         "pregranted": "pgCarouselPullOfferPregranted",
         "pullOffer": "pgCarouselPullOfferPGTopOffer"]
    }
}

extension PGSimpleTableViewController: AccessibilityCapable { }
