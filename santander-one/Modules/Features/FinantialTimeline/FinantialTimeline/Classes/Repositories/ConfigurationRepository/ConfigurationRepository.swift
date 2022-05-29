//
//  ConfigurationRepository.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

protocol ConfigurationRepository {
    func fetchConfiguration(completion: @escaping (Result<TimeLineConfiguration, Error>) -> Void)
}
