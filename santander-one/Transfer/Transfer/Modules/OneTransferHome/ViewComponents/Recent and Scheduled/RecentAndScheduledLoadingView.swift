//
//  RecentAndScheduledLoadingView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 23/12/21.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class RecentAndScheduledLoadingView: XibView {
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAppearance()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.setNewJumpingLoader()
    }
}

private extension RecentAndScheduledLoadingView {
    func setAppearance() {
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: "generic_popup_loadingContent")
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        subtitleLabel.textColor = .oneLisboaGray
        subtitleLabel.configureText(withKey: "loading_label_moment")
        setAccesisibilityIdentifiers()
    }
    
    func setAccesisibilityIdentifiers() {
        imageView.accessibilityIdentifier = AccessibilityRecentAndScheduled.loadingImage
        titleLabel.accessibilityIdentifier = AccessibilityRecentAndScheduled.loadingTitleLabel
        subtitleLabel.accessibilityIdentifier = AccessibilityRecentAndScheduled.loadingSubTitleLabel
        view?.accessibilityIdentifier = AccessibilityRecentAndScheduled.loadingView
    }
}
