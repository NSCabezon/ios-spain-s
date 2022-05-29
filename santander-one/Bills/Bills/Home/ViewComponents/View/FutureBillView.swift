//
//  FutureBillView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import Foundation
import CoreFoundationLib
import UI

final class FutureBillView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: FutureBillCollectionView!
    @IBOutlet weak var topLineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.appearance()
        self.setAccessibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appearance()
        self.setAccessibilityIdentifiers()
    }
    
    func setDelegate(_ delegate: FutureBillCollectionDatasourceDelegate) {
        self.collectionView.setDelegate(delegate: delegate)
    }
    
    func setFutureBillState(_ state: ViewState<[FutureBillViewModel]>) {
        self.collectionView.didStateChanged(state)
    }
    
    func disableTimeLine() {
        self.collectionView.disableTimeLine()
    }
}

private extension FutureBillView {
    func appearance() {
        self.topLineView.backgroundColor = .mediumSkyGray
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "receiptsAndTaxes_title_nextReceipts")
    }
    
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityBills.FutureBillView.nextBillsTitle
    }
}
