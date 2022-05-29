//
//  Users.swift
//  QuickSetup
//
//  Created by Juan Carlos López Robles on 11/5/19.
//

import Foundation

public enum User {
    case sabin
    case demo
    case inaki
    case carlosIgnacio
    case luis
    case teodora
    case eva
    case rosarina
    case lilianaNicoleta
    case erradi
    case aurora
    case sign01
    case custom(String, isPb: Bool)
    
    var user: String {
        switch self {
        case .sabin: return "11907980y"
        case .demo: return "12345679z"
        case .inaki: return "31171180q"
        case .carlosIgnacio: return "02816068v"
        case .luis: return "15838866p"
        case .teodora: return "50438581h"
        case .eva: return "22224444g"
        case .rosarina: return "1010111c"
        case .lilianaNicoleta: return "00026124L"
        case .erradi: return "00062830V"
        case .aurora: return "70223741A"
        case .sign01: return "55115408W"
        case .custom(let user, _): return user
        }
    }
    
    var isPB: Bool {
        switch self {
        case .sabin, .demo, .luis, .teodora, .carlosIgnacio, .rosarina, .eva, .sign01:
            return true
        case .custom(_, isPb: let isPb):
            return isPb
        case .lilianaNicoleta, .inaki, .erradi, .aurora:
            return false
        }
    }
}
