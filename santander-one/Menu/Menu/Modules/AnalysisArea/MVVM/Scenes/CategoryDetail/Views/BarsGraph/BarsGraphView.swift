//
//  BarsGraph.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 30/3/22.
//

import Foundation
import UI
import UIKit
import OpenCombine
import CoreFoundationLib

protocol BarsGraphViewRepresentable {
    var darkColor: UIColor { get }
    var color: UIColor { get }
    var columnDataList: [ColumnDataRepresentable] { get }
}

struct ColumnData {
    let amount: Double
    let secondAmount: Double?
    let text: String
    let index: Int?
    
    init(amount: Double, secondAmount: Double?, text: String, index: Int? = nil) {
        self.amount = amount
        self.secondAmount = secondAmount
        self.text = text
        self.index = index
    }
}

extension ColumnData: ColumnDataRepresentable {
    var mainAmount: Double {
        return self.amount
    }
    
    var secondaryAmount: Double? {
        secondAmount
    }
    
    var barText: String {
        text
    }
    
    var relativeIndex: Int? {
        index
    }
}

struct BarsGraphViewData {
    let normalColor: UIColor
    let boldColor: UIColor
    let dataList: [ColumnDataRepresentable]
}

extension BarsGraphViewData: BarsGraphViewRepresentable {
    var darkColor: UIColor {
        boldColor
    }
    
    var color: UIColor {
        normalColor
    }
    
    var columnDataList: [ColumnDataRepresentable] {
        dataList
    }
}

protocol ColumnDataRepresentable {
    var mainAmount: Double { get }
    var secondaryAmount: Double? { get }
    var barText: String { get }
    var relativeIndex: Int? { get }
}

enum BarsGraphViewState: State {
    case didTapBar(_ info: (index: Int, amount: Double, secondaryAmount: Double?))
}

final class BarsGraphView: XibView {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var leftChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronImageView: UIImageView!
    var representable: BarsGraphViewRepresentable?
    private var subscriptions: Set<AnyCancellable> = []
    private var subject = PassthroughSubject<BarsGraphViewState, Never>()
    public var publisher: AnyPublisher<BarsGraphViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    var dataSource: [BarsGraphViewRepresentable] = []
    var visibleCell: Int = 0 {
        didSet {
            updateIndex()
        }
    }
    var selectedBar: (cell: Int, bar: Int) = (0, 0)
    var selectedRelativeBar: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setInfo(representable: BarsGraphViewRepresentable) {
        self.representable = representable
        setDataSource()
        subscriptions.removeAll()
        selectedBar = (dataSource.count - 1, dataSource[dataSource.count - 1].columnDataList.count - 1)
        collectionView.reloadData()
        collectionView.isScrollEnabled = false
        collectionView.scrollToItem(at: IndexPath(item: (dataSource.count - 1), section: 0), at: .centeredHorizontally, animated: false)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeGraph(_:)))
        swipeRightGesture.direction = .right
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeGraph(_:)))
        swipeLeftGesture.direction = .left
        collectionView.addGestureRecognizer(swipeRightGesture)
        collectionView.addGestureRecognizer(swipeLeftGesture)
    }
}

private extension BarsGraphView {
    var cellIdentifier: String {
        String(describing: type(of: BarsGraphCollectionViewCell()))
    }
    
    func setupView() {
        let nib = UINib(nibName: cellIdentifier, bundle: .module)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupChevrons()
    }
    
    func setupChevrons() {
        leftChevronImageView.image = Assets.image(named: "oneIcnArrowRoundedLeft")
        rightChevronImageView.image = Assets.image(named: "oneIcnArrowTurquoiseRoundedRight")
        leftChevronImageView.isUserInteractionEnabled = true
        leftChevronImageView.tag = 0
        rightChevronImageView.tag = 1
        rightChevronImageView.isUserInteractionEnabled = true
        leftChevronImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLeftChevron)))
        rightChevronImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRightChevron)))
    }
    
    func setDataSource() {
        guard let representable = representable else { return }
        var indexes = [Int]()
        var dividedIndexes: [[Int]] = indexes.reversed().chunked(by: 5).map { $0.reversed() }
        var dividedData = representable.columnDataList.reversed().chunked(by: 5)
        dataSource = dividedData.reversed().map { BarsGraphViewData(normalColor: representable.color,
                                                     boldColor: representable.darkColor,
                                                     dataList: $0.reversed())
        }
    }
    
    func updateIndex() {
        let maxIndex = dataSource.count - 1
        rightChevronImageView.isHidden = visibleCell == maxIndex
        leftChevronImageView.isHidden = visibleCell == 0
    }
    
    @objc func didTapLeftChevron() {
        guard visibleCell > 0 else { return }
        let indexPath = IndexPath(item: visibleCell-1, section: 0)
        collectionView.scrollToItem(at: IndexPath(item: visibleCell-1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func didTapRightChevron() {
        guard visibleCell < dataSource.count-1 else { return }
        let indexPath = IndexPath(item: visibleCell-1, section: 0)
        collectionView.scrollToItem(at: IndexPath(item: visibleCell+1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func didSwipeGraph(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            didTapLeftChevron()
        } else if sender.direction == .left {
            didTapRightChevron()
        }
    }
    
    func bindCell(_ cell: BarsGraphCollectionViewCell) {
        cell.publisher
            .case { BarsGraphCollectionViewCellState.didTapBar }
            .sink { [unowned self] info in
                if selectedRelativeBar != info.index {
                    selectedRelativeBar = info.index
                    subject.send(.didTapBar((index: info.index, amount: info.mainAmount, secondaryAmount: info.secondAmount)))
                }
            }.store(in: &subscriptions)
        
        cell.publisher
            .case { BarsGraphCollectionViewCellState.didSelectCellIndex }
            .sink { [unowned self] barIndex in
                selectedBar.bar = barIndex
                selectedBar.cell = visibleCell
            }.store(in: &subscriptions)
    }
}

extension BarsGraphView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleCell = indexPath.row
        if let barsCell = cell as? BarsGraphCollectionViewCell {
            if indexPath.row == selectedBar.cell {
                barsCell.selectBarAtIndex(selectedBar.bar)
            } else {
                barsCell.unselectBars()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? BarsGraphCollectionViewCell {
            bindCell(cell)
            let source = dataSource[indexPath.row]
            cell.setCellInfo(representable: dataSource[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 356, height: collectionView.frame.height)
    }
}
