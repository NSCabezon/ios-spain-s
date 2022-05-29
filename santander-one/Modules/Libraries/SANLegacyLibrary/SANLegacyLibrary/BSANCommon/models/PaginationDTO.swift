//
// Created by Toni Moreno on 9/11/17.
// Copyright (c) 2017 Toni. All rights reserved.
//
import CoreDomain
import Foundation

public struct PaginationDTO: Codable {
    public var repositionXML: String = ""
    public var accountAmountXML: String = ""
    public var endList: Bool = true
    
    public init() {}
    
    public init(repositionXML: String, accountAmountXML: String, endList: Bool) {
        self.repositionXML = repositionXML
        self.accountAmountXML = accountAmountXML
        self.endList = endList
    }
}

extension PaginationDTO: PaginationRepresentable {}
