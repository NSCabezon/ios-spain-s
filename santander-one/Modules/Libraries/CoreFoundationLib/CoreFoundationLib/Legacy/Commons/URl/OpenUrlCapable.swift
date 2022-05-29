//
//  OpenUrlCapable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/3/20.
//

import Foundation

public protocol OpenUrlCapable {
    func openUrl(_ url: URL)
    func canOpenUrl(_ url: URL) -> Bool
}

extension OpenUrlCapable {
    public func openUrl(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    public func canOpenUrl(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
}
