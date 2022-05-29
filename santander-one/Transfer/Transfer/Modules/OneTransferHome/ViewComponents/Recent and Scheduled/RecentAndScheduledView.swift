//
//  RecentAndScheduledView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 14/12/21.
//

import CoreFoundationLib
import UIKit
import UI

final class RecentAndScheduledView: XibView {
    
    @IBOutlet private weak var emptyView: RecentAndScheduledEmptyView!
    @IBOutlet private weak var loadingView: RecentAndScheduledLoadingView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var historicalButton: UIButton!
    @IBOutlet private weak var recentAndScheduledCollectionView: RecentAndScheduledCollectionView!
    var didSelectSeeHistoricalButton: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAppearance()
    }
    
    @IBAction private func didTapOnSeeHistoricalButton(_ sender: Any) {
        didSelectSeeHistoricalButton?()
    }
    
    func set(datasource: RecentAndScheduledDataSource) {
        recentAndScheduledCollectionView.dataSource = datasource
        recentAndScheduledCollectionView.delegate = datasource
        recentAndScheduledCollectionView.reloadData()
    }
    
    func setView(_ isEmpty: Bool) {
        self.loadingView.isHidden = true
        if isEmpty {
            emptyView.isHidden = false
            historicalButton.isHidden = true
        } else {
            recentAndScheduledCollectionView.reloadData()
        }
    }
}

private extension RecentAndScheduledView {
    func setAppearance() {
        emptyView.isHidden = true
        titleLabel.font = .typography(fontName: .oneH200Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: "transfer_title_recent")
        if #available(iOS 15.0, *) {
            historicalButton.configuration = nil
        }
        historicalButton.titleLabel?.font = .typography(fontName: .oneB200Bold)
        historicalButton.setTitleColor(.oneDarkTurquoise, for: .normal)
        historicalButton.setTitleColor(.oneDarkEmerald, for: .highlighted)
        historicalButton.setTitle(localized("transfer_label_seeHistorical"), for: .normal)
        setAccesibilityIdentifiers()
    }
    
    func setAccesibilityIdentifiers() {
        historicalButton.accessibilityIdentifier = AccessibilityRecentAndScheduled.recentAndScheduledButton
        titleLabel.accessibilityIdentifier = AccessibilityRecentAndScheduled.recentAndScheduledTitleLabel
    }
}
