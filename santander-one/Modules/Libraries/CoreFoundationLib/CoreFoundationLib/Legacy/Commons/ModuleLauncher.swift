//
//  ModuleLauncher.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 29/04/2020.
//

import Foundation

public protocol ModuleProxy {
    associatedtype Output
    func run(onSuccess: ((Output) -> Void)?, onError: ((UseCaseError<StringErrorOutput>) -> Void)?)
}

public protocol ModuleLauncherDelegate: AnyObject {
    func launcherDidStar()
    func launcherDidFinishSuccessfully(completion: @escaping () -> Void)
    func launcherDidFinish<Error: StringErrorOutput>(withDependenciesResolver dependenciesResolver: DependenciesResolver, for error: UseCaseError<Error>)
}

public protocol ModuleLauncher: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
}

extension ModuleLauncher {
    
    /// Execute an use case handling the error case and delegating the onSuccess case.
    /// - Parameters:
    ///   - useCase: The use case to perform
    ///   - delegate: The delegate that handles the states of use case execution
    ///   - onSuccess: The onSuccess completion block
    public func does<Input, Output>(useCase: UseCase<Input, Output, StringErrorOutput>, handledBy delegate: ModuleLauncherDelegate, onSuccess: @escaping (Output) -> Void) {
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { output in
                delegate.launcherDidFinishSuccessfully {
                    onSuccess(output)
                }
            },
            onError: { error in
                delegate.launcherDidFinish(withDependenciesResolver: self.dependenciesResolver, for: error)
            }
        )
    }
    
    public func does<Proxy: ModuleProxy>(proxy: Proxy, handleBy delegate: ModuleLauncherDelegate, onSuccess: @escaping(Proxy.Output) -> Void) {
        proxy.run(onSuccess: { result in
            delegate.launcherDidFinishSuccessfully {
                onSuccess(result)
            }
        }, onError: { error in
            delegate.launcherDidFinish(withDependenciesResolver: self.dependenciesResolver, for: error)
        })
    }
    
    public func enableLoading(enable: Bool, handledBy delegate: ModuleLauncherDelegate) -> Self {
        guard enable else { return self }
        delegate.launcherDidStar()
        return self
    }
}
