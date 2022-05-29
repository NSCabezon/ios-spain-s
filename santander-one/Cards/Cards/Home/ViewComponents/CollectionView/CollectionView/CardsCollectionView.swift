//
//  CardsCollectionViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import UI

private struct CardsGeometry {
    let width: CGFloat = 312.0
    let height: CGFloat = 192.0
}

protocol CardsCollectionViewDelegate: AnyObject {
    func didBeginScrolling()
    func didSelectCardViewModel(_ viewModel: CardViewModel)
    func didTapOnShareViewModel(_ viewModel: CardViewModel)
    func didTapOnCVVViewModel(_ viewModel: CardViewModel)
    func didTapOnActivateCard(_ viewModel: CardViewModel)
    func didTapOnShowPAN(_ viewModel: CardViewModel)
    func isPANAlwaysSharable() -> Bool
}

protocol CardsCollectionViewCellDelegate: AnyObject {
    func didTapOnShareViewModel(_ viewModel: CardViewModel)
    func didTapOnCVVViewModel(_ viewModel: CardViewModel)
    func didTapOnActivateCard(_ viewModel: CardViewModel)
    func didTapOnShowPAN(_ viewModel: CardViewModel)
    func isPANAlwaysSharable() -> Bool
}

protocol Spendable {
    func setExpenses(_ viewModel: CardViewModel)
}

final class CardsCollectionView: UICollectionView {
    let creditCardReuseIdentifier: String = "CreditCardsCollectionViewCell"
    let debitCardReuseIdentifier: String = "DebitCardsCollectionViewCell"
    let prepaidCardReuseIdentifier: String = "PrepaidCardsCollectionViewCell"
    var cellBuilder: CardCellBuilder!
    private var cardsViewModels: [CardViewModel] = []
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    weak var pageControlDelegate: PageControlDelegate?
    weak var cardsDelegate: CardsCollectionViewDelegate?

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateCardViewModel(_ viewModel: CardViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return }
        self.cardsViewModels[index] = viewModel
        self.setExpenses(index: index, viewModel: viewModel)
        self.reloadData()
    }
    
    func updateCardsViewModels(_ viewModels: [CardViewModel], selectedViewModel: CardViewModel) {
        self.cardsViewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selectedViewModel)
        self.animateCellProgressIfNeeded(selectedViewModel)
        self.notifySelectedViewModel(selectedViewModel)
    }
}

extension CardsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cardsViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.cardsViewModels[indexPath.row]
        self.cellBuilder.setViewModel(viewModel)
        self.cellBuilder.setIndexPath(indexPath)
        if let cell = self.cellBuilder.build() {
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        self.pageControlDelegate?.didPageChange(page: indexPath.item)
        self.cardsDelegate?.didBeginScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.endScrollingAndSelectAccount()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.endScrollingAndSelectAccount()
    }
}

extension CardsCollectionView: CardsCollectionViewCellDelegate {
    
    func didTapOnShareViewModel(_ viewModel: CardViewModel) {
        self.cardsDelegate?.didTapOnShareViewModel(viewModel)
    }
    
    func didTapOnCVVViewModel(_ viewModel: CardViewModel) {
        self.cardsDelegate?.didTapOnCVVViewModel(viewModel)
    }
    
    func didTapOnActivateCard(_ viewModel: CardViewModel) {
        self.cardsDelegate?.didTapOnActivateCard(viewModel)
    }
    
    func didTapOnShowPAN(_ viewModel: CardViewModel) {
        self.cardsDelegate?.didTapOnShowPAN(viewModel)
    }
    
    func isPANAlwaysSharable() -> Bool {
        return self.cardsDelegate?.isPANAlwaysSharable() ?? true
    }
}

private extension CardsCollectionView {
    
    func setupView() {
        self.registerCell()
        self.addLayout()
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.cellBuilder = CardCellBuilder(self)
        self.backgroundColor = UIColor.skyGray
    }
    
    func addLayout() {
        let cardGeometry = CardsGeometry()
        layout.setItemSize(CGSize(width: cardGeometry.width, height: cardGeometry.height))
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    func registerCell() {
        let creditCardNib = UINib(nibName: creditCardReuseIdentifier, bundle: Bundle.module)
        let debitCardNib = UINib(nibName: debitCardReuseIdentifier, bundle: Bundle.module)
        let prepaidCardNib = UINib(nibName: prepaidCardReuseIdentifier, bundle: Bundle.module)
        self.register(creditCardNib, forCellWithReuseIdentifier: creditCardReuseIdentifier)
        self.register(debitCardNib, forCellWithReuseIdentifier: debitCardReuseIdentifier)
        self.register(prepaidCardNib, forCellWithReuseIdentifier: prepaidCardReuseIdentifier)
    }
    
    func setSelectedViewModel(_ viewModel: CardViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func animateCellProgressIfNeeded(_ viewModel: CardViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let cell = self.cellForItem(at: indexPath) as? CreditCardsCollectionViewCell
            cell?.animateProgress()
        }
    }
    
    func getIndexForViewModel(_ viewModel: CardViewModel) -> Int? {
        let index = self.cardsViewModels.firstIndex(where: { return $0.hashValue == viewModel.hashValue })
        return index
    }
    
    func notifySelectedViewModel(_ viewModel: CardViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        self.pageControlDelegate?.didPageChange(page: item)
        self.cardsDelegate?.didSelectCardViewModel(viewModel)
    }
 
    func endScrollingAndSelectAccount() {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.cardsViewModels[indexPath.item]
        self.animateCellProgressIfNeeded(viewModel)
        self.cardsDelegate?.didSelectCardViewModel(viewModel)
    }
    
    func setExpenses(index: Int, viewModel: CardViewModel) {
        guard let cell = self.cellForItem(at: IndexPath(item: index, section: 0)) as? Spendable else {
            return
        }
        cell.setExpenses(viewModel)
    }
}
