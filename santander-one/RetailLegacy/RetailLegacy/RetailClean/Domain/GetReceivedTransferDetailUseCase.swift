//
//  GetReceivedTransferDetailUseCase.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 29/06/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetReceivedTransferDetailUseCase: UseCase<GetReceivedTransferDetailUseCaseInput, GetReceivedTransferDetailUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetReceivedTransferDetailUseCaseInput) throws -> UseCaseResponse<GetReceivedTransferDetailUseCaseOkOutput, StringErrorOutput> {
        _ = requestValues.transfer.transferDTO
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.getEmittedTransferDetail(transferEmittedDTO: requestValues.transfer.transferDTO)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let result = EmittedTransferDetail.create(data)
        return UseCaseResponse.ok(GetReceivedTransferDetailUseCaseOkOutput(transferReceivedDetail: result))
    }
}

struct GetReceivedTransferDetailUseCaseInput {
    let transfer: TransferEmitted
}

struct GetReceivedTransferDetailUseCaseOkOutput {
    let transferReceivedDetail: EmittedTransferDetail?
}
