//
//  BankDetailProductsTableView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 14/7/21.
//

import Foundation

private enum BankDetailProductTableViewCellType {
    case accountsHeader(viewModel: BasketHeaderCellViewModel)
    case account(viewModel: AccountProductConfigCellViewModel)
    case cardsHeader(viewModel: BasketHeaderCellViewModel)
    case card(viewModel: CardProductConfigCellViewModel)
    case separator
}

extension BankDetailProductTableViewCellType {
    func identifier() -> String {
        switch self {
        case .accountsHeader: return "AccountsHeaderTableViewCell"
        case .account: return "AccountProductConfigTableViewCell"
        case .cardsHeader: return "CardsHeaderTableViewCell"
        case .card: return "CardProductConfigTableViewCell"
        case .separator: return "SeparatorConfigTableViewCell"
        }
    }
    
    func accessibilityIdentifier(at indexPath: IndexPath) -> String {
        switch self {
        case .accountsHeader: return "accountsHeaderCell"
        case .account: return "accountProductConfigCell\(indexPath.item)"
        case .cardsHeader: return "cardsHeaderCell"
        case .card: return "cardProductConfigCell\(indexPath.item)"
        case .separator: return ""
        }
    }
}

private class BankDetailProductsTableViewHandler: NSObject, UITableViewDataSource {
    var cells: [BankDetailProductTableViewCellType] = []
    weak var delegate: BankDetailProductsConfigDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellType = self.cells[indexPath.item]
        switch cellType {
        case .accountsHeader(viewModel: let viewModel):
            let accountsHeaderCell = tableView.dequeueReusableCell(AccountsHeaderTableViewCell.self, indexPath: indexPath)
            accountsHeaderCell.setViewModel(viewModel)
            accountsHeaderCell.delegate = self
            cell = accountsHeaderCell
        case .account(viewModel: let viewModel):
            let accountCell = tableView.dequeueReusableCell(AccountProductConfigTableViewCell.self, indexPath: indexPath)
            accountCell.setViewModel(viewModel)
            accountCell.delegate = self
            cell = accountCell
        case .cardsHeader(viewModel: let viewModel):
            let cardsHeaderCell = tableView.dequeueReusableCell(CardsHeaderTableViewCell.self, indexPath: indexPath)
            cardsHeaderCell.setViewModel(viewModel)
            cardsHeaderCell.delegate = self
            cell = cardsHeaderCell
        case .card(viewModel: let viewModel):
            let cardCell = tableView.dequeueReusableCell(CardProductConfigTableViewCell.self, indexPath: indexPath)
            cardCell.setViewModel(viewModel)
            cardCell.delegate = self
            cell = cardCell
        case .separator:
            let separatorCell = tableView.dequeueReusableCell(SeparatorConfigTableViewCell.self, indexPath: indexPath)
            cell = separatorCell
        }
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = cellType.accessibilityIdentifier(at: indexPath)
        return cell
    }
}

extension BankDetailProductsTableViewHandler: AccountsHeaderTableViewCellDelegate {
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool) {
        self.delegate?.didPressAllAccountsCheckBox(areAllSelected)
    }
}

extension BankDetailProductsTableViewHandler: AccountProductConfigCellDelegate {
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel) {
        self.delegate?.didPressAccountCheckBox(viewModel)
    }
}

extension BankDetailProductsTableViewHandler: CardsHeaderTableViewCellDelegate {
    func didPressAllCardsCheckBox(_ areAllSelected: Bool) {
        self.delegate?.didPressAllCardsCheckBox(areAllSelected)
    }
}

extension BankDetailProductsTableViewHandler: CardProductConfigCellDelegate {
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel) {
        self.delegate?.didPressCardCheckBox(viewModel)
    }
}

protocol BankDetailProductsConfigDelegate: AnyObject {
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool)
    func didPressAllCardsCheckBox(_ areAllSelected: Bool)
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel)
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel)
    func didPressRecoveryKeys()
    func didPressRemoveConnection()
}

final class BankDetailProductsTableView: UITableView {
    private lazy var bankDetailProductsHandler: BankDetailProductsTableViewHandler = {
        let handler = BankDetailProductsTableViewHandler()
        self.dataSource = handler
        return handler
    }()
    private lazy var bankDetailProductsFooterView = BankDetailProductsConfigFooterView()
    private lazy var headerView = BankDetailProductsConfigHeaderView()
    var bankDetailProductsTableViewDelegate: BankDetailProductsConfigDelegate? {
        get {
            return self.bankDetailProductsHandler.delegate
        }
        set {
            self.bankDetailProductsHandler.delegate = newValue
        }
    }
    
    private var accountViewModels: [AccountProductConfigCellViewModel] = []
    private var cardViewModels: [CardProductConfigCellViewModel] = []
    
    func setup() {
        self.registerCells()
        self.separatorStyle = .none
        self.bankDetailProductsHandler.cells.removeAll()
        self.setFooter()
    }
    
    func setHeader(_ viewModel: BankDetailProductsHeaderViewModel) {
        let headerView = BankDetailProductsConfigHeaderView()
        headerView.setViewModel(viewModel)
        self.setTableHeaderView(headerView: headerView)
    }
    
    func setAccounts(accountViewModels: [AccountProductConfigCellViewModel]) {
        self.accountViewModels = accountViewModels
        self.setAccountCells(accountViewModels)
        self.addSeparator()
        self.reloadData()
    }
    
    func setCards(cardViewModels: [CardProductConfigCellViewModel]) {
        self.cardViewModels = cardViewModels
        self.setCardCells(cardViewModels)
        self.addSeparator()
        self.reloadData()
    }
    
    func reloadAccounts(accountViewModels: [AccountProductConfigCellViewModel]) {
        self.bankDetailProductsHandler.cells.removeAll()
        self.setAccounts(accountViewModels: accountViewModels)
        self.setCards(cardViewModels: self.cardViewModels)
    }
    
    func reloadCards(cardViewModels: [CardProductConfigCellViewModel]) {
        self.bankDetailProductsHandler.cells.removeAll()
        self.setAccounts(accountViewModels: self.accountViewModels)
        self.setCards(cardViewModels: cardViewModels)
    }
}

private extension BankDetailProductsTableView {
    func registerCells() {
        self.register(AccountsHeaderTableViewCell.self, bundle: .module)
        self.register(AccountProductConfigTableViewCell.self, bundle: .module)
        self.register(CardsHeaderTableViewCell.self, bundle: .module)
        self.register(CardProductConfigTableViewCell.self, bundle: .module)
        self.register(SeparatorConfigTableViewCell.self, bundle: .module)
    }
    
    func setFooter() {
        let view = UIView()
        self.bankDetailProductsFooterView.delegate = self
        view.addSubview(self.bankDetailProductsFooterView)
        self.bankDetailProductsFooterView.fullFit()
        self.tableFooterView = view
    }
    
    func setAccountCells(_ viewModels: [AccountProductConfigCellViewModel]) {
        guard !viewModels.isEmpty else { return }
        let areAllSelected = viewModels.allSatisfy { $0.isSelected }
        self.bankDetailProductsHandler.cells.append(.accountsHeader(viewModel: BasketHeaderCellViewModel(areAllSelected: areAllSelected)))
        self.bankDetailProductsHandler.cells.append(contentsOf: viewModels.map(BankDetailProductTableViewCellType.account))
    }
    
    func setCardCells(_ viewModels: [CardProductConfigCellViewModel]) {
        guard !viewModels.isEmpty else { return }
        let areAllSelected = viewModels.allSatisfy { $0.isSelected }
        self.bankDetailProductsHandler.cells.append(.cardsHeader(viewModel: BasketHeaderCellViewModel(areAllSelected: areAllSelected)))
        self.bankDetailProductsHandler.cells.append(contentsOf: viewModels.map(BankDetailProductTableViewCellType.card))
    }
    
    func addSeparator() {
        self.bankDetailProductsHandler.cells.append(.separator)
    }
}

extension BankDetailProductsTableView: BankDetailProductsConfigFooterDelegate {
    func didPressRecoveryKeys() {
        self.bankDetailProductsTableViewDelegate?.didPressRecoveryKeys()
    }
    
    func didPressRemoveConnection() {
        self.bankDetailProductsTableViewDelegate?.didPressRemoveConnection()
    }
}
