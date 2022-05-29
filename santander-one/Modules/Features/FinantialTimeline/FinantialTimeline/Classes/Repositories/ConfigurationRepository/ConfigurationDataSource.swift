//
//  ConfigurationDataSource.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

enum ConfigurationDataSourceError: Error {
    case notInCache
}

protocol ConfigurationDataSource {
    func fetchConfiguration(completion: @escaping (Result<TimeLineConfiguration, Error>) -> Void)
}

protocol ConfigurationStorageDataSource {
    func saveConfiguration(_ configuration: TimeLineConfiguration)
}
