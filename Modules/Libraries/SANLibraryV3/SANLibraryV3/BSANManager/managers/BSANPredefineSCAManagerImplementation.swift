//
//  BSANPredefineSCAManagerImplementation.swift
//  SANLibraryV3
//
//  Created by Juan Carlos López Robles on 4/20/21.
//

import Foundation
import SANLegacyLibrary

public final class BSANPredefineSCAManagerImplementation {
    public init() {}
}

extension BSANPredefineSCAManagerImplementation: BSANPredefineSCAManager {
    public func getInternalTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(PredefinedSCARepresentable.signature)
    }
    
    public func getOnePayTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(PredefinedSCARepresentable.signatureAndOtp)
    }
    
    public func getCVVQueryPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(PredefinedSCARepresentable.signatureAndOtp)
    }
    
    public func getCardBlockPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(PredefinedSCARepresentable.signature)
    }
    
    public func getCardOnOffPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable> {
        return BSANOkResponse(PredefinedSCARepresentable.signature)
    }
}
