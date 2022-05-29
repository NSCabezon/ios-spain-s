//
//  BottomSheetTwoLabelsView.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 9/2/22.
//

import Foundation
import UI
import UIKit
import UIOneComponents
import CoreFoundationLib

final class BottomSheetTwoLabelsView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.text = title.text
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.text = subtitle.text
    }
}

private extension BottomSheetTwoLabelsView {
    func setupView() {
        setupLabels()
        setAccessibilityIdentifiers()
    }
    
    func setupLabels() {
        titleLabel.font = .typography(fontName: .oneH300Bold)
        titleLabel.textColor = .oneLisboaGray
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        subtitleLabel.textColor = .oneLisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTitleTooltipExpenses
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTextTooltipExpenses
    }
}
