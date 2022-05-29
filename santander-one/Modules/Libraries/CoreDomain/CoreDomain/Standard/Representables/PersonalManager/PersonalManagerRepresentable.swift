//
//  PersonalManagerRepresentable.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 27/12/21.
//

public protocol PersonalManagerRepresentable {
    var codGest: String? { get }
    var nameGest: String? { get }
    var category: String? { get }
    var portfolio: String? { get }
    var desTipCater: String? { get }
    var phone: String? { get }
    var email: String? { get }
    var indPriority: Int? { get }
    var portfolioType: String? { get }
    var thumbnailData: Data? { get set }
}
