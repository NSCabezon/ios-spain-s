//
//  CardView.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 13/04/2020.
//

/// Represent card thumbnail on cards footer when folded. It must have declared natural size because it will be inside stack view with Fill Proportionally attribute
final class CardView: UIImageView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 33.0, height: 20.0)
    }
}
