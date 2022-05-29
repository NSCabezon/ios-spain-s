//
//  IntExtension.swift
//  BranchLocator
//
//  Created by Daniel Rincon on 02/07/2019.
//

import Foundation

extension Int {

    func getDayStringFromInt() -> String {
        switch self {
        case 6:
            return localizedString("bl_sunday")
        case 0:
            return localizedString("bl_monday")
        case 1:
            return localizedString("bl_tuesday")
        case 2:
            return localizedString("bl_wednesday")
        case 3:
            return localizedString("bl_thursday")
        case 4:
            return localizedString("bl_friday")
        case 5:
            return localizedString("bl_saturday")
        default:
            return ""
        }
    }

}
