//
//  SavingsHomeCollectionView.swift
//  Savings
//
//  Created by Adrian Escriche Martin on 17/2/22.
//
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

final class SavingsHomeCollectionView: UICollectionView {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    private var layout = ZoomAndSnapFlowLayout()
    private let bindableDegate = Delegate()
    private let bindableDatasource = Datasource<Savings>()
    private var anySubscriptions = Set<AnyCancellable>()
    let positionChangesSubject = PassthroughSubject<Int, Never>()
    let didSelectSavingsSubject = PassthroughSubject<Savings, Never>()
    let scrollViewDidEndScrollingAnimation = PassthroughSubject<CGPoint, Never>()
    let detailSubject = PassthroughSubject<Savings, Never>()
    var currentPosition = 0
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    func scrollTo(_ index: IndexPath) {
        guard let viewModel = bindableDatasource.items[safe: index.item] else { return }
        self.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        self.didSelectSavingsSubject.send(viewModel)
        self.currentPosition = index.row
    }
    
    func scrollTo(_ viewModel: Savings) {
        guard let index = try? getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        self.currentPosition = indexPath.row
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        configureScrollButtons()
        self.layoutIfNeeded()
        highlightCell(indexPath)
    }
    
    func updateCellHeight(_ height: CGFloat) {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: height))
    }
    
    func updatePendingField(_ pendingField: String) {
        let index = IndexPath(item: currentPosition, section: 0)
        let cell = self.cellForItem(at: index) as? SavingProductsHomeCollectionViewCell
        cell?.updatePendingField(pendingField)
        self.layoutIfNeeded()
    }
    
    func handleTapableIconCopyDetailCell(isTappable: Bool) {
        let index = IndexPath(item: currentPosition, section: 0)
        guard let cell = self.cellForItem(at: index) as? SavingProductsHomeCollectionViewCell else {
            return
        }
        cell.handleTapableIconCopyDetailCell(isTappable)
        self.layoutIfNeeded()
    }

    func updateColors() {
        self.configureScrollButtons()
        let index = IndexPath(row: currentPosition, section: 0)
        self.highlightCell(index)
    }
    
    @IBAction func collectionLeftScroll(_ sender: Any) {
        let newIndex = currentPosition - 1
        guard newIndex >= 0 else { return }
        self.currentPosition = newIndex
        self.scrollTo(IndexPath(row: newIndex, section: 0))
    }
    
    @IBAction func collectionRightScroll(_ sender: Any) {
        let newIndex = currentPosition + 1
        guard newIndex <= bindableDatasource.items.count else { return }
        self.currentPosition = newIndex
        self.scrollTo(IndexPath(row: newIndex, section: 0))
    }
    
    func getIndexForViewModel(_ viewModel: Savings) throws -> Int {
        guard let index = bindableDatasource.items.firstIndex(where: { return $0 == viewModel }) else {
            throw NSError()
        }
        return index
    }
    
    var orderedSubviews: [UIView] {
        subviews.sorted(by: { a, b in a.frame.origin.x < b.frame.origin.x  })
    }
}

private extension SavingsHomeCollectionView {
    func setupView() {
        addLayout()
        decelerationRate = .fast
        backgroundColor = .oneWhite
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = bindableDatasource
        delegate = bindableDegate
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        layout.setMinimumLineSpacing(8)
        layout.setItemSize(CGSize(width: itemWidth, height: 160))
        layout.setZoom(0)
        collectionViewLayout = layout
    }
    
    func configureScrollButtons() {
        leftButton.isHidden = false
        rightButton.isHidden = false
        leftButton.isHidden = currentPosition == 0
        rightButton.isHidden = currentPosition == (bindableDatasource.items.count - 1)
    }
    
    func highlightCell(_ indexPath: IndexPath) {
        for visibleCell in self.visibleCells {
            let cell = visibleCell as? SavingProductsHomeCollectionViewCell
            cell?.updateAdjacentCellColor()
        }
        let cell = self.cellForItem(at: indexPath) as? SavingProductsHomeCollectionViewCell
        cell?.updateMainCellColor()
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.85
    }
    
    func item(at point: CGPoint) -> Int {
        let horizontalOffSet = point.x
        let cellWidth = layout.itemSize.width + 8
        let horizontalCenter = cellWidth / 2
        return Int(horizontalOffSet + horizontalCenter) / Int(cellWidth)
    }
}

private extension SavingsHomeCollectionView {
    func bind() {
        bindableDegate
            .scrollViewDidScroll
            .map {[unowned self] point in
                return self.item(at: point)
            }.subscribe(positionChangesSubject)
            .store(in: &anySubscriptions)
        bindableDegate.scrollViewDidEndScrollingAnimation
            .subscribe(scrollViewDidEndScrollingAnimation)
            .store(in: &anySubscriptions)
        bindableDegate.scrollViewDidEndDecelerating
            .map {[unowned self] point in
                self.item(at: point)
            }.filter {[unowned self] nextPosition in
                self.currentPosition != nextPosition
            }.map {[unowned self] position in
                self.currentPosition = position
                return self.bindableDatasource.items[position]
            }.subscribe(didSelectSavingsSubject)
            .store(in: &anySubscriptions)
    }
}

extension SavingsHomeCollectionView {
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }

    func bind<Element, Cell: UICollectionViewCell>(identifier: String, cellType: Cell.Type, items: [Element], completion: @escaping (IndexPath, Cell?, Element) -> Void) {
        registerCell(identifier)
        bindableDatasource.reuseIdentifier = identifier
        bindableDatasource.setItems(items)
        bindableDatasource.bind = { (indexPath, cell) in
            completion(indexPath, cell as? Cell, items[indexPath.row] )
        }
    }
}

private extension SavingsHomeCollectionView {
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

private extension SavingsHomeCollectionView {
    class Delegate: NSObject, UICollectionViewDelegate {
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndScrollingAnimation = PassthroughSubject<CGPoint, Never>()
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollViewDidScroll.send(scrollView.contentOffset)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            self.scrollViewDidEndScrollingAnimation.send(scrollView.contentOffset)
        }
    }
}
