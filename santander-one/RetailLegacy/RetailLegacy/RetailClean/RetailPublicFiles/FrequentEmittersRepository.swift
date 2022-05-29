//
//  FrequentEmittersRepository.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 14/05/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

struct FrequentEmittersRepository: BaseRepository {
    typealias T = FrequentEmittersListDTO
    let datasource: NetDataSource<FrequentEmittersListDTO, CodableParser<FrequentEmittersListDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "frequent_emitters.json")
        let parser = CodableParser<FrequentEmittersListDTO>()
        self.datasource = FullDataSource<FrequentEmittersListDTO, CodableParser<FrequentEmittersListDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension FrequentEmittersRepository: FrequentEmittersRepositoryProtocol {
    func getFrequentEmitters() -> FrequentEmittersListDTO? {
        return self.get()
    }
    
    func loadEmitter(baseUrl: String, language: PublicLanguage) {
        self.load(baseUrl: baseUrl, publicLanguage: language)
    }
}
