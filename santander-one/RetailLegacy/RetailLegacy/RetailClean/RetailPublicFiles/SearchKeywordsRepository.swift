//
//  SearchKeywordsRepository.swift
//  RetailClean
//
//  Created by César González Palomino on 25/07/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

struct SearchKeywordsRepository: BaseRepository {
    typealias T = SearchKeywordListDTO
    let datasource: NetDataSource<SearchKeywordListDTO, CodableParser<SearchKeywordListDTO>>
    
    init(netClient: NetClient, assetClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "searchKeywords.json")
        let parser = CodableParser<SearchKeywordListDTO>()
        datasource = NetDataSource<SearchKeywordListDTO, CodableParser<SearchKeywordListDTO>>(parser: parser, parameters: parameters, assetsClient: assetClient, netClient: netClient)
    }
}

extension SearchKeywordsRepository: SearchKeywordsRepositoryProtocol {
    func getKeywords() -> SearchKeywordListDTO? {
        return self.get()
    }
}
