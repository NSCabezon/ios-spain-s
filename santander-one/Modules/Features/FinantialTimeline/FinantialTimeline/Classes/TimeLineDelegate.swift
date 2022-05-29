//
//  TimeLineDelegate.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 07/10/2019.
//

import Foundation

public protocol TimeLineDelegate: class {
    func onTimeLineCTATap(from viewController: TimeLineDetailViewController, with action: CTAAction)
    func mask(displayNumber: String, completion: @escaping (_ displayNumberMasked: String) -> Void)
}


public extension TimeLineDelegate {
    func onTimeLineCTATap(from viewController: TimeLineDetailViewController, with action: CTAAction) { }
    func mask(displayNumber: String, completion: @escaping (_ displayNumberMasked: String) -> Void) {
        if displayNumber.count <= 4 {
            completion("***\(displayNumber)")
        } else {
            let last4 = displayNumber.suffix(4)
            completion("***\(last4)")
        }
    }
}
