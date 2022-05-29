//
//  BSANPredefineSCAManager.swift
//  SANLegacyLibrary
//
//  Created by Juan Carlos López Robles on 4/19/21.
//

import Foundation

public protocol BSANPredefineSCAManager {
    func getInternalTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable>
    func getOnePayTransferPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable>
    func getCVVQueryPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable>
    func getCardBlockPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable>
    func getCardOnOffPredefinedSCA() -> BSANResponse<PredefinedSCARepresentable>
}
