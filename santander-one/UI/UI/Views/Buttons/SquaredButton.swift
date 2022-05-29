//
//  SquaredButton.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 28/04/2020.
//

import UIKit

public class SquaredButton: LisboaButton {
    private let btnAngleBracket = Assets.image(named: "icnArrowTransaction")
    
    /// default image is a right angle, modify this property to change this image
    var rightImage: UIImage? {
        willSet {
            guard let customImage = newValue else { return }
            self.setButtonImage(customImage)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func setupView() {
        super.setupView()
        self.semanticContentAttribute = .forceRightToLeft
        self.contentEdgeInsets = .zero
        self.borderWidth = 1.3
        self.borderColor = .darkTorquoise
        if let defaultImage = btnAngleBracket {
            self.setButtonImage(defaultImage)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 4
    }
}

private extension SquaredButton {
    func setButtonImage(_ image: UIImage) {
        self.setImage(image, for: .normal)
        self.tintColor = self.borderColor
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: (frame.size.width - ((frame.size.width) - 15)), bottom: 0, right: 0)
    }
}
