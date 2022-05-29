//
//  BizumRepository.swift
//  SANSpainLibrary
//
//  Created by José Carlos Estela Anguita on 7/4/21.
//

public protocol BizumRepository {
    func checkPayment(defaultXPAN: String) throws -> Result<BizumCheckPaymentRepresentable, Error>
}
