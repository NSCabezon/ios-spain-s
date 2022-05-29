//
//  BizumRefundMoneyResponseDTO.swift
//
//  Created by Boris Chirino Fernandez on 09/12/2020.
//

public struct BizumRefundMoneyResponseDTO: Codable {
    public let info: BizumRefundMoneyResponseInfo
    public let idOperacion: String?
}

public struct BizumRefundMoneyResponseInfo: Codable {
    public let errorCode: String
}
