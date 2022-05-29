//
//  PublicProductsRepositoryProtocol.swift
//  Commons
//
//  Created by alvola on 28/04/2020.
//



public protocol PublicProductsRepositoryProtocol {
    func getPublicProducts() -> PublicProductsDTO?
    func loadProduct(baseUrl: String, publicLanguage: PublicLanguage)
}
