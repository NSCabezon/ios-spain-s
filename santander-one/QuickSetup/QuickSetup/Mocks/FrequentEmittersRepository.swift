//
//  FrequentEmittersRepository.swift
//  QuickSetup
//
//  Created by Daniel Gómez Barroso on 20/9/21.
//

import CoreFoundationLib

public final class FrequentEmittersRepository: FrequentEmittersRepositoryProtocol {
    public func loadEmitter(baseUrl: String, language: PublicLanguage) { }
    
    public func getFrequentEmitters() -> FrequentEmittersListDTO? {
        return FrequentEmittersListDTO(frequentEmitters: [])
    }
}
