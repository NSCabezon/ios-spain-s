//
//  BankProductsTableView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 30/6/21.
//

import Foundation

private enum BankProductTableViewCellType {
    case accountsHeader(viewModel: BasketHeaderCellViewModel)
    case account(viewModel: AccountProductConfigCellViewModel)
    case cardsHeader(viewModel: BasketHeaderCellViewModel)
    case card(viewModel: CardProductConfigCellViewModel)
    case separator
}

extension BankProductTableViewCellType {
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

private class BankProductsTableViewHandler: NSObject, UITableViewDataSource {
    var cells: [BankProductTableViewCellType] = []
    weak var delegate: BankProductsConfigDelegate?
    
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

extension BankProductsTableViewHandler: AccountsHeaderTableViewCellDelegate {
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool) {
        self.delegate?.didPressAllAccountsCheckBox(areAllSelected)
    }
}

extension BankProductsTableViewHandler: AccountProductConfigCellDelegate {
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel) {
        self.delegate?.didPressAccountCheckBox(viewModel)
    }
}

extension BankProductsTableViewHandler: CardsHeaderTableViewCellDelegate {
    func didPressAllCardsCheckBox(_ areAllSelected: Bool) {
        self.delegate?.didPressAllCardsCheckBox(areAllSelected)
    }
}

extension BankProductsTableViewHandler: CardProductConfigCellDelegate {
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel) {
        self.delegate?.didPressCardCheckBox(viewModel)
    }
}

protocol BankProductsConfigDelegate: AnyObject {
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool)
    func didPressAllCardsCheckBox(_ areAllSelected: Bool)
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel)
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel)
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel)
    func didPressAddOtherBanks()
}

final class BankProductsTableView: UITableView {
    private lazy var bankProductsHandler: BankProductsTableViewHandler = {
        let handler = BankProductsTableViewHandler()
        self.dataSource = handler
        return handler
    }()
    private lazy var bankProductsFooterView = BankProductsFooterView()
    var bankProductsTableViewDelegate: BankProductsConfigDelegate? {
        get {
            return self.bankProductsHandler.delegate
        }
        set {
            self.bankProductsHandler.delegate = newValue
        }
    }
    
    private var accountViewModels: [AccountProductConfigCellViewModel] = []
    private var cardViewModels: [CardProductConfigCellViewModel] = []
    
    func setup() {
        self.registerCells()
        self.separatorStyle = .none
        self.bankProductsHandler.cells.removeAll()
    }
    
    func setHeader(_ viewModel: ExpensesAnalysysConfigHeaderViewModel) {
        let headerView = ExpensesAnalysisConfigHeaderView()
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
        self.bankProductsHandler.cells.removeAll()
        self.setAccounts(accountViewModels: accountViewModels)
        self.setCards(cardViewModels: self.cardViewModels)
    }
    
    func reloadCards(cardViewModels: [CardProductConfigCellViewModel]) {
        self.bankProductsHandler.cells.removeAll()
        self.setAccounts(accountViewModels: self.accountViewModels)
        self.setCards(cardViewModels: cardViewModels)
    }
    
    func setOtherBanksConfigFooter(_ viewModels: [OtherBankConfigViewModel]) {
        let view = UIView()
        self.bankProductsFooterView.delegate = self
        self.bankProductsFooterView.setViewModels(viewModels)
        view.addSubview(self.bankProductsFooterView)
        bankProductsFooterView.fullFit()
        self.tableFooterView = view
    }
}

private extension BankProductsTableView {
    func registerCells() {
        self.register(AccountsHeaderTableViewCell.self, bundle: .module)
        self.register(AccountProductConfigTableViewCell.self, bundle: .module)
        self.register(CardsHeaderTableViewCell.self, bundle: .module)
        self.register(CardProductConfigTableViewCell.self, bundle: .module)
        self.register(SeparatorConfigTableViewCell.self, bundle: .module)
    }
    
    func setAccountCells(_ viewModels: [AccountProductConfigCellViewModel]) {
        guard !viewModels.isEmpty else { return }
        let areAllSelected = viewModels.allSatisfy { $0.isSelected }
        self.bankProductsHandler.cells.append(.accountsHeader(viewModel: BasketHeaderCellViewModel(areAllSelected: areAllSelected)))
        self.bankProductsHandler.cells.append(contentsOf: viewModels.map(BankProductTableViewCellType.account))
    }
    
    func setCardCells(_ viewModels: [CardProductConfigCellViewModel]) {
        guard !viewModels.isEmpty else { return }
        let areAllSelected = viewModels.allSatisfy { $0.isSelected }
        self.bankProductsHandler.cells.append(.cardsHeader(viewModel: BasketHeaderCellViewModel(areAllSelected: areAllSelected)))
        self.bankProductsHandler.cells.append(contentsOf: viewModels.map(BankProductTableViewCellType.card))
    }
    
    func addSeparator() {
        self.bankProductsHandler.cells.append(.separator)
    }
}

extension BankProductsTableView: BankProductsFooterViewDelegate {
    func didSelectOtherBankConfig(_ viewModel: OtherBankConfigViewModel) {
        self.bankProductsHandler.delegate?.didPressOtherBankConfig(viewModel)
    }
    
    func didSelectAddOtherBanks() {
        self.bankProductsHandler.delegate?.didPressAddOtherBanks()
    }
}
