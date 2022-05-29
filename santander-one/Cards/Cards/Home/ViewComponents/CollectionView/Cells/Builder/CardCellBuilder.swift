//
//  CardCellBuilder.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/30/19.
//

import Foundation
import UIKit

class CardCellBuilder {
    let creditCardIdentifier: String = "CreditCardsCollectionViewCell"
    let debitCardIdentifier: String = "DebitCardsCollectionViewCell"
    let prepaidCardIdentifier: String = "PrepaidCardsCollectionViewCell"
    let collectionView: CardsCollectionView
    var indexPath: IndexPath?
    var viewModel: CardViewModel?
    
    init(_ collectionView: CardsCollectionView) {
        self.collectionView = collectionView
    }
    
    func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
    
    func setViewModel(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
    }
    
    func build() -> UICollectionViewCell? {
        guard let viewModel = self.viewModel else {
            return UICollectionViewCell()
        }
        if viewModel.isCreditCard {
            return makeCreditCardCell()
        } else if viewModel.isDebitCard {
            return makeDebitCardCell()
        } else if viewModel.isPrepaidCard {
            return makePrepaidCardCell()
        } else {
            return UICollectionViewCell()
        }
    }
    
    private func makeCreditCardCell() -> UICollectionViewCell? {
        guard let viewModel = self.viewModel,
              let indexPath = self.indexPath else {
              return UICollectionViewCell()
        }
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.creditCardIdentifier, for: indexPath) as? CreditCardsCollectionViewCell
        cell?.delegate = collectionView
        cell?.configure(viewModel)
        return cell
    }
    
    private func makeDebitCardCell() -> UICollectionViewCell? {
        guard let viewModel = self.viewModel,
              let indexPath = self.indexPath else {
              return UICollectionViewCell()
        }
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.debitCardIdentifier, for: indexPath) as? DebitCardsCollectionViewCell
        cell?.delegate = collectionView
        cell?.configure(viewModel)
        return cell
    }
    
    private func makePrepaidCardCell() -> UICollectionViewCell? {
        guard let viewModel = self.viewModel,
              let indexPath = self.indexPath else {
              return UICollectionViewCell()
        }
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.prepaidCardIdentifier, for: indexPath) as? PrepaidCardsCollectionViewCell
        cell?.delegate = collectionView
        cell?.configure(viewModel)
        return cell
    }
}
