//
//  UIImageView+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 08/07/2019.
//

import UIKit

extension UIImageView {
    
    func setAnimationImagesWith(prefixName: String, range: CountableClosedRange<Int>, format: String? = nil) {
        var images: [UIImage] = []
        range.forEach { index in
            guard let image = UIImage(fromModuleWithName: "\(prefixName)\(format.map({ String(format: $0, index) }) ?? String(index))") else { return }
            images.append(image)
        }
        self.animationImages = images
    }
}
