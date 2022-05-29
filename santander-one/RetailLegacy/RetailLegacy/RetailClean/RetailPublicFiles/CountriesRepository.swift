//
//  CountriesRepository.swift
//  RetailClean
//
//  Created by alvola on 19/03/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

struct CountriesRepository: BaseRepository {
    
    typealias T = CountriesDTO
    
    let datasource: NetDataSource<CountriesDTO, CodableParser<CountriesDTO>>
    
    init(netClient: NetClient, assetClient: AssetsClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "countriesTrip.json")
        let parser = CodableParser<CountriesDTO>()
        
        datasource = NetDataSource<CountriesDTO, CodableParser<CountriesDTO>>(parser: parser, parameters: parameters, assetsClient: assetClient, netClient: netClient)
    }
}

extension CountriesRepository: CountriesRepositoryProtocol {
    func getCountries() -> CountriesDTO? {
        return self.get()
    }
}
