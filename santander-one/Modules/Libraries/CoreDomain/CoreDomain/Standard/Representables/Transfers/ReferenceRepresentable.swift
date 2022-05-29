//
//  ReferenceRepresentable.swift
//  CoreDomain
//
//  Created by José María Jiménez Pérez on 7/1/22.
//

public protocol ReferenceRepresentable {
    var reference: String? { get }
}
public protocol CheckTransferStatusRepresentable {
    var codInfo: String? { get }
}
