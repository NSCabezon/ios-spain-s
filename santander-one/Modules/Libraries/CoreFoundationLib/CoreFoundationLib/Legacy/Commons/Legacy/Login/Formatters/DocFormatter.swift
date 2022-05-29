//
//  DocumentFormatter.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/18/20.
//

import Foundation

public protocol DocumentFormatterProtocol {
    func format(document: String) -> String
    func format(passport: String) -> String
}

public class DocumentFormatter: DocumentFormatterProtocol {
    private let demo = "0123456789"
    public init() {}
    
    public func format(document: String) -> String {
        var document = document
        guard document.count >= 2 else { return document }
        guard document.count < 9 else { return document.uppercased() }
        if let subString = document.substring(0, 1)?.uppercased(),
           demo.contains(subString) {
            while document.count < 9 {
                document = "0\(document)"
            }
            return document.uppercased()
        }
        guard  var subdoc = document.substring(1) else { return document }
        while subdoc.count < 8 {
            subdoc = "0\(subdoc)"
        }
        guard let subString = document.substring(0, 1)?.uppercased() else { return document }
        return ("\(subString)\(subdoc)").uppercased()
    }
    
    public func format(passport: String) -> String {
        var document = passport
        guard !document.isEmpty else { return document }
        if document.count >= 9 {
            return document.uppercased()
        }
        while document.count < 9 {
            document = "0\(document)"
        }
        return document.uppercased()
    }
}
