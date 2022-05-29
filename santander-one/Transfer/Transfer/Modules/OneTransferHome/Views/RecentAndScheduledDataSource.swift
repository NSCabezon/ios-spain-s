//
//  RecentAndScheduledDataSource.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 14/12/21.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIKit
import UIOneComponents

final class RecentAndScheduledDataSource: NSObject {
    let didSelectRowAtSubject = PassthroughSubject<[OnePastTransferViewModel], Never>()
    weak var delegate: OnePastTransferCardViewDelegate?
    var list: [OnePastTransferViewModel] = []
    var didSwipe: (() -> Void)?

    init(delegate: OnePastTransferCardViewDelegate) {
        self.delegate = delegate
    }
    
    public func setList(_ list: [OnePastTransferViewModel]) {
        self.list = list
    }
}

extension RecentAndScheduledDataSource: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecentAndScheduledCollectionViewCell.self), for: indexPath)
        (cell as? RecentAndScheduledCollectionViewCell)?.set(model: list[indexPath.item])
        if let delegate = delegate {
            (cell as? RecentAndScheduledCollectionViewCell)?.set(delegate: delegate)
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didSwipe?()
    }
}
