//
//  SendMoneyDestinationAccountFavoritesCollectionView.swift
//  Account
//
//  Created by Angel Abad Perez on 28/9/21.
//

import UIOneComponents
import CoreFoundationLib

protocol SendMoneyDestinationAccountFavoritesCollectionViewDelegate: AnyObject {
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel)
    func didSelectAllFavorites()
}

final class SendMoneyDestinationAccountFavoritesCollectionView: UICollectionView {
    private enum Constants {
        static let firstIndexPath: IndexPath = IndexPath(row: .zero, section: .zero)
        
        enum Item {
            private static let width: CGFloat = 136.0
            private static let height: CGFloat = 148.0
            static let itemSize: CGSize = CGSize(width: width, height: height)
            static let spacing: OneSpacingType = .oneSizeSpacing16
        }
    }
    
    weak var favoritesCollectionDelegate: SendMoneyDestinationAccountFavoritesCollectionViewDelegate?
    private var selectedIndexPath: IndexPath?
    private var sections: [SendMoneyDestinationAccountFavoritesSection] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setSections(_ sections: [SendMoneyDestinationAccountFavoritesSection]) {
        self.sections = sections
        self.reloadData()
    }
    
    func scrollToSelected() {
        for (sectionIndex, section) in self.sections.enumerated() {
            if let selectedContactIndex = section.indexForSelectedContact() {
                self.selectedIndexPath = IndexPath(row: selectedContactIndex, section: sectionIndex)
            }
        }
        self.reloadData()
        self.layoutIfNeeded()
        self.scrollToItem(at: self.selectedIndexPath ?? Constants.firstIndexPath, at: .centeredHorizontally, animated: false)
    }
}

private extension SendMoneyDestinationAccountFavoritesCollectionView {
    func setupView() {
        self.configureLayout()
        self.registerCells()
        self.delegate = self
        self.dataSource = self
        self.allowsSelection = true
        self.allowsMultipleSelection = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }
    
    func configureLayout() {
        guard let flowlayout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowlayout.itemSize = Constants.Item.itemSize
        flowlayout.minimumLineSpacing = oneSpacing(type: Constants.Item.spacing)
        flowlayout.scrollDirection = .horizontal
    }
    
    func registerCells() {
        self.register(type: SendMoneyDestinationAccountFavoriteContactCollectionViewCell.self, bundle: Bundle.module)
        self.register(type: SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell.self, bundle: Bundle.module)
    }
}

extension SendMoneyDestinationAccountFavoritesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].numberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.sections[indexPath.section].cell(in: collectionView, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .contacts(let cards):
            self.favoritesCollectionDelegate?.didSelectFavoriteAccount(cards[indexPath.row])
            if UIAccessibility.isVoiceOverRunning {
                let selected: String = localized("voiceover_selected").text
                UIAccessibility.post(notification: .announcement, argument: selected)
                UIAccessibility.post(notification: .layoutChanged, argument: indexPath)
            }
        case .seeAll:
            self.favoritesCollectionDelegate?.didSelectAllFavorites()
        }
    }
}

extension SendMoneyDestinationAccountFavoritesCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sections[section].sectionInsets()
    }
}
