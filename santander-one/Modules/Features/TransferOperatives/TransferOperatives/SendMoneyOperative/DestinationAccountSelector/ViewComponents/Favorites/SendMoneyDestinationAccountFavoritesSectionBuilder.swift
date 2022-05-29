//
//  SendMoneyDestinationAccountFavoritesSectionBuilder.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 28/9/21.
//

import UIKit
import CoreFoundationLib

enum SendMoneyDestinationAccountFavoritesSection {
    case contacts([OneFavoriteContactCardViewModel])
    case seeAll
    
    func numberOfRows() -> Int {
        switch self {
        case .contacts(let cards):
            return cards.count
        case .seeAll:
            return 1
        }
    }
    
    func indexForSelectedContact() -> Int? {
        switch self {
        case .contacts(let cards):
            return cards.firstIndex(where: { $0.cardStatus == .selected })
        case .seeAll:
            return nil
        }
    }
    
    func cell(in collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .contacts(let cards):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier(), for: indexPath) as? SendMoneyDestinationAccountFavoriteContactCollectionViewCell else { return SendMoneyDestinationAccountFavoriteContactCollectionViewCell() }
            cell.setViewModel(cards[indexPath.row])
            cell.setAccessibilityCell()
            return cell
        case .seeAll:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier(), for: indexPath) as? SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell else { return SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell() }
            return cell
        }
    }
    
    func sectionInsets() -> UIEdgeInsets {
        switch self {
        case .contacts:
            return UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 12.0)
        case .seeAll:
            return UIEdgeInsets(top: 16.0, left: .zero, bottom: 16.0, right: 16.0)
        }
    }
    
    private func cellIdentifier() -> String {
        switch self {
        case .contacts:
            return "SendMoneyDestinationAccountFavoriteContactCollectionViewCell"
        case .seeAll:
            return "SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell"
        }
    }
}

struct SendMoneyDestinationAccountFavoritesSectionBuilder {
    let cards: [OneFavoriteContactCardViewModel]
    let hasSeeAll: Bool
    
    func buildSections() -> [SendMoneyDestinationAccountFavoritesSection] {
        var sections: [SendMoneyDestinationAccountFavoritesSection] = []
        sections.append(.contacts(self.cards))
        if hasSeeAll {
            sections.append(.seeAll)
        }
        return sections
    }
}
