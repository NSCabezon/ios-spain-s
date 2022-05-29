//
//  FrequentEmittersRepository.swift
//  Commons
//
//  Created by Cristobal Ramos Laina on 14/05/2020.
//

import Foundation

import SANLegacyLibrary

public protocol FrequentEmittersRepositoryProtocol {
    func getFrequentEmitters() -> FrequentEmittersListDTO?
    func loadEmitter(baseUrl: String, language: PublicLanguage)
}
