//
//  BillHomeViewController.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//
import UIKit
import UI
import CoreFoundationLib
import CoreDomain

protocol BillHomeViewProtocol: NavigationBarWithSearchProtocol {
    func showFutureBills(_ viewModels: [FutureBillViewModel])
    func showLastBills(_ viewModels: [LastBillViewModel])
    func showMonths(_ months: Int)
    func showFutureBillsEmpty()
    func showLastBillsEmpty()
    func showLastBillsLoading()
    func setMonthsHidden()
    func showMonths()
    func disableTimeLine()
    func showPageLoading()
    func hidePageLoading()
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
    func setTagsOnHeader(_ tagsMetadata: [TagMetaData])
    func showFiltersButton()
    func hideFiltersButton()
    func removeTagsContainer()
    func setFutureBillsHidden()
    func setOfferBannerLocation(_ offerViewModel: OfferBannerViewModel?)
}

public class BillHomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let presenter: BillHomePresenterProtocol
    private let billTableViewHeader = BillTableViewHeader()
    private let billTableViewFooter = PageLoadingView()
    private let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    public  var searchButtonPosition: Int { 1 }
    private var sheetView: SheetView? = SheetView()
    public var isSearchEnabled: Bool = false {
        didSet { setupNavigationBar()  }
    }
    
    private lazy var lastBillDatasource: LastBillTableDatasource = {
        return LastBillTableDatasource(strategy: GroupBillByDateStrategy(delegate: self))
    }()
    
    private lazy var billStrategies: [BillStrategy] = {
        [GroupBillByDateStrategy(delegate: self),
         GroupBillByTransmitterStrategy(delegate: self),
         GroupBillByProductStrategy(delegate: self)]
    }()
    
    private let cellIdentifiers = [
        LastBillLoadingTableViewCell.identifier,
        LastBillEmptyTableViewCell.identifier,
        LastBillTableViewCell.identifier,
        TransmitterHeaderTableViewCell.identifier,
        TransmitterElementTableViewCell.identifier,
        TransmitterFooterTableViewCell.identifier,
        ProductHeaderTableViewCell.identifier,
        ProductElementTableViewCell.identifier,
        ProductFooterTableViewCell.identifier
    ]
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: BillHomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        self.setupTableView()
        self.setupTableViewDatasource()
        self.presenter.viewDidLoad()
        self.view.backgroundColor = .skyGray
        self.sheetView?.accessibilityIdentifier = "areaCard"
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent { // View is being presented
            self.setupNavigationBar()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
        self.tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sheetView?.closeWithoutAnimation()
        self.sheetView?.removeFromSuperview()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    @objc func dismissViewController() {
        self.presenter.dismissViewController()
    }
    
    @objc func openMenu() {
        self.presenter.openMenu()
    }
}

private extension BillHomeViewController {
    func setupTableView() {
        self.tableView.bounces = false
        self.tableView.backgroundColor = .white
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.setTableHeaderView(headerView: billTableViewHeader)
        self.tableView.contentInset = self.contentInset
        self.registerSectionHeader()
        self.registerCells()
    }
    
    func setupTableViewDatasource() {
        self.billTableViewHeader.setDelegate(delegate: self)
        self.lastBillDatasource.setDelegate(delegate: self)
        self.tableView.dataSource = lastBillDatasource
        self.tableView.delegate = lastBillDatasource
    }
    
    func registerSectionHeader() {
        let nib = UINib(nibName: DateTableSectionHeaderView.identifier, bundle: .module)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: DateTableSectionHeaderView.identifier)
    }
    
    func registerCells() {
        self.cellIdentifiers.forEach {
            self.tableView.register(UINib(nibName: $0, bundle: .module), forCellReuseIdentifier: $0)
        }
    }
    
    func didLastBillsStateChanged(_ state: ViewState<[LastBillViewModel]>) {
        self.lastBillDatasource.didStateChanged(state)
        self.tableView.reloadData()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_receiptsAndTaxes",
                type: .red, action: { [weak self] sender in
                    self?.didSelectToolTip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func didSelectToolTip(_ sender: UIView) {
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(title: localized("toolbar_title_receiptsAndTaxes"))
        navigationToolTip.add(description: localized("tooltip_label_payReceiptsAndTaxes"))
        navigationToolTip.show(in: self, from: sender)
        self.presenter.trackTooltip()
    }
}

extension BillHomeViewController: BillHomeViewProtocol {
    func setFutureBillsHidden() {
        self.billTableViewHeader.setFutureBillHidden()
    }
    
    func showFutureBills(_ viewModels: [FutureBillViewModel]) {
        self.billTableViewHeader.setFutureBillState(.filled(viewModels))
    }
    
    func showLastBills(_ viewModels: [LastBillViewModel]) {
        self.didLastBillsStateChanged(.filled(viewModels))
    }
    
    func showFutureBillsEmpty() {
        self.billTableViewHeader.setFutureBillState(.empty)
    }
    
    func showLastBillsEmpty() {
        self.didLastBillsStateChanged(.empty)
    }
    
    func showLastBillsLoading() {
        self.didLastBillsStateChanged(.loading)
    }
    
    func showMonths(_ months: Int) {
        self.billTableViewHeader.setBillMonths(months)
    }
    
    func disableTimeLine() {
        self.billTableViewHeader.disableTimeLine()
    }
    
    func showPageLoading() {
        let size = CGSize(width: tableView.bounds.width, height: 68)
        let frame = CGRect(origin: .zero, size: size)
        self.billTableViewFooter.frame = frame
        self.billTableViewFooter.startLoading()
        self.tableView.tableFooterView = billTableViewFooter
    }
    
    func hidePageLoading() {
        self.billTableViewFooter.stopLoading()
        self.tableView.tableFooterView = nil
    }
    
    public func searchButtonPressed() {
        self.presenter.doSearch()
    }
    
    func setMonthsHidden() {
        self.billTableViewHeader.setMonthsHidden()
    }
    
    func showMonths() {
        self.billTableViewHeader.showMonths()
    }
    
    func showFiltersButton() {
        self.billTableViewHeader.showFiltersButton()
    }
    
    func hideFiltersButton() {
        self.billTableViewHeader.hideFiltersButton()
    }
    
    func setTagsOnHeader(_ tagsMetadata: [TagMetaData]) {
        self.billTableViewHeader.tagsContainerView?.removeFromSuperview()
        self.billTableViewHeader.addTagContainer(withTags: tagsMetadata, delegate: self)
        self.tableView.updateHeaderWithAutoLayout()
    }
    
    func removeTagsContainer() {
        self.billTableViewHeader.tagsContainerView?.removeFromSuperview()
        self.billTableViewHeader.tagsContainerView = nil
        self.tableView.updateHeaderWithAutoLayout()
    }
    
    func setOfferBannerLocation(_ offerViewModel: OfferBannerViewModel?) {
        self.billTableViewHeader.configView(offerViewModel)
        self.tableView.reloadData()
    }
}

extension BillHomeViewController: BillTableViewHeaderDelegate {
    func didSelectTimeLine() {
        self.presenter.didSelectTimeLine()
    }
    
    func didSelectFutureBill(_ futureBillViewModel: FutureBillViewModel) {
        presenter.didSelectFutureBill(futureBillViewModel)
    }
    
    func didSelectPayment() {
        self.presenter.didSelectPayment()
    }
    
    func didSelectDomicile() {
        self.presenter.didSelectDomicile()
    }
    
    func didSegmentIndexChanged(_ index: Int) {
        self.lastBillDatasource.setStrategy(self.billStrategies[index])
        self.tableView.reloadData()
        self.presenter.segmentedIndexChanged(index)
    }
    
    func didSelectFilter() {
        self.presenter.didSelectFilters()
    }
    
    func scrollViewDidEndDecelerating() {
        self.presenter.nextBillsScrollViewDidEndDecelerating()
    }
    
    func didSelectOfferBanner(_ offerViewModel: OfferBannerViewModel?) {
        self.presenter.didTapInOfferBanner(offerViewModel)
    }
}

extension BillHomeViewController: BillStrategyDelegate {
    func reloadCellSection(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        self.tableView.beginUpdates()
        self.tableView.reloadSections([indexPath.section], with: .none)
        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        self.tableView.endUpdates()
    }
    
    func tableViewDidReachTheEndOfTheList() {
        self.presenter.loadMoreBills()
    }
    
    func didSelectTransmitterGroup(_ viewModel: TransmitterGroupViewModel) {
        let contentBuilder = TransmitterContentSheetBuilder(viewModel: viewModel)
        contentBuilder.addDelegate(delegate: self)
        self.sheetView?.removeContent()
        self.sheetView?.addScrollableContent(contentBuilder.build())
        self.sheetView?.show()
    }
    
    func didSwipeBegin(on cell: LastBillTableViewCell) {
        let visibleCells = self.tableView.visibleCells.filter { return $0 != cell }
        visibleCells.forEach {
            ($0 as? LastBillTableViewCell)?.swipeToOriginWithAnimation()
        }
    }
    
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel) {
        self.presenter.didSelectReturnReceipt(viewModel)
    }
    
    func didSelectSeePDF(_ viewModel: LastBillViewModel) {
        self.presenter.didSelectSeePDF(viewModel)
    }
}

extension BillHomeViewController: TransmitterContentSheetBuilderDelegate {
    func didSelectLastBillViewModelFromSheetView(_ viewModel: LastBillViewModel) {
        self.sheetView?.closeWithAnimation()
        self.presenter.didSelectLastBillViewModel(viewModel)
    }
}

extension BillHomeViewController: LastBillTableDatasourceDelegate {
    func didSelectLastBillViewModel(_ viewModel: LastBillViewModel) {
        self.presenter.didSelectLastBillViewModel(viewModel)
    }
}

extension BillHomeViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .bills
    }
}

extension BillHomeViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension BillHomeViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension BillHomeViewController: TagsContainerViewDelegate {
    
    public func didRemoveFilter(_ remaining: [TagMetaData]) {
        self.tableView.updateHeaderWithAutoLayout()
        self.presenter.didSelectRemoveFilter(remaining)
    }
}
