//
//  InternalTransferAccountSelectorViewController.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import Operative
import UIOneComponents
import CoreFoundationLib
import CoreDomain

final class InternalTransferAccountSelectorViewController: UIViewController {
    
    private let viewModel: InternalTransferAccountSelectorViewModel
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferAccountSelectorDependenciesResolver
    
    private lazy var tableViewDatasource: InternalTransferAccountSelectorTableDataSource = {
        return InternalTransferAccountSelectorTableDataSource()
    }()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var headerView: InternalTransferAccountSelectorHeaderView = {
        let headerView = InternalTransferAccountSelectorHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    init(dependencies: InternalTransferAccountSelectorDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "InternalTransferAccountSelectorViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
        setupTableViewHeader()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAccessibility(setViewAccessibility: setAccesibilityInfo)
    }
}

private extension InternalTransferAccountSelectorViewController {
    func setupTableView() {
        tableView.register(InternalTransferAccountSelectorCell.self,
                           bundle: InternalTransferAccountSelectorCell.bundle)
        tableView.register(InternalTransferAccountSelectorShowMoreCell.self,
                           bundle: InternalTransferAccountSelectorShowMoreCell.bundle)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupDataSource() {
        tableView.dataSource = tableViewDatasource
        tableView.delegate = tableViewDatasource
    }
    
    func setupTableViewHeader() {
        tableView.setTableHeaderView(headerView: self.headerView)
        tableView.updateHeaderViewFrame()
    }
    
    func bind() {
        bindFilteredAccounts()
        bindSelectRow()
        bindExpandHiddenAccounts()
        bindHeaderView()
    }
    
    func bindFilteredAccounts() {
        viewModel.state
            .case (InternalTransferAccountSelectorState.loaded)
            .sink { [weak self] (visible, notVisible, selected, filteredAccounts) in
                guard let self = self else { return }
                self.configureDataSourceWithAccounts(visible: visible, notVisible: notVisible, selected: selected)
            }.store(in: &anySubscriptions)
    }
    
    func bindSelectRow() {
        tableViewDatasource
            .didSelectRowAtSubject
            .sink { [weak self] accountItem in
                guard let self = self else { return }
                self.viewModel.didSelect(account: accountItem.account)
                self.tableView.reloadData()
            }.store(in: &anySubscriptions)
    }
    
    func bindExpandHiddenAccounts() {
        tableViewDatasource
            .expandHidden
            .sink { [weak self] (expanded, index) in
                guard let self = self else { return }
                guard let anIndex = index else { return }
                self.reloadTableViewSection(index: anIndex, expanded: expanded)
                self.trackViewHiddenAccounts(expanded: expanded)
            }.store(in: &anySubscriptions)
    }
    
    func bindHeaderView() {
        viewModel.state
            .case (InternalTransferAccountSelectorState.loaded)
            .map { [weak self] (visibleAccounts, notVisibleAccounts, _,  filteredAccounts) in
                guard let self = self else { return .showFilteredAccouts }
                let hiddenItems = visibleAccounts.count == 0 && notVisibleAccounts.count > 0
                return self.configureHeaderType(hiddenItems: hiddenItems, filteredAccounts: filteredAccounts)
            }
            .subscribe(headerView.typeSubject)
            .store(in: &anySubscriptions)
        
        headerView.viewFrameSubject
            .sink { [weak self] type in
                guard let self = self else { return }
                self.tableView.updateHeaderViewFrame()
            }
            .store(in: &anySubscriptions)
    }
    
    func trackViewHiddenAccounts(expanded: Bool) {
        guard expanded else { return }
        viewModel.didShowHiddenAccounts()
    }
    
    func reloadTableViewSection(index: Int, expanded: Bool) {
        tableView.beginUpdates()
        tableView.reloadSections([index], with: .automatic)
        tableView.endUpdates()
        guard UIAccessibility.isVoiceOverRunning else { return }
    }
    
    func configureDataSourceWithAccounts(visible: [AccountRepresentable], notVisible: [AccountRepresentable], selected: AccountRepresentable?) {
        let visibleItems: [OneAccountSelectionCardItem] = visible.map { account in
            let selected = account.equalsTo(other: selected)
            return OneAccountSelectionCardItem(account: account, cardStatus: selected ? .selected : .inactive, accessibilityOfView: account.alias ?? "", numberFormater: self.dependencies.external.resolve())
        }
        let hiddenItems: [OneAccountSelectionCardItem] = notVisible.map { account in
            let selected = account.equalsTo(other: selected)
            return OneAccountSelectionCardItem(account: account, cardStatus: selected ? .selected : .inactive, accessibilityOfView: account.alias ?? "", numberFormater: self.dependencies.external.resolve())
        }
        tableViewDatasource.sections = InternalTransferAccountSelectorSectionBuilder(visibles: visibleItems, hidden: hiddenItems).buildSections()
        tableView.reloadData()
    }
    
    func configureHeaderType(hiddenItems: Bool, filteredAccounts: Bool) -> InternalTransferAccountSelectorHeaderType {
        if hiddenItems && filteredAccounts {
            return .showHiddenAndFilteredAccounts
        } else if filteredAccounts {
            return .showFilteredAccouts
        } else if hiddenItems {
            return .showHiddenAccounts
        } else {
            return .hidden
        }
    }
    
    func getShowMoreCellIndex() -> Int {
        guard let index = tableView.visibleCells.firstIndex(where: {
            return ($0 as? InternalTransferAccountSelectorShowMoreCell) != nil
        }) else { return 0 }
        return index
    }
    
    func setAccesibilityInfo() {
        UIAccessibility.post(notification: .layoutChanged, argument: navigationItem.titleView)
    }
}

extension InternalTransferAccountSelectorViewController: StepIdentifiable {}
extension InternalTransferAccountSelectorViewController: AccessibilityCapable {}
