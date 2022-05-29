//
//  SignBasicOperationEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import SANLegacyLibrary
import CoreDomain

public protocol SignBasicOperationEntityRepresentable {
    var magicPhrase: String { get }
    var signatureData: SignatureDataEntity? { get set }
    var otpData: OtpDataEntity? { get }
    var informationStepCurrentSignature: InformationStepEntity? { get }
}

public struct SignBasicOperationEntity: SignBasicOperationEntityRepresentable {
    private var dto: SignBasicOperationDTO
    public init(dto: SignBasicOperationDTO) {
        self.dto = dto
    }
    
    public var magicPhrase: String {
        return dto.magicPhrase
    }
    
    public var signatureData: SignatureDataEntity? {
        get {
            guard let signatureDataDto = dto.signatureData else { return nil }
            return SignatureDataEntity(dto: signatureDataDto)
        }
        set {
            dto.signatureData?.values = newValue?.values
        }
    }
    
    public var otpData: OtpDataEntity? {
        guard let otpDataDto = dto.otpData else { return nil }
        return OtpDataEntity(dto: otpDataDto)
    }

    public var informationStepCurrentSignature: InformationStepEntity? {
        guard let informationStepDto = dto.informationStepCurrentSignature else { return nil }
        return InformationStepEntity(dto: informationStepDto)
    }
}

extension SignBasicOperationEntity: SignatureRepresentable {
    public var length: Int? {
        guard let signatureData = self.signatureData else { return nil }
        return Int(signatureData.length)
    }
    
    public var positions: [Int]? {
        guard let signatureData = self.signatureData else { return nil }
        let trimmedPositions = signatureData.positions.trimmingCharacters(in: .whitespaces)
        return trimmedPositions.compactMap {Int(String($0))}
    }
    
    public var values: [String]? {
        get {
            guard let signatureData = self.signatureData else { return nil }
            return signatureData.values
        }
        set {
            guard let newValueStrong = newValue else { return }
            self.signatureData?.values = newValueStrong
        }
    }
}
