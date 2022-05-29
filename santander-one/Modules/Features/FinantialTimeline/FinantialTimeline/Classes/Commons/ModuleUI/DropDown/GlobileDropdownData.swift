//
//  GlobileDropdownData.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import Foundation

public class GlobileDropdownData<T> {
    public var label: (String)
    public var value: (T)? = nil
    
    public init(label: String, value: T?) {
        self.label = label
        self.value = value
    }
}
