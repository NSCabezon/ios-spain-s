//
//  ComingFeaturesRepository.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 24/02/2020.
//

import Foundation


public protocol ComingFeaturesRepositoryProtocol {
    func getFeatures() -> ComingFeatureListDTO?
    func load(baseUrl: String, publicLanguage: PublicLanguage)
}
