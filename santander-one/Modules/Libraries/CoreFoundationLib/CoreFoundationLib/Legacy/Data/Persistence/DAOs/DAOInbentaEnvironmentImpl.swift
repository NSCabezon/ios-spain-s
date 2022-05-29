//
// Created by Guillermo on 16/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public class DAOInbentaEnvironmentImpl: DAOInbentaEnvironment {

    private let dataRepository: DataRepository

    public init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }

    public func remove() -> Bool {
        dataRepository.remove(InbentaEnvironmentDTO.self)
        return true
    }

    public func set(inbentaEnvironmentDTO: InbentaEnvironmentDTO) -> Bool {
        dataRepository.store(inbentaEnvironmentDTO)
        return true
    }

    public func get() -> InbentaEnvironmentDTO? {
        return dataRepository.get(InbentaEnvironmentDTO.self)
    }
}
