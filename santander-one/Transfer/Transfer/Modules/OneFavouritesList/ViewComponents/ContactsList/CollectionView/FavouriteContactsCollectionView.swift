//
//  FavouriteContactsCollectionView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 10/1/22.
//

import UI
import UIKit
import OpenCombine

final class FavouriteContactsCollectionView: UICollectionView {
    private let bindableDelegate = Delegate()
    private let bindableDatasource = Datasource()
    private let layout = UICollectionViewFlowLayout()
 
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension FavouriteContactsCollectionView {
    func setupView() {
        dataSource = bindableDatasource
        delegate = bindableDelegate
        layout.scrollDirection = .vertical
        collectionViewLayout = layout
        backgroundColor = .white
    }
    
    func getIndexForViewModel(_ viewModel: FavouriteContact) throws -> Int {
        guard let index = bindableDatasource.items.firstIndex(where: { return $0 == viewModel }) else {
            throw NSError()
        }
        return index
    }
}

extension FavouriteContactsCollectionView {
    func registerCell(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }

    func bind<Cell: UICollectionViewCell>(identifier: String, cellType: Cell.Type, items: [FavouriteContact], completion: @escaping (IndexPath, Cell?, FavouriteContact) -> Void) {
        registerCell(identifier)
        bindableDatasource.reuseIdentifier = identifier
        bindableDatasource.setItems(items)
        bindableDatasource.bind = { (indexPath, cell) in
            completion(indexPath, cell as? Cell, items[indexPath.row] )
        }
    }
}

private extension FavouriteContactsCollectionView {
    typealias Binds = (IndexPath, UICollectionViewCell) -> Void?

    class Datasource: NSObject, UICollectionViewDataSource {
        var items: [FavouriteContact] = []
        var bind: Binds?
        var reuseIdentifier: String = ""
        
        func setItems(_ elements: [FavouriteContact]) {
            items = elements
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

private extension FavouriteContactsCollectionView {
    class Delegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        private let cellHeight: CGFloat = 140
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: self.cellHeight)
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: String(describing: FavouriteContactsFooter.self),
                    for: indexPath
                )
            default:
                return UICollectionReusableView()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 56)
        }
    }
}
