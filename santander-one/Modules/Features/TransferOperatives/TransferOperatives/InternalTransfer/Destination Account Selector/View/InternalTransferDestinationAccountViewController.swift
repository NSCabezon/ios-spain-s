//
//  InternalTransferDestinationAccountViewController.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 15/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import Operative
import UIOneComponents
import CoreFoundationLib
import CoreDomain

final class InternalTransferDestinationAccountViewController: UIViewController {
    private let viewModel: InternalTransferDestinationAccountViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferDestinationAccountDependenciesResolver

    private lazy var tableViewDatasource: InternalTransferAccountSelectorTableDataSource = {
        return InternalTransferAccountSelectorTableDataSource()
    }()

    @IBOutlet private weak var tableView: UITableView!

    private lazy var headerView: InternalTransferDestinationAccountSelectorHeaderView = {
        let headerView = InternalTransferDestinationAccountSelectorHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    init(dependencies: InternalTransferDestinationAccountDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "InternalTransferDestinationAccountViewController", bundle: .module)
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

private extension InternalTransferDestinationAccountViewController {
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

    func reloadTableViewSection(index: Int, expanded: Bool) {
        tableView.beginUpdates()
        tableView.reloadSections([index], with: .automatic)
        tableView.endUpdates()
        guard UIAccessibility.isVoiceOverRunning else { return }
    }

    func configureDataSourceWithAccounts(visible: [AccountRepresentable], notVisible: [AccountRepresentable], selected: AccountRepresentable?) {
        let visibleItems:[OneAccountSelectionCardItem] = visible.map { account in
            let selected = account.equalsTo(other: selected)
            return OneAccountSelectionCardItem(account: account, cardStatus: selected ? .selected : .inactive, accessibilityOfView: account.alias ?? "", numberFormater: self.dependencies.external.resolve())
        }
        let hiddenItems:[OneAccountSelectionCardItem] = notVisible.map { account in
            let selected = account.equalsTo(other: selected)
            return OneAccountSelectionCardItem(account: account, cardStatus: selected ? .selected : .inactive, accessibilityOfView: account.alias ?? "", numberFormater: self.dependencies.external.resolve())
        }
        tableViewDatasource.sections = InternalTransferAccountSelectorSectionBuilder(visibles: visibleItems, hidden: hiddenItems).buildSections()
        tableView.reloadData()
    }

    func configureHeaderType(hiddenItems: Bool, filteredAccounts: Bool) -> InternalTransferDestinationAccountSelectorHeaderType {
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

private extension InternalTransferDestinationAccountViewController {

    func bind() {
        bindFilteredAccounts()
        bindSelectRow()
        bindExpandHiddenAccounts()
        bindHeaderView()
    }

    func bindFilteredAccounts() {
        viewModel.state
            .case(InternalTransferDestinationAccountState.loaded)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.configureDataSourceWithAccounts(visible: data.visibleAccounts,
                                                     notVisible: data.notVisibleAccounts,
                                                     selected: data.selectedAccount)
            }.store(in: &subscriptions)
    }

    func bindSelectRow() {
        tableViewDatasource
            .didSelectRowAtSubject
            .sink {[weak self] accountItem in
                guard let self = self else { return }
                self.viewModel.didSelect(account: accountItem.account)
                self.tableView.reloadData()
            }.store(in: &subscriptions)
    }

    func bindExpandHiddenAccounts() {
        tableViewDatasource
            .expandHidden
            .sink {[weak self] (expanded, index) in
                guard let self = self else { return }
                guard let anIndex = index else { return }
                self.reloadTableViewSection(index: anIndex, expanded: expanded)
            }.store(in: &subscriptions)
    }

    func bindHeaderView() {
        viewModel.state
            .case(InternalTransferDestinationAccountState.loaded)
            .map {[weak self] data in
                guard let self = self else { return .hidden}
                let hiddenItems = data.visibleAccounts.count == 0 && data.notVisibleAccounts.count > 0
                let viewModel = OneAccountsSelectedCardViewModel(statusCard: .contracted, originAccount: data.originAccount)
                self.headerView.oneAccountSelectedCardView.setupAccountViewModel(viewModel)
                return self.configureHeaderType(hiddenItems: hiddenItems, filteredAccounts: data.showFilteredAccountsMessage)
            }
            .subscribe(headerView.typeSubject)
            .store(in: &subscriptions)

        headerView.oneAccountSelectedCardView.publisher
            .case(ReactiveOneAccountsSelectedState.didSelectOrigin)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.didChangeAccount()
                self.viewModel.back()
            }.store(in: &subscriptions)

        headerView.viewFrameSubject
            .sink {[weak self] type in
                guard let self = self else { return }
                self.tableView.updateHeaderViewFrame()
            }
            .store(in: &subscriptions)
    }
}

extension InternalTransferDestinationAccountViewController: StepIdentifiable {}
extension InternalTransferDestinationAccountViewController: AccessibilityCapable {}
