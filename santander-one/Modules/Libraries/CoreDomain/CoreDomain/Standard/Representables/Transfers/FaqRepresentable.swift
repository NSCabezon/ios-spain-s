//
//  FaqRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 27/9/21.
//

import Foundation

public protocol FaqRepresentable {
    var identifier: Int? { get }
    var question: String { get }
    var answer: String { get }
    var icon: String? { get }
    var keywords: [String]? { get }
}
