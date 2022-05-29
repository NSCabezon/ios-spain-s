//
//  ThreeDotsView.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 13/04/2020.
//

/// Custom label required when more the user have more than 5 cards. It must have declared natural size because it will be inside stack view with Fill Proportionally attribute
final class ThreeDotsView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSantanderTextFont(type: .bold, size: 16.0, color: .grafite)
        self.textAlignment = .center
        self.text = "..."
        self.accessibilityIdentifier = "moreOptionsLabel"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 24.0, height: 20.0)
    }
}
