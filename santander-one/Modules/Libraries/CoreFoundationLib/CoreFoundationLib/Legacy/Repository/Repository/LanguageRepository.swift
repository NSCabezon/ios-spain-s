//
//  LangugeRepository.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 6/2/20.
//



public protocol LanguageRepository {
    // MARK: Locale //
    func getLanguage() -> RepositoryResponse<LanguageType?>
}
