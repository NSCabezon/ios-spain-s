//
//  MenuRepository.swift
//  CoreDomain
//
//  Created by Daniel Gómez Barroso on 23/12/21.
//

import OpenCombine

public protocol MenuRepository {
    func fetchSoapTokenCredential() -> AnyPublisher<String, Never>
}
