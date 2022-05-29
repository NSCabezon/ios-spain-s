//
//  AditionalInfoRepresentable.swift
//  CoreDomain
//
//  Created by David Gálvez Alonso on 7/12/21.
//

public protocol AditionalInfoRepresentable {    
    var last: Bool? { get }
    var totalElements: Int? { get }
    var totalPages: Int? { get }
    var first: Bool? { get }
}
