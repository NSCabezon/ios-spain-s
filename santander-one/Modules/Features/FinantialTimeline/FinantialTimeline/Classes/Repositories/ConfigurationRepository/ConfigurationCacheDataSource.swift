//
//  ConfigurationCacheDataSource.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

class ConfigurationCacheDataSource: ConfigurationDataSource, ConfigurationStorageDataSource {
    private let cache = NSCache<NSString, AnyObject>()
    private let configurationKey: String = "TimeLineConfiguration"
    
    func fetchConfiguration(completion: @escaping (Result<TimeLineConfiguration, Error>) -> Void) {
        guard let configuration = cache.object(forKey: configurationKey as NSString) as? TimeLineConfiguration else {
            return completion(.failure(ConfigurationDataSourceError.notInCache))
        }
        completion(.success(configuration))
    }
    
    func saveConfiguration(_ configuration: TimeLineConfiguration) {
        cache.setObject(configuration, forKey: configurationKey as NSString)
    }
}
