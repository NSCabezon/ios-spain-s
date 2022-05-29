//
//  LoanShareable.swift
//  Loans
//
//  Created by Juan Jose Acosta González on 23/2/22.
//
import CoreFoundationLib

struct LoanShareable: Shareable {
    
    var shared: String = ""
    
    func getShareableInfo() -> String {
        return shared
    }
}
