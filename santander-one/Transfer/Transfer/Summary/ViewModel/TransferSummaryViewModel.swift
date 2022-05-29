//
//  TransferSummaryViewModel.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 1/13/20.
//

import Foundation
import CoreFoundationLib

struct TransferSummaryViewModel {
    var contentElements: [SummaryContentItemViewModel]
    var footerElements: [SummaryFooterItemViewModel]
}

struct SummaryContentItemViewModel {
    
    enum Position {
        case unknown
        case last
    }
    
    let title: String
    let subTitle: NSAttributedString
    let info: String?
    
    init(title: String, subTitle: NSAttributedString, info: String? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.info = info
    }
    
    init(title: String, subTitle: String, info: String? = nil) {
        self.title = title
        self.subTitle = NSAttributedString(string: subTitle)
        self.info = info
    }
}

struct SummaryFooterItemViewModel {
    let image: String
    let title: String
    let action: () -> Void
}

struct SummaryActionViewModel: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let action: () -> Void
    
    init(image: String, title: String, action: @escaping () -> Void) {
        self.viewType = .defaultButton(DefaultActionButtonViewModel(
            title: title,
            imageKey: image,
            titleAccessibilityIdentifier: "",
            imageAccessibilityIdentifier: image
        ))
        self.action = action
    }
}

struct SummaryHeaderViewModel {
    let image: String
    let title: String
    let description: String
}
