//
//  RecentAndScheduledCollectionView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 14/12/21.
//

import UIKit

final class RecentAndScheduledCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        setupAvailableContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAvailableContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAvailableContent()
    }
}

private extension RecentAndScheduledCollectionView {
    func setupAvailableContent() {
        showsHorizontalScrollIndicator = false
        setLayout()
        registerCells()
    }
    
    func setLayout() {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: 200, height: 146)
        flowLayout?.scrollDirection = .horizontal
        flowLayout?.minimumLineSpacing = 8.0
        flowLayout?.sectionInset = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
    }
    
    func registerCells() {
        register(
            UINib(
                nibName: String(describing: RecentAndScheduledCollectionViewCell.self),
                bundle: .module
            ),
            forCellWithReuseIdentifier: String(describing: RecentAndScheduledCollectionViewCell.self)
        )
    }
}
