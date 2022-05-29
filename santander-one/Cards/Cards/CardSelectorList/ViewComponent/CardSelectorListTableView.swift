//
//  CardSelectorListTableView.swift
//  Cards
//
//  Created by Ignacio González Miró on 10/6/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardSelectorListTableViewDelegate: AnyObject {
    func didTapInCard(_ viewModel: CardboardingCardCellViewModel)
}

final class CardSelectorListTableView: UITableView {
    private var models: [CardboardingCardCellViewModel]?
    weak var tableDelegate: CardSelectorListTableViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    func configView(_ viewModels: [CardboardingCardCellViewModel]) {
        guard !viewModels.isEmpty else {
            setTableHeader()
            setEmptyView()
            return
        }
        self.models = viewModels
        reloadData()
    }
}

private extension CardSelectorListTableView {
    func setView() {
        setTableHeader()
        setCell()
        backgroundColor = .clear
        separatorStyle = .none
        alwaysBounceVertical = false
        dataSource = self
        delegate = self
    }
    
    func setTableHeader() {
        sectionHeaderHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 36
    }
    
    func setCell() {
        let cellNib = UINib(nibName: CardboardingCardCell.nibName, bundle: .module)
        register(cellNib, forCellReuseIdentifier: CardboardingCardCell.identifier)
    }
    
    func setEmptyView() {
        let emptyView = SingleEmptyView()
        emptyView.centerView()
        emptyView.titleFont(.santander(family: .text, type: .regular, size: 18))
        emptyView.updateTitle(localized("deeplink_alert_errorDirectMoney"))
        backgroundView = emptyView
    }
}

extension CardSelectorListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = self.models else {
            return 0
        }
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardboardingCardCell.identifier, for: indexPath) as? CardboardingCardCell,
              let models = self.models else {
            return UITableViewCell()
        }
        let model = models[indexPath.row]
        cell.configureCellWithModel(model: model)
        return cell
    }
}

extension CardSelectorListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let models = self.models else {
            return
        }
        let model = models[indexPath.row]
        tableDelegate?.didTapInCard(model)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CardboardingCardCell.heightForRow
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        headerView.backgroundView = {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.numberOfLines = 0
        headerLabel.accessibilityIdentifier = AccessibilityCardBoardingCardsSelector.tableHeaderLabel
        headerLabel.setHeadlineTextFont(type: .regular, size: 18.0, color: .lisboaGray)
        headerLabel.configureText(withKey: "deeplink_label_selectCard")
        headerView.contentView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.contentView.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerView.contentView.topAnchor, constant: 14),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.contentView.bottomAnchor, constant: -10)
        ])
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
}
