//
//  LoadingButtonView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 09/10/2020.
//

import CoreFoundationLib

public final class LoadingButtonView: BaseInformationButton {
    
    @IBOutlet private weak var loadingImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setAccessibilityIdentifier(identifier: String = "loadingButton") {
        self.accessibilityIdentifier = identifier + "_view"
        loadingImageView.accessibilityIdentifier = identifier + "_image"
    }
}

private extension LoadingButtonView {
    func setupView() {
        loadingImageView.setPointsLoader()
        setAccessibility {
            self.setAccessibility()
        }
    }
    
    func setAccessibility() {
        self.view?.isAccessibilityElement = true
    }
}

extension LoadingButtonView: AccessibilityCapable { }
