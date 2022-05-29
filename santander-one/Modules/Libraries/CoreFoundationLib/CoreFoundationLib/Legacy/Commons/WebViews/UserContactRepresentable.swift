//
//  UserContactRepresentable.swift
//  Commons
//
//  Created by José María Jiménez Pérez on 4/6/21.
//

public protocol UserContactRepresentable {
    var identifier: String { get }
    var name: String { get }
    var surname: String { get }
    var phonesRepresentable: [UserContactPhoneRepresentable] { get set }
    var thumbnail: Data? { get }
}

public protocol UserContactPhoneRepresentable {
    var alias: String { get }
    var number: String { get }
}
