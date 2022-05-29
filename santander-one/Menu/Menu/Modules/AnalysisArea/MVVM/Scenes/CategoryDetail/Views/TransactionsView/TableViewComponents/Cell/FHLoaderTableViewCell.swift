//
//  FHLoaderTableViewCell.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 12/4/22.
//

import UIKit
import CoreFoundationLib
import UIOneComponents
import UI

class FHLoaderTableViewCell: UITableViewCell {
    @IBOutlet private weak var loaderImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    func showLoader() {
        loaderImageView.startAnimating()
    }
}

private extension FHLoaderTableViewCell {
    func configureView() {
        loaderImageView.setNewJumpingLoader(accessibilityIdentifier: AnalysisAreaAccessibility.analysisViewSmallLoader)
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.text = localized("analysis_loading_collectingInfo")
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        subtitleLabel.textColor = .oneLisboaGray
        subtitleLabel.text = localized("analisys_loading_soon")
    }
}
