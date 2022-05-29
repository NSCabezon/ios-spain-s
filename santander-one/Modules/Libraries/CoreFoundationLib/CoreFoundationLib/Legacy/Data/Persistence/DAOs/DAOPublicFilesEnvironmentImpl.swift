//
// Created by Guillermo on 16/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public class DAOPublicFilesEnvironmentImpl: DAOPublicFilesEnvironment {

    private let dataRepository: DataRepository

    public init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }

    public func remove() -> Bool {
        dataRepository.remove(PublicFilesEnvironmentDTO.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func set(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO) -> Bool {
        dataRepository.store(publicFilesEnvironmentDTO, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func get() -> PublicFilesEnvironmentDTO? {
        return dataRepository.get(PublicFilesEnvironmentDTO.self, DataRepositoryPolicy.createPersistentPolicy())
    }
}
