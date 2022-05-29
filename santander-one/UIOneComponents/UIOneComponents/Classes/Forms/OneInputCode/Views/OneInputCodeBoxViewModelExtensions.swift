//
//  OneInputCodeBoxViewModelExtensions.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 2/3/22.
//

import CoreFoundationLib

extension OneInputCodeBoxViewStatus {
    var externalBorderColor: UIColor {
        switch self {
        case .deselected:
            return .oneBrownGray
        case .selected:
            return .oneDarkTurquoise
        case .error:
            return .oneSantanderRed
        }
    }
    
    var internalBorderColor: UIColor {
        switch self {
        case .deselected, .error:
            return .oneBrownGray
        case .selected:
            return .oneDarkTurquoise
        }
    }
}
