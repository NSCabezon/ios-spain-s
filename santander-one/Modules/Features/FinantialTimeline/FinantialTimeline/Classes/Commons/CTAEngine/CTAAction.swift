//
//  CTAAction.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 03/09/2019.
//

import Foundation

public class CTAAction {
    public var identifier: String
    public var actionDescription: String?
    public var structure: CTAStructure?
    public var event: TimeLineEvent?
    
    public required init(identifier: String) {
        self.identifier = identifier
    }
}


public class PublicCTA {
    public let reference: String    
    
    public required init(reference: String) {
        self.reference = reference
    }
}
