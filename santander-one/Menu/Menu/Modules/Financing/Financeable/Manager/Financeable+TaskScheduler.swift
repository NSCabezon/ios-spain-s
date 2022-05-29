//
//  Financeable+TaskScheduler.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 02/07/2020.
//

import Foundation

extension FinanceableManager {

    class TaskScheduler {
        
        private let dispatchQueue: DispatchQueue = DispatchQueue(label: "financeable.task.scheduler")
        private let dispatchGroup = DispatchGroup()
        var onFinished: (() -> Void)? {
            didSet {
                self.dispatchGroup.notify(queue: .main) {
                    self.onFinished?()
                }
            }
        }
        
        public func schedule(
            _ function: @escaping (@escaping () -> Void) -> Void,
            completion: (() -> Void)? = nil
        ) {
            self.dispatchGroup.enter()
            self.dispatchQueue.async {
                function { [weak self] in
                    completion?()
                    self?.dispatchGroup.leave()
                }
            }
        }
        
        func schedule<FunctionReturnType>(
            _ function: @escaping (@escaping (FunctionReturnType) -> Void) -> Void,
            completion: ((FunctionReturnType) -> Void)? = nil
        ) {
            self.dispatchGroup.enter()
            self.dispatchQueue.async {
                function { [weak self] result in
                    guard let self = self else { return }
                    completion?(result)
                    self.dispatchGroup.leave()
                }
            }
        }
    }

}
