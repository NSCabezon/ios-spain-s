//
//  FavRicipientsTableView.swift
//  Transfer
//
//  Created by Ignacio González Miró on 26/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol FavRecipientsTableViewDelegate: AnyObject {
    func didSelectFavRecipient(_ viewModel: ContactListItemViewModel)
}

class FavRecipientsTableView: UITableView {
    private var viewModels: [ContactListItemViewModel] = []
    weak var favRecipientDelegate: FavRecipientsTableViewDelegate?
    private var country: String = ""
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [ContactListItemViewModel], country: String) {
        self.viewModels = viewModels
        self.country = country
        self.reloadData()
    }
}

private extension FavRecipientsTableView {
    func setupView() {
        self.delegate = self
        self.dataSource = self
    }
}

extension FavRecipientsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.isEmpty ? 1 : self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModels.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavRecipientEmptyTableViewCell.identifier, for: indexPath) as? FavRecipientEmptyTableViewCell else { return FavRecipientEmptyTableViewCell() }
            cell.config(self.country)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavRecipientTableViewCell.identifier, for: indexPath) as? FavRecipientTableViewCell else { return FavRecipientTableViewCell() }
            let viewModel = self.viewModels[indexPath.row]
            cell.config(with: viewModel)
            cell.setAccessibilityIdentifier(with: "\(indexPath.row)")
            cell.accessibilityIdentifier = AccessibilityFavRecipients.favouriteCell + "\(indexPath.row)"
            return cell
        }
    }
}

extension FavRecipientsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.viewModels.isEmpty {
            tableView.deselectRow(at: indexPath, animated: true)
            let favourite = self.viewModels[indexPath.row]
            favRecipientDelegate?.didSelectFavRecipient(favourite)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !self.viewModels.isEmpty else { return 211.0 }
        let viewModel = self.viewModels[indexPath.row]
        return viewModel.name.isEmpty || viewModel.beneficiaryName.isEmpty ? 104.0 : 112.0
    }
}
