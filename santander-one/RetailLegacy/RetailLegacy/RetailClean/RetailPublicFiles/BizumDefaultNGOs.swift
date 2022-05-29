//
//  BizumDefaultNGOs.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 15/02/2021.
//

import CoreFoundationLib

struct BizumDefaultNGOsRepository: BaseRepository {
    typealias T = BizumDefaultNGOsListDTO
    let datasource: NetDataSource<BizumDefaultNGOsListDTO, CodableParser<BizumDefaultNGOsListDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "default_ongs.json")
        let parser = CodableParser<BizumDefaultNGOsListDTO>()
        self.datasource = FullDataSource<BizumDefaultNGOsListDTO, CodableParser<BizumDefaultNGOsListDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension BizumDefaultNGOsRepository: BizumDefaultNGOsRepositoryProtocol {
    func getDefaultNGOs() -> BizumDefaultNGOsListDTO? {
        return self.get()
    }
    
    func load(baseUrl: String, language publicLanguage: PublicLanguage) {
        datasource.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
