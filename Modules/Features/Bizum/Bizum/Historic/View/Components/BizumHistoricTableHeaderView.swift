//
//  BizumHistoricTableHeaderView.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 05/11/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class BizumHistoricTableHeaderView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .lisboaGray
            titleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelListHeaderTitle
        }
    }
        
    func setTitle(results: Int) {
        let key = results == 1 ? "globalSearch_text_result_one" : "globalSearch_text_result_other"
        let spholder = StringPlaceholder(.number, String(results))
        let textConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 17))
        titleLabel.configureText(withLocalizedString: localized(key, [spholder]),
                            andConfiguration: textConfiguration)
    }
}
