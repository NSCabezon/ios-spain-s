//
//  ContactsEngine.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 04/02/2020.
//

import CoreDomain
import Foundation
import CoreFoundationLib

public enum ContactsEngineError: Error {
    case descriptedError(String?)
}

public protocol ContactsEngineProtocol {
    func fetchContacts(_ completion: @escaping (Result<[PayeeRepresentable], ContactsEngineError>) -> Void)
}

public final class ContactsEngine {
    
    private class ActiveRequests {
        lazy var completions: ThreadSafeProperty<[(Result<[PayeeRepresentable], ContactsEngineError>) -> Void]> = {
           return ThreadSafeProperty([])
        }()
    }
    
    private let activeRequests: ActiveRequests
    private let dependenciesResolver: DependenciesResolver & DependenciesInjector
    private lazy var loadContactsSuperUseCase: LoadContactsSuperUseCase = {
        LoadContactsSuperUseCase(dependenciesResolver: dependenciesResolver)
    }()
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father:  dependenciesResolver)
        self.activeRequests = ActiveRequests()
        self.registerDependencies()
        self.loadContactsSuperUseCase.delegate = self
    }
    
    private func registerDependencies() {
        self.dependenciesResolver.register(for: LoadContactsUseCase.self) { dependenciesResolver in
            return LoadContactsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesResolver.register(for: GetNoSepaPayeeDetailUseCase.self) { dependenciesResolver in
            GetNoSepaPayeeDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension ContactsEngine: ContactsEngineProtocol {
    
    public func fetchContacts(_ completion: @escaping (Result<[PayeeRepresentable], ContactsEngineError>) -> Void) {
        defer { self.activeRequests.completions.value.append(completion) }
        guard self.activeRequests.completions.value.isEmpty else { return }
        self.loadContactsSuperUseCase.execute()
    }
}

extension ContactsEngine: LoadContactsSuperUseCaseDelegate {
    
    func didFinishSuccessfully(with contacts: [PayeeRepresentable]) {
        self.activeRequests.completions.value.forEach { completion in
            completion(.success(contacts))
        }
        self.activeRequests.completions.value.removeAll()
    }
    
    func didFinishWithError(_ error: String?) {
        self.activeRequests.completions.value.forEach { completion in
            completion(.failure(.descriptedError(error)))
        }
        self.activeRequests.completions.value.removeAll()
    }
}
