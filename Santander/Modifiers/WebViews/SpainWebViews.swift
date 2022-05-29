//
//  SpainWebViews.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 2/6/21.
//

enum SpainWebViews {
    case uiwebview
    init?(string: String) {
        switch string {
        case "uiwebview": self = .uiwebview
        default: return nil
        }
    }
}
