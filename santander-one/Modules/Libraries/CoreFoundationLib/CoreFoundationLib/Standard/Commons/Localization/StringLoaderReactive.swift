//
//  StringLoaderReactive.swift
//  CoreFoundationLib
//
//  Created by alvola on 9/3/22.
//

import Foundation
import OpenCombine

public protocol StringLoaderReactive {
    func getCurrentLanguage() -> AnyPublisher<Language, Never> 
}

