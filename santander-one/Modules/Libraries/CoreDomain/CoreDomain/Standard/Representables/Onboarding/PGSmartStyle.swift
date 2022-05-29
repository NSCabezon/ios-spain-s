//
//  PGSmartStyle.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation

public enum PGSmartStyle: Int, Codable {
    case red = 0
    case black
    
    public func imageName() -> String {
        switch self {
        case .red:
            return "imgPgSmart"
        case .black:
            return "imgYoungBlack"
        }
    }
}
