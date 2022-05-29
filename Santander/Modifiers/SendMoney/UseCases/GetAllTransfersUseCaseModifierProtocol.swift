//
//  GetAllTransfersUseCaseModifierProtocol.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 19/4/21.
//

import CoreFoundationLib
import CoreDomain
import Foundation

protocol GetAllTransfersUseCaseModifierProtocol {
    func filterBizumTransfers<Transfer: TransferEntityProtocol>(_ transfers: [AccountEntity: [Transfer]]) -> [AccountEntity: [Transfer]]
    func filterBizumTransfers(_ transfers: [TransferRepresentable]) -> [TransferRepresentable]
}
