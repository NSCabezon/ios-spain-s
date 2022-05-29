//
//  FrequentEmittersListDTO.swift
//  Models
//
//  Created by Cristobal Ramos Laina on 14/05/2020.
//

import Foundation
import SANLegacyLibrary

public struct FrequentEmittersListDTO: Codable {
    public let frequentEmitters: [EmitterDTO]
    
    public init(frequentEmitters: [EmitterDTO]) {
        self.frequentEmitters = frequentEmitters
    }
}
