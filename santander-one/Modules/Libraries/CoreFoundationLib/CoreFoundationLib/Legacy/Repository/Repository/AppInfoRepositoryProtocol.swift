//
//  AppInfoRepositoryProtocol.swift
//  Commons
//
//  Created by alvola on 22/04/2020.
//

public protocol AppInfoRepositoryProtocol {
    func load(baseUrl: String, publicLanguage: PublicLanguage)
    func getAppInfo() -> AppVersionsInfoDTO?
}
