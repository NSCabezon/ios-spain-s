//
//  RecentAndScheduledEmptyView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 23/12/21.
//

import Foundation
import UI
import CoreFoundationLib

final class RecentAndScheduledEmptyView: XibView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAppearance()
    }
}

private extension RecentAndScheduledEmptyView {
    func setAppearance() {
        imageView.setLeavesLoader()
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: "generic_label_emptyListResult")
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        subtitleLabel.textColor = .oneLisboaGray
        subtitleLabel.configureText(withKey: "transfer_text_emptyView_notDone")
        setAccesisibilityIdentifiers()
    }
    
    func setAccesisibilityIdentifiers() {
        imageView.accessibilityIdentifier = AccessibilityRecentAndScheduled.emptyImage
        titleLabel.accessibilityIdentifier = AccessibilityRecentAndScheduled.emptyTitleLabel
        subtitleLabel.accessibilityIdentifier = AccessibilityRecentAndScheduled.emptySubTitleLabel
        view?.accessibilityIdentifier = AccessibilityRecentAndScheduled.emptyView
    }
}
