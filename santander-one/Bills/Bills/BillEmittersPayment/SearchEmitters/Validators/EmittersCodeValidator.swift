//
//  EmittersCodeValidator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/18/20.
//

import Foundation

final class EmittersCodeValidator {
    func sanitizeCode(_ code: String) -> String {
        guard !code.isEmpty else { return code }
        let sanitizeCode = self.first50Character(code)
        let count = sanitizeCode.count - 6
        guard count < 0 else { return sanitizeCode }
        let zeros = String(repeating: "0", count: abs(count))
        return sanitizeCode + zeros
    }
    
    func fillWithLeadingZeros(_ code: String) -> String {
        guard !code.isEmpty, code.count < 7 else { return code }
        let count = code.count - 7
        let zeros = String(repeating: "0", count: abs(count))
        return zeros + code
    }
    
    private func first50Character(_ text: String) -> String {
        guard text.count > 50 else {
            return text
        }
        return text.substring(0, 50) ?? ""
    }
}
