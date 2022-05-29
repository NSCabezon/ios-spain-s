//
//  ConfigurationApiRepository.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

class ConfigurationApiRepository: ConfigurationRepository {
    
    private let remoteDataSource: ConfigurationDataSource
    
    init(remoteDataSource: ConfigurationDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchConfiguration(completion: @escaping (Result<TimeLineConfiguration, Error>) -> Void) {
        remoteDataSource.fetchConfiguration(completion: completion)
    }
}
