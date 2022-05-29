//
//  GetSignPositionsUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

typealias BasicSignValidationUseCaseAlias = UseCase<BasicSignValidationInput, BasicSignValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput>

typealias GetPositionsUseCase = BasicSignValidationUseCase
typealias ValidateSignUseCase = BasicSignValidationUseCase
typealias ValidateOTPUseCase = BasicSignValidationUseCase

final class BasicSignValidationUseCase: BasicSignValidationUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: BasicSignValidationInput) throws -> UseCaseResponse<BasicSignValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanSignBasicOperationManager()
        let contractCmc = try manager.getContractCmc()
        var modifiedInput = requestValues
        modifiedInput.contract = contractCmc
        let input = getSignValidationInputParams(input: modifiedInput)
        let response = try manager.validateSignPattern(input)
        guard response.isSuccess(),
            let responseData = try response.getResponseData()
        else {
            let signatureType = try processSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }

        return .ok(BasicSignValidationUseCaseOkOutput(signBasicOperationEntity: SignBasicOperationEntity(dto: responseData)))
    }
    
    func getSignValidationInputParams(input: BasicSignValidationInput) -> SignValidationInputParams {
        var otpDataInputParams: OtpDataInputParams?
        if !input.isOTPNull || !input.ticketOTP.isEmpty {
            otpDataInputParams = OtpDataInputParams(
                codeOTP: input.codeOTP,
                ticketOTP: input.ticketOTP,
                contract: input.contract
            )
        }
        var signatureDataInputParams: SignatureDataInputParams?
        if let signatureData = input.signatureData {
            signatureDataInputParams = SignatureDataInputParams(
                positions: signatureData.positions,
                positionsValues: signatureData.getValues() ?? ""
            )
        }
        return SignValidationInputParams(magicPhrase: input.magicPhrase, signatureData: signatureDataInputParams, otpData: otpDataInputParams)
    }
}

struct BasicSignValidationUseCaseOkOutput {
    let signBasicOperationEntity: SignBasicOperationEntity
}

struct BasicSignValidationInput {
    var magicPhrase: String
    var signatureData: SignatureDataEntity?
    var isOTPNull: Bool = true
    var codeOTP: String = ""
    var ticketOTP: String = ""
    var contract: String?
}
