//
//  PGClassicTableViewController.swift
//  GlobalPosition
//
//  Created by alvola on 28/10/2019.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib
import OfferCarousel
import CoreDomain

protocol PGClassicTableViewControllerDelegate: PGSimpleTableViewControllerDelegate {
    func didSelectSection(_ type: ProductTypeEntity, idx: Int?)
    func newShippmentDidPress()
    func newFavContactDidPress()
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel)
    func didTapInHistoricSendMoney()
    func switchFilterHeader(_ idx: Int)
    func filterDidSelect(_ filter: PGInterventionFilter)
    func didPressConfigureGP()
    func didPressAvios()
    func didSelectTimeLine()
    func didSelectTimeLineOffer()
    func didEndedPGBookmarkScroll()
    func didSelectedSizeOffer(_ offer: OfferEntity)
}

protocol PGReapearActionProtocol {
    func appearAction()
}

private extension PGClassicTableViewController {
    enum Constants {
        static let aviosBannerCell = "ClassicGPAviosBannerContainerTableViewCell"
        static let configureYourGPTCell = "ConfigureYourGPTableViewCell"
    }
}

final class PGClassicTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource, PGGeneralHeaderViewDelegate, PullOfferTableViewCellDelegate, CardProductTableViewCellDelegate {

    // MARK: - Attributes
    
    private let dependenciesResolver: DependenciesResolver
    weak var controlledTableView: UITableView?
    weak var shadowTopView: UIView?
    var discreteModeEnabled: Bool = false
    var cellsInfo: [PGClassicTableViewCellInfo] = []
    private var onePayCollectionInfo: [OnePayCollectionInfo] = []
    private let correctedIndex: Int = 1
    weak var delegate: PGClassicTableViewControllerDelegate?
    weak var pullOffersDelegate: PTDeeplinkVerifierProtocol? {
        return dependenciesResolver.resolve(forOptionalType: PTDeeplinkVerifierProtocol.self)
    }
    private let semaphore = DispatchSemaphore(value: 1)
    private let supportedCells = [
        "ClassicCardProductCell",
        "ClassicGeneralProductTableViewCell",
        "OfferTableViewCell",
        "PGBookmarkTableViewCell",
        "OnePayTableViewCell",
        "FutureLoadingCollectionViewCell",
        "CardsFooterTableViewCell",
        "PGClassicFooterTableViewCell",
        "InterventionFilterHeaderTableViewCell",
        "InterventionFilterOptionTableViewCell",
        "NoResultsTableViewCell",
        "PgSpaceTableViewCell",
        "ConfigureYourGPTableViewCell",
        Constants.aviosBannerCell
    ]
    private var isTopCarouselInitialized = false
    
    // MARK: - Initializers
    
    init(tableView: UITableView?, shadowTopView: UIView?, dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
        self.controlledTableView = tableView
        self.shadowTopView = shadowTopView
        registerCells()
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    // MARK: - Life cycle

    func viewWillAppear() {
        self.controlledTableView?.visibleCells.forEach({
            ($0 as? PGReapearActionProtocol)?.appearAction()
        })
    }
    
    func setOnePayCollectionInfo(_ dataList: [OnePayCollectionInfo]) {
        guard !dataList.isEmpty else { return }
        self.onePayCollectionInfo = dataList
    }
    
    func removeFavouriteCarousel(_ section: Int) {
        self.cellsInfo.enumerated().forEach { index, item in
            item.cellInfos.forEach { itemInfo in
                if itemInfo.cellClass == "OnePayTableViewCell" {
                    self.cellsInfo.remove(at: index)
                }
            }
        }
        self.deleteSection(at: section)
    }
    
    func reloadAllTable() {
        UIView.performWithoutAnimation {
            self.isTopCarouselInitialized = false
            controlledTableView?.reloadData()
            checkBubbleIsLastPosition()
        }   
    }
    
    func collapseSection(_ sec: Int) {
        semaphore.wait()
        controlledTableView?.beginUpdates()
        refreshHeaderOf(sec)
        refreshFooterOf(sec)
        collapseActionsForSection(sec)
        controlledTableView?.reloadSections(IndexSet(arrayLiteral: sec), with: .automatic)
        controlledTableView?.endUpdates()
        controlledTableView?.scrollToRow(at: IndexPath(row: NSNotFound, section: sec), at: .none, animated: false)
        semaphore.signal()
    }
    
    func insertSection(at index: Int) {
        self.controlledTableView?.beginUpdates()
        self.controlledTableView?.insertSections(IndexSet(integer: index), with: .automatic)
        self.controlledTableView?.endUpdates()
    }
    
    func deleteSection(at index: Int) {
        semaphore.wait()
        self.controlledTableView?.beginUpdates()
        self.controlledTableView?.deleteSections(IndexSet(integer: index), with: .none)
        self.controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func expandSection(_ sec: Int) {
        semaphore.wait()
        controlledTableView?.beginUpdates()
        refreshHeaderOf(sec)
        refreshFooterOf(sec)
        expandActionsForSection(sec)
        controlledTableView?.endUpdates()
        controlledTableView?.scrollToRow(at: IndexPath(row: NSNotFound, section: sec), at: .none, animated: false)
        semaphore.signal()
    }
    
    func expandFilter(_ sec: Int) {
        semaphore.wait()
        controlledTableView?.beginUpdates()
        controlledTableView?.insertRows(at: (1..<cellsInfo[sec].cellInfos.count).map { IndexPath(row: $0, section: sec)}, with: .automatic)
        controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func collapseFilter(_ sec: Int) {
        semaphore.wait()
        controlledTableView?.beginUpdates()
        if let cellsNum = controlledTableView?.numberOfRows(inSection: sec) {
            controlledTableView?.deleteRows(at: (1...(cellsNum - 1)).map { IndexPath(row: $0, section: sec)}, with: .fade)
        }
        controlledTableView?.endUpdates()
        semaphore.signal()
    }
    
    func reload(_ sections: Set<Int>, with animation: UITableView.RowAnimation = .automatic) {
        UIView.performWithoutAnimation {
            semaphore.wait()
            controlledTableView?.beginUpdates()
            controlledTableView?.reloadSections(IndexSet(sections), with: animation)
            controlledTableView?.endUpdates()
            semaphore.signal()
        }
    }
    
    func reloadRows(_ indexPaths: [IndexPath]) {
        guard let visibleCells = controlledTableView?.indexPathsForVisibleRows else { return }
        controlledTableView?.beginUpdates()
        indexPaths
            .filter({visibleCells.contains($0)})
            .forEach {
                let modifyIndexPath = modify($0)
                let cell = controlledTableView?.cellForRow(at: modifyIndexPath) as? GeneralPGCellProtocol
                let info = cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].info
                cell?.setCellInfo(info)
            }
        controlledTableView?.endUpdates()
    }
    
    func scrollToTop() {
        controlledTableView?.contentOffset = .zero
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellsInfo.count
    }
    
    func isValidIndex(_ sec: Int, _ row: Int) -> Bool {
        guard let table = controlledTableView else { return false }
        return sec < table.numberOfSections && row < table.numberOfRows(inSection: sec)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < cellsInfo.count else { return 0 }
        let numberOfCells = self.isOpenProduct(section) ? cellsInfo[section].cellInfos.count : 0
        return numberOfCells + self.numberOfFooter(section) + self.numberOfUnderCellOffer(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFooterCell(indexPath) {
            return footerCellForIndexPath(indexPath) ?? UITableViewCell()
        }
        if self.isUnderdcell(indexPath) {
            return offerCellForIndexPath(indexPath) ?? UITableViewCell()
        }
        let modifyIndexPath = modify(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].cellClass, for: modifyIndexPath)
        (cell as? PullOfferCellProtocol)?.setCellDelegate(self)
        (cell as? PullOfferCellProtocol)?.hideFrame(cellsInfo[modifyIndexPath.section].header == nil && cellsInfo[modifyIndexPath.section].footer == PGClassicFooter.none)
        (cell as? OfferCarouselTableViewCellProtocol)?.topCarouselInit(
            delegate: self,
            dependenciesResolver: self.dependenciesResolver,
            gpType: GlobalPositionConstants.classicPgType
        )
        if !self.isTopCarouselInitialized {
            (cell as? OfferCarouselTableViewCellProtocol)?.resetNextIndex()
        }
        (cell as? DiscretePGCellProtocol)?.setDiscreteModeEnabled(discreteModeEnabled)
        (cell as? OfferCarouselTableViewCellProtocol)?.setCellInfo(cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].info as? OfferCarouselViewModel)
        (cell as? GeneralPGCellProtocol)?.setCellInfo(cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].info)
        (cell as? CardProductTableViewCellProtocol)?.setCellDelegate(self)
        (cell as? SeparatorCellProtocol)?.hideSeparator(cellsInfo[modifyIndexPath.section].cellInfos.count == (modifyIndexPath.row + self.correctedIndex))
        (cell as? BookmarkPGCellProtocol)?.setDelegate(self)
        (cell as? InterventionFilterOptionTableViewCellProtocol)?.delegate = self
        (cell as? OnePayTableViewCellProtocol)?.setDelegate(self)

        if cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].cellClass == "FutureLoadingCollectionViewCell" {
            (cell as? OnePayTableViewCellProtocol)?.setLoadingView()
        } else if !onePayCollectionInfo.isEmpty {
            (cell as? OnePayTableViewCellProtocol)?.setFavouriteContactsList(onePayCollectionInfo)
        }
        if cellsInfo[modifyIndexPath.section].cellInfos.count == (modifyIndexPath.row + self.correctedIndex),
            !hasFoot(indexPath.section) {
            (cell as? RoundedCellProtocol)?.roundBottomCorners()
        }
        cell.layoutIfNeeded()
        self.setAccessibility { self.setAccessibilityLabel(cell, tableView, indexPath) }
        self.isTopCarouselInitialized = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        self.tableView(tableView, heightForFooterInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { nil }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < cellsInfo.count else { return 0.0 }
        return cellsInfo[section].header == nil ? 0.0 : 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let info = cellsInfo[section].header else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PGGeneralHeaderView")
        (header as? GeneralPGCellProtocol)?.setCellInfo(info)
        (header as? PGGeneralHeaderViewProtocol)?.setDelegate(self)
        (header as? PGGeneralHeaderViewProtocol)?.roundBottom(roundHeaderIn(section))
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let modifyIndexPath = modify(indexPath)
        let defaultCellHeight: CGFloat = 40
        guard indexPath.row != cellsInfo[indexPath.section].cellInfos.count else { return defaultCellHeight }
        guard self.isUnderdcell(indexPath), let bottomOfferCell = cellsInfo[modifyIndexPath.section].underCell else {
            let cellHeight = cellsInfo[modifyIndexPath.section].cellInfos[modifyIndexPath.row].cellHeight
            return cellHeight == 0 ? defaultCellHeight : cellHeight
        }
        return bottomOfferCell.cellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowTopView?.layer.shadowRadius = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
        ((scrollView as? UITableView)?.tableHeaderView as? TableViewHeaderScrollObserver)?.scrolls(scrollView.contentOffset.y)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Footer closed when collapsed
        guard !self.isFooterCellSelectable(indexPath) else {
            if let type = cellsInfo[indexPath.section].header?.productType {
                self.didSelect(type)
            }
            return
        }
        guard !self.isCellUnderCellSelected(indexPath) else {
            if let info = cellsInfo[indexPath.section].underCell?.info,
                let offer = (info as? CarouselOfferViewModel)?.elem as? PullOfferCompleteInfo {
                delegate?.didSelectPullOffer(offer)
            }
            return
        }
        if let info = cellsInfo[indexPath.section].cellInfos[indexPath.row].info {
            if let general = info as? ElementEntity {
                delegate?.didSelectInfo(general)
            } else if let offer = (info as? CarouselOfferViewModel)?.elem as? PullOfferCompleteInfo {
                delegate?.didSelectPullOffer(offer)
            } else if info as? PGInterventionFilterModel != nil, indexPath.row == 0 {
                delegate?.switchFilterHeader(indexPath.section)
            }
        } else if cellsInfo[indexPath.section].cellInfos[indexPath.row].cellClass == Constants.configureYourGPTCell {
            self.controlledTableView?.blockingAction {
                delegate?.didPressConfigureGP()
            }
        } else if cellsInfo[indexPath.section].cellInfos[indexPath.row].cellClass == Constants.aviosBannerCell {
            self.controlledTableView?.blockingAction {
                delegate?.didPressAvios()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (cellsInfo.count > indexPath.section && self.isCellSelectable(indexPath)) ? indexPath : nil
    }
    
    // MARK: - PGGeneralHeaderViewDelegate methods
    
    func didSelect(_ type: ProductTypeEntity) { delegate?.didSelectSection(type, idx: sectionIdxOf(type)) }
    
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

extension PGClassicTableViewController: OfferCarouselTableViewCellDelegate {
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

extension PGClassicTableViewController: OnePayCollectionViewControllerDelegate {
    func newShippmentPressed() {
        delegate?.newShippmentDidPress()
    }
    
    func newFavContactPressed() {
        delegate?.newFavContactDidPress()
    }
    
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel) {
        delegate?.didTapInFavContact(viewModel)
    }
    
    func didTapInHistoricSendMoney() {
        delegate?.didTapInHistoricSendMoney()
    }
}

extension PGClassicTableViewController: PGBookmarkTableViewCellDelegate {
    func didSelectTimeLineOffer() {
        self.delegate?.didSelectTimeLineOffer()
    }
    
    func didSelectTimeLine() {
        self.delegate?.didSelectTimeLine()
    }
    
    func didSelectedSizeOffer(_ offer: OfferEntity) {
        guard pullOffersDelegate != nil else {
            self.delegate?.didSelectedSizeOffer(offer)
            return
        }
        pullOffersDelegate?.verifyOffer(entity: offer, completion: { canContinue in
            if canContinue {
                self.delegate?.didSelectedSizeOffer(offer)
            }
        })
    }
    
    func circularSliderDidStart() {
        controlledTableView?.isScrollEnabled = false
    }
    
    func circularSliderDidStop() {
        controlledTableView?.isScrollEnabled = true
    }
    
    func didEndedScroll() {
        self.delegate?.didEndedPGBookmarkScroll()
    }
}

extension PGClassicTableViewController: InterventionFilterOptionTableViewCellDelegate {
    func didSelectFilter(_ filter: PGInterventionFilter) {
        delegate?.filterDidSelect(filter)
    }
}

private extension PGClassicTableViewController {
    func hasFoot(_ section: Int) -> Bool {
        return cellsInfo[section].hasFooter
    }
    func numberOfFooter(_ section: Int) -> Int {
        return hasFoot(section) ? 1 : 0
    }
    func hasUnderCellOffer(_ section: Int) -> Bool {
        return cellsInfo[section].underCell != nil
    }
    func numberOfUnderCellOffer(_ section: Int) -> Int {
        return hasUnderCellOffer(section) ? 1 : 0
    }
    func isOpenProduct(_ section: Int) -> Bool {
        return cellsInfo[section].header?.open ?? true
    }
    func isOfferCell(_ indexPath: IndexPath) -> Bool {
        return self.controlledTableView?.cellForRow(at: indexPath) is OfferTableViewCell
    }
    
    func setAccessibilityLabel(_ cell: UITableViewCell, _ tableView: UITableView, _ indexPath: IndexPath) {
        if (cell as? GeneralPGCellProtocol != nil || cell as? CardProductTableViewCellProtocol != nil) && (cell as? BookmarkPGCellProtocol == nil) {
            let rows = String(tableView.numberOfRows(inSection: indexPath.section))
            let indx = String(indexPath.row + 1)
            let label = localized("voiceover_position", [StringPlaceholder(.number, indx), StringPlaceholder(.number, rows)]).text
            cell.accessibilityLabel = label
        }
    }
    
    // MARK: Helper functions
    func collapseActionsForSection(_ sec: Int) {
        var numberOfCellsToDelete = cellsInfo[sec].cellInfos.count
        if case PGClassicFooter.onlyWhenClosed = cellsInfo[sec].footer {
            numberOfCellsToDelete -= 1
        } else if case PGClassicFooter.onlyWhenOpened = cellsInfo[sec].footer {
            numberOfCellsToDelete += 1
        }
        guard numberOfCellsToDelete >= 0 else { return }
        controlledTableView?.deleteRows(at: (0..<numberOfCellsToDelete).map { IndexPath(row: $0, section: sec)}, with: .bottom)
    }
    
    func expandActionsForSection(_ sec: Int) {
        var numberOfCellsToInsert = cellsInfo[sec].cellInfos.count
        if case PGClassicFooter.onlyWhenClosed = cellsInfo[sec].footer {
            numberOfCellsToInsert -= 1
        } else if case PGClassicFooter.onlyWhenOpened = cellsInfo[sec].footer {
            numberOfCellsToInsert += 1
        }
        guard numberOfCellsToInsert >= 0 else { return }
        controlledTableView?.insertRows(at: (0..<numberOfCellsToInsert).map { IndexPath(row: $0, section: sec)}, with: .bottom)
    }
    
    func refreshHeaderOf(_ sec: Int) {
        let header = controlledTableView?.headerView(forSection: sec)
        (header as? GeneralPGCellProtocol)?.setCellInfo(cellsInfo[sec].header)
        (header as? PGGeneralHeaderViewProtocol)?.roundBottom(roundHeaderIn(sec))
    }
    
    func refreshFooterOf(_ sec: Int) {
        guard let row = controlledTableView?.numberOfRows(inSection: sec) else { return }
        let cell = controlledTableView?.cellForRow(at: IndexPath(row: row - 1, section: sec))
        (cell as? SeparatorCellProtocol)?.hideSeparator(!(cellsInfo[sec].header?.open ?? false))
    }
    
    func modify(_ idxPath: IndexPath) -> IndexPath {
        return (cellsInfo[idxPath.section].header?.open ?? true) ? idxPath : IndexPath(row: cellsInfo[idxPath.section].cellInfos.count - 1, section: idxPath.section)
    }
    
    func roundHeaderIn(_ section: Int) -> Bool {
        return !self.hasFoot(section) && !(self.isOpenProduct(section))
    }
    
    func registerCells() {
        supportedCells.forEach {
            controlledTableView?.register(UINib(nibName: $0, bundle: Bundle(for: PGClassicViewController.self)), forCellReuseIdentifier: $0)
        }
        controlledTableView?.register(UINib(nibName: "PGGeneralHeaderView", bundle: Bundle(for: PGClassicViewController.self)), forHeaderFooterViewReuseIdentifier: "PGGeneralHeaderView")
        // Register OfferCarousel cell from outside Bundle
        controlledTableView?.register(UINib(nibName: "OfferCarouselTableViewCell", bundle: BundleHelper.bundle), forCellReuseIdentifier: "OfferCarouselTableViewCell")
    }
    
    func sectionIdxOf(_ type: ProductTypeEntity) -> Int? { return cellsInfo.firstIndex { $0.header?.productType == type } }
    
    // MARK: - Foot and UnderCell cells
    func footerCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
        var cell: UITableViewCell?
        if cellsInfo[indexPath.section].header?.productType == .card {
            cell = controlledTableView?.dequeueReusableCell(withIdentifier: "CardsFooterTableViewCell", for: indexPath)
            configureFooter(forCell: cell as? GeneralPGCellProtocol, inSection: indexPath.section, withFooter: cellsInfo[indexPath.section].footer)
        } else {
            cell = controlledTableView?.dequeueReusableCell(withIdentifier: "PGClassicFooterTableViewCell", for: indexPath)
            configureFooter(forCell: cell as? GeneralPGCellProtocol, inSection: indexPath.section, withFooter: cellsInfo[indexPath.section].footer)
            (cell as? DiscretePGCellProtocol)?.setDiscreteModeEnabled(discreteModeEnabled)
            (cell as? SeparatorCellProtocol)?.hideSeparator(!(cellsInfo[indexPath.section].header?.open ?? false))
        }
        if let type = cellsInfo[indexPath.section].header?.productType.rawValue {
            (cell as? PGClassicFooterTableViewCell)?.setAccessibilityIdentifier(identifier: type)
            (cell as? CardsFooterTableViewCell)?.setAccessibilityIdentifier(identifier: type)
        }
        cell?.layoutIfNeeded()
        return cell
    }
    
    func configureFooter(forCell cell: GeneralPGCellProtocol?, inSection section: Int, withFooter footer: PGClassicFooter) {
        var info: GeneralFooterInfo?
        switch footer {
        case .always(let newInfo):
            info = newInfo
        case .onlyWhenClosed(let newInfo):
            info = newInfo
        case .onlyWhenOpened(let newInfo):
            info = newInfo
        case .custom(let openInfo, let closedInfo):
            info = cellsInfo[section].header?.open ?? false ? openInfo: closedInfo
        case .none:
            break
        }
        cell?.setCellInfo(info)
    }
    
    func offerCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
        let cell = controlledTableView?.dequeueReusableCell(withIdentifier: "OfferTableViewCell", for: indexPath) as? OfferTableViewCell
        cell?.setCellDelegate(self)
        cell?.addMargintTop(8.0)
        cell?.setCellInfo(cellsInfo[indexPath.section].underCell?.info)
        cell?.hideFrame(true)
        return cell
    }
    
    // MARK: - Footer and UnderCell control
    func isFooterCell(_ indexPath: IndexPath) -> Bool {
        // Card has a different use
        guard hasFoot(indexPath.section) else { return false }
        let whenOpenedFooter = (indexPath.row == cellsInfo[indexPath.section].cellInfos.count) && self.isOpenProduct(indexPath.section)
        let whenClosedFooter = (indexPath.row == 0) && !self.isOpenProduct(indexPath.section)
        return (whenOpenedFooter || whenClosedFooter)
    }
    
    func isFooterCellSelectable(_ indexPath: IndexPath) -> Bool {
        return self.controlledTableView?.cellForRow(at: indexPath) is FooterTableViewCellProtocol
    }
    
    func isUnderdcell(_ indexPath: IndexPath) -> Bool {
        guard hasUnderCellOffer(indexPath.section) else { return false }
        let shouldBeUndercellWhenOpened = cellsInfo[indexPath.section].cellInfos.count + self.numberOfFooter(indexPath.section) == indexPath.row
        let whenOpened = self.isOpenProduct(indexPath.section) && shouldBeUndercellWhenOpened
        let whenClosed = !self.isOpenProduct(indexPath.section) && indexPath.row == self.numberOfFooter(indexPath.section)
        return (whenOpened || whenClosed)
    }
    
    func isCellUnderCellSelected(_ indexPath: IndexPath) -> Bool {
        return self.isUnderdcell(indexPath) && self.isOfferCell(indexPath)
    }
    
    // Used in willSelectRowAt:
    func isCellSelectable(_ indexPath: IndexPath) -> Bool {
        return !(self.isFooterCellSelectable(indexPath) && self.isOpenProduct(indexPath.section))
    }
}

extension PGClassicTableViewController {
    func scrollToPregrantedLoans(section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        if #available(iOS 11.0, *) {
            controlledTableView?.performBatchUpdates({
                controlledTableView?.scrollToRow(at: indexPath, at: .top, animated: true)
            }, completion: { [weak self] _ in
                guard let bookMarkCell = self?.controlledTableView?.cellForRow(at: indexPath) else { return }
                (bookMarkCell as? PGBookmarkTableViewCell)?.scrollToPregrantedLoans()
            })
        } else {
            controlledTableView?.beginUpdates()
            controlledTableView?.scrollToRow(at: indexPath, at: .top, animated: true)
            controlledTableView?.endUpdates()
            guard let bookMarkCell = controlledTableView?.cellForRow(at: indexPath) else { return }
            (bookMarkCell as? PGBookmarkTableViewCell)?.scrollToPregrantedLoans()
        }
    }
    
    func checkBubbleIsLastPosition() {
        guard let tableView = controlledTableView,
            !(tableView.subviews.last is BubbleWhatsNew),
            let view = tableView.subviews.first(where: { $0 is BubbleWhatsNew }) else {
                return
        }
        tableView.bringSubviewToFront(view)
    }
}

extension PGClassicTableViewController: AccessibilityCapable { }
