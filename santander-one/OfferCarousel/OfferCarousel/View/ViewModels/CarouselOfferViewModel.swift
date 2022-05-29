//
//  CarouselOfferViewModel.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 23/7/21.
//

import Foundation
import CoreFoundationLib

public struct CarouselOfferViewModel: ElementEntity {
    public let imgURL: String?
    public var height: CGFloat?
    public let elem: Any?
    public let transparentClosure: Bool
    
    public init(imgURL: String?,
                height: CGFloat?,
                elem: Any?,
                transparentClosure: Bool) {
        self.imgURL = imgURL
        self.height = height
        self.elem = elem
        self.transparentClosure = transparentClosure
    }
}
