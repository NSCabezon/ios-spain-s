//
//  UIView+Extension.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 2/21/22.
//

import Foundation
import OpenCombine
import OpenCombineDispatch
import UIKit

extension UIView {
    func assign<Value>(
        _ publisher: AnyPublisher<Value, Never>,
        to key: ReferenceWritableKeyPath<UIView, Value>
    ) -> AnyCancellable {
        return publisher.assign(to: key, on: self)
    }
}
