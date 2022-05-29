//
//  SendMoneyDestinationAccountLastTransfersCollectionView.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 29/9/21.
//

import UIKit
import CoreFoundationLib

private enum LayoutConstants {
    static let cardSize: CGSize = CGSize(width: 200, height: 145)
    static let minimumLineSpacing: CGFloat = 15.0
    static let minimumInteritemSpacing: CGFloat = 8.0
}

public protocol SendMoneyDestinationAccountLastTransfersCollectionViewDelegate: AnyObject {
    func didSelectPastTransfer(index: Int)
}

public final class SendMoneyDestinationAccountLastTransfersCollectionView: UICollectionView {

    weak var collectionDelegate: SendMoneyDestinationAccountLastTransfersCollectionViewDelegate?

    private var rows: [OnePastTransferViewModel] = [] {
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
}

// MARK: - Public methods
public extension SendMoneyDestinationAccountLastTransfersCollectionView {
    func setRows(_ rows: [OnePastTransferViewModel]) {
        self.rows = rows
    }

    func reloadLastTransfers() {
        self.reloadData()
    }

    func scrollToSelectedLastTransfer() {
        if let index = self.rows.firstIndex(where: { $0.cardStatus == .selected }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.reloadData()
            self.layoutIfNeeded()
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - Private methods
private extension SendMoneyDestinationAccountLastTransfersCollectionView {
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
        flowlayout.itemSize = LayoutConstants.cardSize
        flowlayout.minimumLineSpacing = LayoutConstants.minimumLineSpacing
        flowlayout.minimumInteritemSpacing = LayoutConstants.minimumInteritemSpacing
        flowlayout.scrollDirection = .horizontal
        flowlayout.sectionInset = UIEdgeInsets(
            top: oneSpacing(type: .oneSizeSpacing16),
            left: oneSpacing(type: .oneSizeSpacing16),
            bottom: oneSpacing(type: .oneSizeSpacing16),
            right: oneSpacing(type: .oneSizeSpacing16)
        )
    }

    func registerCells() {
        self.register(type: SendMoneyDestinationAccountLastTransferCollectionViewCell.self, bundle: Bundle.module)
    }
}

// MARK: - UICollectionView delegate and datasource conformance
extension SendMoneyDestinationAccountLastTransfersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rows.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "SendMoneyDestinationAccountLastTransferCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? SendMoneyDestinationAccountLastTransferCollectionViewCell
        cell?.setViewModel(rows[indexPath.row])
        return cell ?? UICollectionViewCell()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionDelegate?.didSelectPastTransfer(index: indexPath.row)
    }
}
