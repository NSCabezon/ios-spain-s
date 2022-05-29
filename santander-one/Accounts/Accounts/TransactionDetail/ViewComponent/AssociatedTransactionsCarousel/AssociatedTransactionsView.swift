//
//  AssociatedTransactionsView.swift
//  Account
//
//  Created by Tania Castellano Brasero on 23/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol AssociatedTransactionsViewDelegate: AnyObject {
    func didSelectTransaction(_ viewModel: AssociatedTransactionViewModel)
}

final class AssociatedTransactionsView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    weak var associatedTransactionDelegate: AssociatedTransactionsViewDelegate?
    private var associatedTransactions: [AssociatedTransactionViewModel] = []
    private let cellSpacing: CGFloat = 16
    private let cellWidth: CGFloat = 207
    private let cellHeight: CGFloat = 176
    private let collectionHeight: CGFloat = 260
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.view?.backgroundColor = UIColor.blueAnthracita
        self.heightConstraint.constant = collectionHeight
        self.setTitle()
        self.setInfo()
        self.setupCollectionView()
        self.setAccessibilityIdentifiers()
    }
    
    public func setViewModels(_ viewModels: [AssociatedTransactionViewModel]) {
        self.heightConstraint.constant = viewModels.isEmpty ? 0 : collectionHeight
        self.associatedTransactions = viewModels
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(CGPoint(x: -cellSpacing, y: 0), animated: true)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

private extension AssociatedTransactionsView {
    func setTitle() {
        self.titleLabel.textColor = .white
        self.titleLabel.configureText(withKey: "transactionDetail_title_related",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 15)))
    }
    
    func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func setInfo() {
        self.infoImageView.image = Assets.image(named: "icnInfoWhite")
        self.infoImageView.isUserInteractionEnabled = true
        self.infoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoPressed)))
    }
    
    @objc func infoPressed() {
        var conf = BubbleLabelConfiguration.defaultConfiguration()
        conf.leftMargin = 51.0
        BubbleLabelView.startWith(associated: self.infoImageView,
                                  text: localized("transaction_tooltip_related"),
                                  position: .bottom,
                                  configuration: conf)
    }
}

private extension AssociatedTransactionsView {
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityAccountTransaction.relatedCarouselTitle
    }
        
    func setupCollectionView() {
        let nib = UINib(nibName: AssociatedTransactionCollectionViewCell.identifier, bundle: .module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: AssociatedTransactionCollectionViewCell.identifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.blueAnthracita
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: cellSpacing, bottom: 0, right: cellSpacing)
        self.setCollectionViewFlowLayout()
        self.collectionView.reloadData()
    }
}

extension AssociatedTransactionsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.associatedTransactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssociatedTransactionCollectionViewCell.identifier, for: indexPath)
        let viewModel = self.associatedTransactions[indexPath.row]
        (cell as? AssociatedTransactionCollectionViewCell)?.setViewModel(viewModel)
        return cell
    }
}

extension AssociatedTransactionsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.associatedTransactions[indexPath.row]
        self.associatedTransactionDelegate?.didSelectTransaction(viewModel)
    }
}
