//
//  ManagerHobbiesRepository.swift
//  RetailClean
//
//  Created by César González Palomino on 18/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

struct ManagerHobbiesRepository: BaseRepository {
    
    typealias T = ManagerHobbieListDTO
    
    let datasource: FullDataSource<ManagerHobbieListDTO, CodableParser<ManagerHobbieListDTO>>
    
    init(netClient: NetClient, assetClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "managers.json")
        let parser = CodableParser<ManagerHobbieListDTO>()
        datasource = FullDataSource<ManagerHobbieListDTO, CodableParser<ManagerHobbieListDTO>>(netClient: netClient, assetsClient: assetClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension ManagerHobbiesRepository: ManagerHobbiesRepositoryProtocol {
    func getManagerHobbies() -> ManagerHobbieListDTO? {
        return self.get()
    }
    
    func loadManagerHobbies(baseUrl: String, publicLanguage: PublicLanguage) {
        self.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
