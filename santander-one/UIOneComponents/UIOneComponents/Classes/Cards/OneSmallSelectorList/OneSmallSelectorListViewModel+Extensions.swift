//
//  OneSmallSelectorListViewModel+Extensions.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 10/1/22.
//

import CoreFoundationLib

public extension OneSmallSelectorListViewModel.Status {
    var borderWidth: CGFloat {
        switch self {
        case .inactive:
            return 1.0
        case .activated:
            return .zero
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .inactive:
            return .white
        case .activated:
            return UIColor.oneTurquoise.withAlphaComponent(0.07)
        }
    }

    var leftTextColor: UIColor {
        switch self {
        case .inactive:
            return UIColor.oneLisboaGray
        case .activated:
            return UIColor.oneDarkTurquoise
        }
    }
    
    var leftTextFont: UIFont {
        switch self {
        case .inactive:
            return .typography(fontName: .oneB300Regular)
        case .activated:
            return .typography(fontName: .oneB300Bold)
        }
    }
}
