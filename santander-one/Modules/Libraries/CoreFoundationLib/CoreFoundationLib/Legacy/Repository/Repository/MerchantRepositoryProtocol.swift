//
//  MerchantRepositoryProtocol.swift
//  Repository
//
//  Created by César González Palomino on 04/03/2021.
//



public protocol MerchantRepositoryProtocol {
    func getMerchantList() -> MerchantListDTO?
    func load(baseUrl: String, publicLanguage: PublicLanguage)
}
