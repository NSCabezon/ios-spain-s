//
//  PGColorMode+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension PGColorMode {
    func imageName() -> String {
         switch self {
         case .red:
             return "imgPgSmart"
         case .black:
             return "imgYoungBlack"
         }
     }
}
