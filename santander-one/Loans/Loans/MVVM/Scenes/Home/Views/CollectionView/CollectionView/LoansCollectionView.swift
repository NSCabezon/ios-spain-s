//
//  LoansCollectionView.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/10/19.
//
import UI
import UIKit
import OpenCombine

final class LoansCollectionView: UICollectionView {
    private var layout = ZoomAndSnapFlowLayout()
    private let bindableDegate = Delegate()
    private let bindableDatasource = Datasource<Loan>()
    private var anySubscriptions = Set<AnyCancellable>()
    let positionChangesSubject = PassthroughSubject<Int, Never>()
    let didSelectLoanSubject = PassthroughSubject<Loan, Never>()
    let detailSubject = PassthroughSubject<Loan, Never>()
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
        self.didSelectLoanSubject.send(viewModel)
    }
    
    func scrollTo(_ viewModel: Loan) {
        guard let index = try? getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        self.currentPosition = indexPath.row
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
}

private extension LoansCollectionView {
    func setupView() {
        addLayout()
        decelerationRate = .fast
        backgroundColor = .skyGray
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = bindableDatasource
        delegate = bindableDegate
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        layout.setMinimumLineSpacing(16)
        layout.setItemSize(CGSize(width: itemWidth, height: 172))
        layout.setZoom(0)
        collectionViewLayout = layout
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    func item(at point: CGPoint) -> Int {
        let horizontalOffSet = point.x
        let cellWidth = layout.itemSize.width + 16
        let horizontalCenter = cellWidth / 2
        return Int(horizontalOffSet + horizontalCenter) / Int(cellWidth)
    }
    
    func getIndexForViewModel(_ viewModel: Loan) throws -> Int {
        guard let index = bindableDatasource.items.firstIndex(where: { return $0 == viewModel }) else {
            throw NSError()
        }
        return index
    }
}

private extension LoansCollectionView {
    func bind() {
        bindableDegate.scrollViewDidScroll
        .map {[unowned self] point in
            self.item(at: point)
        }.subscribe(positionChangesSubject)
        .store(in: &anySubscriptions)
        
        bindableDegate.scrollViewDidEndDecelerating
        .map {[unowned self] point in
            self.item(at: point)
        }.filter {[unowned self] nextPosition in
            self.currentPosition != nextPosition
        }.map {[unowned self] position in
            self.currentPosition = position
            return self.bindableDatasource.items[position]
        }.subscribe(didSelectLoanSubject)
        .store(in: &anySubscriptions)
        
        detailSubject
        .tryMap {[unowned self] viewModel -> (index: Int, viewModel: Loan) in
            let index = try self.getIndexForViewModel(viewModel)
            return (index, viewModel)
        }.sink(receiveCompletion: {_ in }) { [unowned self] result in
            let indexPath = IndexPath(item: result.index, section: 0)
            UIView.performWithoutAnimation {
                self.reloadItems(at: [indexPath])
            }
            let cell = self.cellForItem(at: indexPath) as? LoanCollectionViewCell
            cell?.animateProgress(withViewModel: result.viewModel)
        }.store(in: &anySubscriptions)
    }
}

extension LoansCollectionView {
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

private extension LoansCollectionView {
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

private extension LoansCollectionView {
    class Delegate: NSObject, UICollectionViewDelegate {
        let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
        let scrollViewDidEndDecelerating = PassthroughSubject<CGPoint, Never>()
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollViewDidScroll.send(scrollView.contentOffset)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.scrollViewDidEndDecelerating.send(scrollView.contentOffset)
        }
    }
}
