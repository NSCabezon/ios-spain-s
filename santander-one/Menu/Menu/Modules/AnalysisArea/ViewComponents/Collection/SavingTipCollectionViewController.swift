//
//  SavingTipCollectionViewController.swift
//  Menu
//
//  Created by David Gálvez Alonso on 20/03/2020.
//

import Foundation

struct SavingTipCollectionInfo {
    let cellClass: String
    let info: SavingTipViewModel
}

protocol SavingTipCollectionViewControllerDelegate: AnyObject {
    func didPressCell(index: Int)
}

protocol SavingTipCollectionViewDelegate: AnyObject {
    func scrollViewDidEndDecelerating()
}

final class SavingTipCollectionViewController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var controlledCollectionView: UICollectionView?
    weak var delegate: SavingTipCollectionViewControllerDelegate?
    weak var collectionViewDelegate: SavingTipCollectionViewDelegate?
    var currentContentOffset: CGPoint?
    
    var cellsInfo: [SavingTipCollectionInfo] = [] {
        didSet {
            controlledCollectionView?.reloadData()
        }
    }
        
    init(collectionView: UICollectionView?) {
        super.init()
        controlledCollectionView = collectionView
        registerCellClasses()
        controlledCollectionView?.delegate = self
        controlledCollectionView?.dataSource = self
        controlledCollectionView?.clipsToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentCellInfo = cellsInfo[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentCellInfo.cellClass, for: indexPath)
        
        (cell as? SavingCollectionViewCell)?.setTextCell(currentCellInfo.info.textButton)
        (cell as? SavingCollectionViewCell)?.setImageCell(currentCellInfo.info.imageUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didPressCell(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 232, height: collectionView.frame.height)
    }
    
    func setCellInfo(savingTips: [SavingTipViewModel]) {
        cellsInfo = savingTips.map {SavingTipCollectionInfo(cellClass: "SavingCollectionViewCell", info: $0)}
    }
}

// MARK: - Private methods

private extension SavingTipCollectionViewController {
    
    func registerCellClasses() {
        controlledCollectionView?.register(UINib(nibName: "SavingCollectionViewCell", bundle: Bundle.module!), forCellWithReuseIdentifier: "SavingCollectionViewCell")
    }
}

extension SavingTipCollectionViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionViewDelegate?.scrollViewDidEndDecelerating()
    }
}
