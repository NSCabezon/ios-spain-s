//
//  TricksCollectionViewController.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 09/07/2020.
//

import Foundation

public protocol TricksCollectionViewControllerDelegate: AnyObject {
    func didPressTrick(index: Int)
}

public protocol TricksCollectionViewDelegate: AnyObject {
    func scrollViewDidEndDecelerating()
}

public final class TricksCollectionViewController: NSObject {
    weak var collectionView: UICollectionView?
    weak var controllerDelegate: TricksCollectionViewControllerDelegate?
    weak var collectionViewDelegate: TricksCollectionViewDelegate?
    var currentContentOffset: CGPoint?
    let cellIdentifiers = [
        TrickCollectionViewCell.identifier
    ]
    
    var viewModels: [TrickViewModel] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
        
    public init(collectionView: UICollectionView?) {
        super.init()
        self.setCollectionView(collectionView: collectionView)
    }
    
    public func setViewModels(_ viewModels: [TrickViewModel]) {
        self.viewModels = viewModels
    }
}

extension TricksCollectionViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrickCollectionViewCell.identifier, for: indexPath
            ) as? TrickCollectionViewCell else { return UICollectionViewCell() }
        cell.setViewModel(self.viewModels[indexPath.row])
        return cell
    }
}

extension TricksCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.controllerDelegate?.didPressTrick(index: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 232, height: collectionView.frame.height)
    }
}

private extension TricksCollectionViewController {
    
    func setCollectionView(collectionView: UICollectionView?) {
        self.collectionView = collectionView
        self.registerCellClasses()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.clipsToBounds = false
    }
    
    func registerCellClasses() {
        self.cellIdentifiers.forEach {
            self.collectionView?.register(
                UINib(nibName: $0, bundle: .module), forCellWithReuseIdentifier: $0
            )
        }
    }
}

extension TricksCollectionViewController {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionViewDelegate?.scrollViewDidEndDecelerating()
    }
}
