//
//  DefaultPrivateMenuRepository.swift
//  CoreFoundationLib
//
//  Created by Daniel Gómez Barroso on 31/1/22.
//

import CoreDomain
import OpenCombine

//TODO: Datos externos que necesitamos. Las funciones de MenuRepository no son nuestras, solo se necesitan desde el menu privado.
public class DefaultPrivateMenuRepository: MenuRepository {
    private var subjectSoapToken = CurrentValueSubject<String, Never>("")
    
    public func fetchSoapTokenCredential() -> AnyPublisher<String, Never> {
        return subjectSoapToken.eraseToAnyPublisher()
    }
    
    public init() {}
}
