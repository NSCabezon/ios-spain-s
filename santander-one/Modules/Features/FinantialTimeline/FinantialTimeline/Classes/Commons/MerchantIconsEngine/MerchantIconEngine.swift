//
//  MerchantIconEngine.swift
//  FinantialTimeline
//
//  Created by Jose Carlos Estela Anguita on 22/01/2020.
//

import Foundation

final class MerchantIconEngine {
    
    var baseUrl: String?
    
    func loadIcon(for merchantId: String) -> String? {
        guard let baseUrl = self.baseUrl else { return nil }
        return baseUrl + merchantId + ".png"
    }
}
