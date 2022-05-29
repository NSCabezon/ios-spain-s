//
//  FundsHomeCollectionView.swift
//  Funds
//

import UI
import UIKit
import OpenCombine

private enum FundsHomeCollectionConstants {
    static let fundHeaderCellHeight: CGFloat = 157
    static let fundHeaderCellWithProfitabilityHeight: CGFloat = 212
    static let fundHeaderCellTopWithoutOwnerView: CGFloat = 4
    static let fundHeaderCellTopWithOwnerView: CGFloat = 14
    static let carouselMinimumLineSpacing: CGFloat = 8
    static let carouselCellProporcionality: CGFloat = 0.88
}

final class FundsHomeCollectionView: UICollectionView {
    private var layout = ZoomAndSnapFlowLayout()
    private let bindableDegate = Delegate()
    private let bindableDatasource = Datasource<Fund>()
    private var anySubscriptions = Set<AnyCancellable>()
    private var heightConstraint: NSLayoutConstraint?
    let positionChangesSubject = PassthroughSubject<Int, Never>()
    let didSelectFundsSubject = PassthroughSubject<Fund, Never>()
    let detailSubject = PassthroughSubject<Fund, Never>()
    var currentPositionChanged: (() -> Void)?
    var currentPosition = 0 {
        didSet {
            currentPositionChanged?()
        }
    }

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: self.layout)
        self.setupView()
        self.bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.bind()
    }

    func scrollTo(_ index: IndexPath) {
        guard let viewModel = self.bindableDatasource.items[safe: index.item] else { return }
        self.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        self.currentPosition = index.row
        self.didSelectFundsSubject.send(viewModel)
    }

    func scrollTo(_ viewModel: Fund) {
        guard let index = try? self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        self.currentPosition = indexPath.row
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.didSelectFundsSubject.send(viewModel)
    }
}

private extension FundsHomeCollectionView {
    func setupView() {
        self.addDefaultLayout()
        self.decelerationRate = .fast
        self.backgroundColor = .white
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.dataSource = self.bindableDatasource
        self.delegate = self.bindableDegate
    }

    func addDefaultLayout() {
        self.setLayout()
        self.collectionViewLayout = self.layout
    }

    func setLayout() {
        let itemWidth = self.getProportionalItemSizeWidth()
        let itemHeight = self.getProportionalItemSizeHeight()
        self.layout.setMinimumLineSpacing(FundsHomeCollectionConstants.carouselMinimumLineSpacing)
        self.layout.setItemSize(CGSize(width: itemWidth, height: itemHeight))
        self.layout.setZoom(0)
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: itemHeight)
    }

    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * FundsHomeCollectionConstants.carouselCellProporcionality
    }

    func getProportionalItemSizeHeight() -> CGFloat {
        guard let viewModel = bindableDatasource.items.first else { return 0.0 }
        var fundHeaderCellHeight: CGFloat = viewModel.isProfitabilityDataEnabled ? FundsHomeCollectionConstants.fundHeaderCellWithProfitabilityHeight : FundsHomeCollectionConstants.fundHeaderCellHeight
        fundHeaderCellHeight += viewModel.isOwnerViewEnabled ? FundsHomeCollectionConstants.fundHeaderCellTopWithOwnerView : FundsHomeCollectionConstants.fundHeaderCellTopWithoutOwnerView
        return fundHeaderCellHeight
    }

    func item(at point: CGPoint) -> Int {
        let horizontalOffSet = point.x
        let cellWidth = self.layout.itemSize.width + FundsHomeCollectionConstants.carouselMinimumLineSpacing
        let horizontalCenter = cellWidth / 2
        return Int(horizontalOffSet + horizontalCenter) / Int(cellWidth)
    }

    func getIndexForViewModel(_ viewModel: Fund) throws -> Int {
        guard let index = self.bindableDatasource.items.firstIndex(where: { return $0 == viewModel }) else {
            throw NSError()
        }
        return index
    }
}

private extension FundsHomeCollectionView {
    func bind() {
        self.bindableDegate
            .scrollViewDidScroll
            .map {[unowned self] point in
                let selectedItem = self.item(at: point)
                self.bindableDatasource.selectedItem = selectedItem
                self.reloadData()
                return selectedItem
            }.subscribe(self.positionChangesSubject)
            .store(in: &self.anySubscriptions)

        self.bindableDegate
            .scrollViewDidEndDecelerating
            .map {[unowned self] point in
                self.item(at: point)
            }.filter {[unowned self] nextPosition in
                self.currentPosition != nextPosition
            }.map {[unowned self] position in
                self.currentPosition = position
                self.bindableDatasource.selectedItem = position
                self.reloadData()
                return self.bindableDatasource.items[position]
            }.subscribe(self.didSelectFundsSubject)
            .store(in: &self.anySubscriptions)

        self.bindableDegate
            .didSelectItem
            .sink(receiveValue: {[unowned self] indexPath in
                self.scrollTo(indexPath)
            })
            .store(in: &self.anySubscriptions)
    }
}

extension FundsHomeCollectionView {
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }

    func bind<Element, Cell: UICollectionViewCell>(identifier: String, cellType: Cell.Type, items: [Element], completion: @escaping (IndexPath, Cell?, Element) -> Void) {
        self.registerCell(identifier)
        self.bindableDatasource.reuseIdentifier = identifier
        self.bindableDatasource.setItems(items)
        self.bindableDatasource.selectedItem = self.currentPosition
        self.bindableDatasource.bind = { (indexPath, cell) in
            completion(indexPath, cell as? Cell, items[indexPath.row] )
        }
        self.setLayout()
        self.addConstraint(self.heightConstraint ?? NSLayoutConstraint())
    }
}

private extension FundsHomeCollectionView {
    typealias Binds = (IndexPath, UICollectionViewCell) -> Void?

    class Datasource<Item>: NSObject, UICollectionViewDataSource {
        var items: [Item] = []
        var bind: Binds?
        var reuseIdentifier: String = ""
        var selectedItem: Int = 0

        func setItems<Element>(_ elements: [Element]) {
            self.items = elements as? [Item] ?? []
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath)
            cell.isSelected = indexPath.row == self.selectedItem
            self.bind?(indexPath, cell)
            return cell
        }
    }
}

private extension FundsHomeCollectionView {
    class Delegate: NSObject, UICollectionViewDelegate {
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()
        let didSelectItem = PassthroughSubject<IndexPath, Never>()

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.scrollViewDidScroll.send(scrollView.contentOffset)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.didSelectItem.send(indexPath)
        }
    }
}
