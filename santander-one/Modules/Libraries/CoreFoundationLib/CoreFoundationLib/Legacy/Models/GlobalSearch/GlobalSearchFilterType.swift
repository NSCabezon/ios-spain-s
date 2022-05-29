//
//  GlobalSearchFilterType.swift
//  Models
//
//  Created by alvola on 25/08/2020.
//

public enum GlobalSearchFilterType: Int {
    case all = 0
    case movement
    case action
    case help
    
    public var sectionTitle: String {
        switch self {
        case .all:
            return "search_tab_all"
        case .movement:
            return "search_tab_movements"
        case .action:
            return "search_tab_actions"
        case .help:
            return "search_tab_help"
        }
    }
}
