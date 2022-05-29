//
//  LastAccessInfoManager.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 14/08/2020.
//

import CoreFoundationLib

protocol LastAccessInfoManagerProtocol: AnyObject {
    func getLastAccessDateViewModelIfAvailable(_ viewModel: @escaping (LastLogonViewModel?) -> Void)
}

final class LastAccessInfoManager: LastAccessInfoManagerProtocol {
    
    private var dependenciesEngine: DependenciesDefault
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    private var useCase: GetLastLogonUseCaseProtocol {
        return dependenciesEngine.resolve(firstTypeOf: GetLastLogonUseCaseProtocol.self)
    }
    
    private var timeManager: TimeManager {
        return self.dependenciesEngine.resolve(for: TimeManager.self)
    }
    
    init(dependenciesEngine: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesEngine)
        self.setupDependencies()
    }
    
    func getLastAccessDateViewModelIfAvailable(_ viewModel: @escaping (LastLogonViewModel?) -> Void) {
        getLastLogonDate { result in
            guard let lastLogonViewModel = self.createLastLogonViewModelIfNeeded(from: result) else { return viewModel(nil) }
            viewModel(lastLogonViewModel)
        }
    }
}

private extension LastAccessInfoManager {
    func setupDependencies() {
        self.dependenciesEngine.register(for: GetLastLogonUseCaseProtocol.self) { dependenciesResolver in
            return GetLastLogonUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func getLastLogonDate(_ completion: @escaping (LastLogonInfoOkOutput?) -> Void) {
        Scenario(useCase: useCase)
            .execute(on: useCaseHandler)
            .onSuccess { result in
                completion(result)
            }
            .onError { _ in
                completion(nil)
            }
    }
    
    func createLastLogonViewModelIfNeeded(from output: LastLogonInfoOkOutput?) -> LastLogonViewModel? {
        guard let date = output?.lastLogonInfoEntity?.lastConnection else { return nil }
        guard let stringDate = timeManager.toStringFromCurrentLocale(date: date, outputFormat: TimeFormat.EEE_ddMM_HHmm)?.camelCasedString else { return nil }
        return LastLogonViewModel(lastLogonDate: stringDate)
    }
}
