//
//  CardTransactionCollectoinView.swift
//  Pods
//
//  Created by Hernán Villamil on 6/4/22.
//

import OpenCombine
import CoreDomain
import Foundation
import UI
import UIKit

final class CardTransactionCollectoinView: UICollectionView {
    private let identifier = "CardTransactionCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private let bindableDatasource = Datasource<CardTransactionViewItemRepresentable>()
    private var subscriptions = Set<AnyCancellable>()
    private let bindableDegate = Delegate()
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    let didSelectTransactionSubject = PassthroughSubject<CardTransactionViewItemRepresentable, Never>()
    let didLoadTransactionSubject = PassthroughSubject<CardTransactionViewItemRepresentable, Never>()
    var currentPosition = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

extension CardTransactionCollectoinView {
    func scrollTo(_ item: CardTransactionViewItemRepresentable) {
        guard let index = try? getIndexForItem(item) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        currentPosition = indexPath.row
        layoutIfNeeded()
        selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func updateItem(_ item: CardTransactionViewItemRepresentable) {
        guard let index = try? getIndexForItem(item) else { return }
        let cell = getCell(index: index)
        let indexPath = IndexPath(item: index, section: 0)
        bindableDatasource.items[indexPath.item] = item
        cell?.stateSubject.send(.item(item))
                
    }
    
    func bind<Element, Cell: UICollectionViewCell>(items: [Element], completion: @escaping (IndexPath, Cell?, Element) -> Void) {
        registerCell()
        bindableDatasource.reuseIdentifier = identifier
        bindableDatasource.setItems(items)
        bindableDatasource.bind = { [unowned self] (indexPath, cell) in
            self.bindResizeCell(indexPath.item)
            return completion(indexPath, cell as? Cell, items[indexPath.row] )
        }
    }
}

private extension CardTransactionCollectoinView {
    func commonInit() {
        bind()
        setupAppearance()
        registerCell()
        addConstraints()
        delegate = bindableDegate
        dataSource = bindableDatasource
        addLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor.skyGray
        decelerationRate = .fast
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func addConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint =
            heightAnchor.constraint(equalToConstant: ExpandableConfig.estimatedHeight)
        collectionViewHeightConstraint?.isActive = true
    }
    
    func addLayout() {
        let itemWidth = UIScreen.main.bounds.size.width * 0.80
        layout.setItemSize(CGSize(width: itemWidth, height: ExpandableConfig.estimatedExpandedHeight))
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        collectionViewLayout = layout
    }
    
    func updateLayout() {
       guard let indexPath = layout.indexPathForCenterRect(),
             let cell = cellForItem(at: indexPath) as? CardTransactionCollectionViewCell else {
                 return
             }
       collectionViewHeightConstraint.constant = cell.getCellHeight(cell, collectionVIew: self)
       layoutIfNeeded()
   }
    
    func getIndexForItem(_ item: CardTransactionViewItemRepresentable) throws -> Int {
        guard let index = bindableDatasource.items.firstIndex(where: { return itemsAreEqual($0, item) }) else {
            throw NSError()
        }
        return index
    }
    
    func itemsAreEqual(_ firstItem: CardTransactionViewItemRepresentable, _ secondItem: CardTransactionViewItemRepresentable) -> Bool {
        guard firstItem.transaction.description?.capitalized == secondItem.transaction.description?.capitalized else {
            return false
        }
        guard firstItem.transaction.operationDate?.description == secondItem.transaction.operationDate?.description else {
            return false
        }
        guard firstItem.card.detailUI == secondItem.card.detailUI else {
            return false
        }
        guard firstItem.transaction.transactionDay?.description == secondItem.transaction.transactionDay?.description else {
            return false
        }
        return true
    }
    
    func item(at point: CGPoint) -> Int {
        let horizontalOffSet = point.x
        let cellWidth = layout.itemSize.width + 16
        let horizontalCenter = cellWidth / 2
        return Int(horizontalOffSet + horizontalCenter) / Int(cellWidth)
    }
    
    func getCell(index: Int) -> CardTransactionCollectionViewCell? {
        let indexPath = IndexPath(item: index, section: 0)
        UIView.performWithoutAnimation {
            reloadItems(at: [indexPath])
        }
        return cellForItem(at: indexPath) as? CardTransactionCollectionViewCell
    }
}

// MARK: - Bind
private extension CardTransactionCollectoinView {
    func bind() {
        bindDidLoadTransactionSubject()
        bindDidEndDecelerating()
    }
    
    func bindDidEndDecelerating() {
        bindableDegate.scrollViewDidEndDecelerating
        .map { [unowned self] point in
            item(at: point)
        }.filter { [unowned self] nextPosition in
            currentPosition != nextPosition
        }.map { [unowned self] position in
            currentPosition = position
            return bindableDatasource.items[position]
        }.subscribe(didSelectTransactionSubject)
        .store(in: &subscriptions)

    }
    
    func bindDidLoadTransactionSubject() {
        didLoadTransactionSubject
            .tryMap { [unowned self] item -> (index: Int, item: CardTransactionViewItemRepresentable) in
                let index = try getIndexForItem(item)
                return (index, item)
            }.sink(receiveCompletion: {_ in }) { [unowned self] result in
                let cell = getCell(index: result.index)
                cell?.stateSubject.send(.item(result.item))
            }.store(in: &subscriptions)
    }
    
    func bindResizeCell(_ index: Int) {
        getCell(index: index)?.bannerView.resizeWithRatioSubject
            .sink { [unowned self] _ in
                self.updateLayout()
            }.store(in: &subscriptions)
    }
}

private extension CardTransactionCollectoinView {
    typealias Binds = (IndexPath, UICollectionViewCell) -> Void?

    class Datasource<Item>: NSObject, UICollectionViewDataSource {
        var items: [Item] = []
        var bind: Binds?
        var reuseIdentifier: String = ""
        
        func setItems<Element>(_ elements: [Element]) {
            items = elements as? [Item] ?? []
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            bind?(indexPath, cell)
            return cell
        }
    }
}

private extension CardTransactionCollectoinView {
    class Delegate: NSObject, UICollectionViewDelegate {
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollViewDidScroll.send(scrollView.contentOffset)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }
    }
}
