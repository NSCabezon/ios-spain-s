//
//  BizumNGOListViewModel.swift
//  Bizum

import CoreFoundationLib

struct BizumNGOListViewModel {
    let identifier: String
    let name: String
    let alias: String
    var displayedIdentifier: String {
            guard identifier.count > 5, let displayedCode = identifier.substring(identifier.count - 5) else {
                return ""
            }
            return displayedCode
    }
}

extension BizumNGOListViewModel: Hashable {
    static func == (lhs: BizumNGOListViewModel, rhs: BizumNGOListViewModel) -> Bool {
        return lhs.name == rhs.name
    }
}
