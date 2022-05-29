//
//  TricksRepository.swift
//  RetailClean
//
//  Created by Tania Castellano Brasero on 28/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib
import Foundation

struct TricksRepository: BaseRepository {
    typealias T = TrickListDTO
    let datasource: NetDataSource<TrickListDTO, CodableParser<TrickListDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "tricks.json")
        let parser = CodableParser<TrickListDTO>()
        self.datasource = FullDataSource<TrickListDTO, CodableParser<TrickListDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension TricksRepository: TricksRepositoryProtocol {
    func getTricks() -> TrickListDTO? {
        return self.get()
    }
    
    func loadTricks(with baseUrl: String, publicLanguage: PublicLanguage) {
        self.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
