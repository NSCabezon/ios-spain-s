//
//  TricksRepositoryProtocol.swift
//  Models
//
//  Created by Tania Castellano Brasero on 28/04/2020.
//



public protocol TricksRepositoryProtocol {
    func getTricks() -> TrickListDTO?
    func loadTricks(with baseUrl: String, publicLanguage: PublicLanguage)
}
