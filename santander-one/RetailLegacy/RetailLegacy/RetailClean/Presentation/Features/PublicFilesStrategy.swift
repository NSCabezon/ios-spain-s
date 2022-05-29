//
//  PublicFilesStrategy.swift
//  RetailClean
//
//  Created by José Carlos Estela Anguita on 03/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

protocol PublicFilesStrategyDelegate: AnyObject {
    func publicFilesDidFinishLoading()
}

final class PublicFilesStrategy {
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private weak var delegate: PublicFilesStrategyDelegate?
    private lazy var loadPublicFilesSuperUseCase: LoadPublicFilesSuperUseCase<PublicFilesStrategy> = {
        return LoadPublicFilesSuperUseCase(
            useCaseProvider: useCaseProvider,
            useCaseHandler: useCaseHandler,
            errorHandler: LoadPublicFilesSuperUseCaseErrorHandler(self),
            delegate: self,
            queuePriority: .veryHigh,
            finishQueue: .noChange
        )
    }()
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, delegate: PublicFilesStrategyDelegate?) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.delegate = delegate
    }
    
    func loadPublicFiles(timeout: TimeInterval) {
        guard timeout != 0 else { return self.loadPublicFilesSuperUseCase.execute() }
        self.loadPublicFilesSuperUseCase.execute(withTimeout: timeout)
    }
    
    func cancel() {
        self.loadPublicFilesSuperUseCase.cancel()
        self.delegate?.publicFilesDidFinishLoading()
    }
}

extension PublicFilesStrategy: SuperUseCaseDelegate {
    
    func onSuccess() {
        self.delegate?.publicFilesDidFinishLoading()
    }
    
    func onError(error: String?) {
        self.delegate?.publicFilesDidFinishLoading()
    }
}
