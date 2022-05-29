//
//  LastMovementsListView.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

enum LastMovementListViewState {
    case loading
    case empty
    case showMovements
}

protocol LastMovementsListDelegate: AnyObject {
    func didSelectItem(_ item: UnreadMovementItem)
    func didTapInGoToMoreMovements()
    func updatedTableView()
    func didTapCrossSellingButton(_ item: UnreadMovementItem)
}

final class LastMovementsListView: DesignableView {

    @IBOutlet private weak var container: UIView!
    @IBOutlet public weak var tableView: UITableView!
    
    private enum LastMovementsListSizes: CGFloat {
        case headerHeight = 46.0
        case footerHeight = 54.0
        case sectionHeight = 30.0
    }
    
    private var headerView = LastMovementsHeaderView()
    private var footerView = LastMovementsFooterView()
    
    weak var delegate: LastMovementsListDelegate?
    var viewModel: WhatsNewLastMovementsViewModel?
    var state: LastMovementListViewState = .loading

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTable()
        self.setTableHeader(0, isSmallList: false, section: .fractionableCards)
    }
    
    func configList(_ viewModel: WhatsNewLastMovementsViewModel, isSmallList: Bool, section: LastMovementsConfiguration.FractionableSection) {
        self.viewModel = viewModel
        self.setupTable()
        let shortHeader = section == .lastMovements && isSmallList
        self.setTableHeader(viewModel.totalTransactions, isSmallList: shortHeader, section: section)
        self.setTableFooter(isSmallList)
        self.state = .showMovements
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false
        self.tableView.reloadData()
    }

    func showEmptyView() {
        self.state = .empty
        self.tableView.reloadData()
    }
}

private extension LastMovementsListView {
    func setupTable() {
        let footer = UINib(nibName: "LastMovementsSection", bundle: Bundle(for: WhatsNewViewController.self))
        self.tableView.register(footer, forHeaderFooterViewReuseIdentifier: LastMovementsSection.identifier)
        let cell = UINib(nibName: "LastMovementsCell", bundle: Bundle(for: WhatsNewViewController.self))
        self.tableView.register(cell, forCellReuseIdentifier: LastMovementsCell.identifier)
        self.tableView.register(LastMovementLoadingTableViewCell.self, bundle: LastMovementLoadingTableViewCell.bundle)
        self.tableView.register(LastMovementEmptyTableViewCell.self, bundle: LastMovementEmptyTableViewCell.bundle)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .clear
        self.tableView.layer.cornerRadius = 6.0
        self.setShadow()
    }
    
    func setTableHeader(_ numberOfMovements: Int, isSmallList: Bool, section: LastMovementsConfiguration.FractionableSection) {
        let headerFrame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: LastMovementsListSizes.headerHeight.rawValue)
        let title: LocalizedStylableText = localized("widget_label_lastMovements")
        self.headerView = LastMovementsHeaderView(frame: headerFrame)
        self.headerView.configHeader(title, numberOfMovements, isSmallList, section: section)
        self.tableView.tableHeaderView = headerView
    }
    
    func setTableFooter(_ isSmallList: Bool) {
        let totalTransactions = viewModel?.totalTransactions ?? 0
        if isSmallList && totalTransactions > 4 {
            let footerFrame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: LastMovementsListSizes.footerHeight.rawValue)
            let title: LocalizedStylableText = localized("product_button_seeMore")
            self.footerView = LastMovementsFooterView(frame: footerFrame)
            self.footerView.config(title)
            self.footerView.delegate = self
            self.tableView.tableFooterView = footerView
        } else {
            self.tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    func setShadow() {
        self.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        let shadowConfiguration = ShadowConfiguration(color: UIColor.darkTorquoise.withAlphaComponent(0.33), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.container.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
    }
}

extension LastMovementsListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .empty, .loading:
            return 1
        case .showMovements:
            return viewModel?.numberOfSections() ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .empty, .loading:
            return 1
        case .showMovements:
            return viewModel?.rowsAtSection(section) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .empty:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LastMovementEmptyTableViewCell.identifier, for: indexPath) as? LastMovementEmptyTableViewCell else { return UITableViewCell() }
            return cell
        case .loading:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LastMovementLoadingTableViewCell.identifier, for: indexPath) as? LastMovementLoadingTableViewCell else { return UITableViewCell() }
            return cell
        case .showMovements:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LastMovementsCell.identifier, for: indexPath) as? LastMovementsCell else {
                return LastMovementsCell()
            }
            guard let item = viewModel?.itemAtIndexPath(indexPath) else { return LastMovementsCell() }
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            let isLastItem = indexPath.row == numberOfRows - 1
            cell.configWithItem(item, isLastItem: isLastItem, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
}

extension LastMovementsListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch state {
        case .showMovements:
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedItem = viewModel?.itemAtIndexPath(indexPath) else {
            return
        }
        delegate?.didSelectItem(selectedItem)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch state {
        case .empty, .loading:
            return nil
        case .showMovements:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LastMovementsSection.identifier) as? LastMovementsSection,
                  let dateItem = viewModel?.sectionItemAt(section) else {
                return nil
            }
            headerView.accessibilityIdentifier = AccesibilityLastMovementsList.titleSection
            headerView.hideSeparator(false)
            headerView.configure(withDate: dateItem.formatedLocalizedHeader())
            tableView.removeUnnecessaryHeaderTopPadding()
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch state {
        case .empty, .loading:
            return 0
        case .showMovements:
            return LastMovementsListSizes.sectionHeight.rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last, indexPath.row == lastVisibleIndexPath.row {
            delegate?.updatedTableView()
        }
    }
}

extension LastMovementsListView: LastMovementsFooterDelegate {
    func didTapInSeeMoreMovements() {
        delegate?.didTapInGoToMoreMovements()
    }
}

extension LastMovementsListView: LastMovementsCellDelegate {
    func didTapCrossSelling(_ item: UnreadMovementItem) {
        self.delegate?.didTapCrossSellingButton(item)
    }
}
