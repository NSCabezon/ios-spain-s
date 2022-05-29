//
//  LastContributionsView.swift
//  Menu
//
//  Created by Ignacio González Miró on 01/09/2020.
//

import UI
import CoreFoundationLib

protocol LastContributionsDelegate: AnyObject {
    func updateComponentHeight(_ tableHeight: CGFloat)
}

final class LastContributionsView: UIDesignableView {
    @IBOutlet private weak var tableView: AutoSizeTableView!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    private var viewModel: LastContributionsViewModel?
    weak var delegate: LastContributionsDelegate?
    private var isEmptyViewHidden: Bool? = true
    
    override func getBundleName() -> String {
        "Menu"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func configView(_ viewModel: LastContributionsViewModel) {
        self.viewModel = viewModel
        self.updateTableViewHeight(viewModel)
    }
    
    func configEmptyView() {
        self.isEmptyViewHidden = false
        self.tableView.reloadData()
        let newHeight = TableSettings.headerHeight + LastContributionsEmptyCell.height
        self.updatedHeight(newHeight)
    }
}

private extension LastContributionsView {
    struct TableSettings {
        enum Sections: Int {
            case loans = 0
            case cards = 1
        }
        
        static let headerHeight: CGFloat = 55
    }
    
    func setupView() {
        self.tableView.register(LastContributionsEmptyCell.self, bundle: .module)
        self.tableView.register(LastContributionsLoansCell.self, bundle: .module)
        self.tableView.register(LastContributionsCardsCell.self, bundle: .module)
        let header = setTableHeader()
        self.tableView.tableHeaderView = header
        self.tableView.estimatedRowHeight = 72
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func setTableHeader() -> UIView {
        let view = UIView(frame: CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: TableSettings.headerHeight))
        let label = UILabel(frame: CGRect(x: 18.0, y: 19.0, width: self.tableView.frame.width, height: 26.0))
        label.font = UIFont.santander(family: .text, type: .light, size: 22.0)
        label.configureText(withLocalizedString: localized("financing_title_lastInstalments"))
        label.accessibilityIdentifier = AccessibilityLastContributions.lcTitle.rawValue
        view.addSubview(label)
        return view
    }

    func updateTableViewHeight(_ viewModel: LastContributionsViewModel) {
        self.tableViewHeight.constant = CGFloat.greatestFiniteMagnitude
        self.tableView.invalidateIntrinsicContentSize()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        let newHeight = self.tableView.contentSize.height
        self.updatedHeight(newHeight)
    }
    
    func updatedHeight(_ height: CGFloat) {
        self.tableViewHeight.constant = height
        delegate?.updateComponentHeight(height)
    }
}

extension LastContributionsView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = self.viewModel, let isEmptyView = self.isEmptyViewHidden else {
            return 1
        }
        return viewModel.numberOfSections(isEmptyView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel, let isEmptyView = self.isEmptyViewHidden else {
            return 1
        }
        return viewModel.numberOfRows(isEmptyView, section: section, viewModel: viewModel)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isEmptyViewHidden == true {
            switch indexPath.section {
            case TableSettings.Sections.loans.rawValue:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LastContributionsLoansCell.identifier, for: indexPath) as? LastContributionsLoansCell, let viewModel = self.viewModel, let loans = viewModel.loans, loans.count > 0 else { return LastContributionsLoansCell() }
                let item = loans[indexPath.row]
                viewModel.loan = item
                cell.config(viewModel)
                return cell
            case TableSettings.Sections.cards.rawValue:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LastContributionsCardsCell.identifier, for: indexPath) as? LastContributionsCardsCell, let viewModel = self.viewModel, let cards = viewModel.cards, cards.count > 0 else { return LastContributionsCardsCell() }
                let item = cards[indexPath.row]
                viewModel.card = item
                cell.config(viewModel)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LastContributionsEmptyCell.identifier, for: indexPath) as? LastContributionsEmptyCell else { return LastContributionsEmptyCell() }
            let title: LocalizedStylableText = localized("financing_text_emptyViewLastFee")
            cell.config(title)
            return cell
        }
    }
}
