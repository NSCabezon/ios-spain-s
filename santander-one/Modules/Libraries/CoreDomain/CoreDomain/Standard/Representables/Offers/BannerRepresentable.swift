//
//  BannerRepresentable.swift
//  CoreDomain
//
//  Created by Carlos Monfort Gómez on 29/11/21.
//

import Foundation

public protocol BannerRepresentable {
    var height: CGFloat { get }
    var width: Float { get }
    var url: String { get }
}

public extension BannerRepresentable {
    func equalsTo(other: BannerRepresentable) -> Bool {
        return self.height == other.height &&
            self.width == other.width &&
            self.url == other.url
    }
}
