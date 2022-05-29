//
//  SKVideoView.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 2/2/22.
//

import UIKit
import UI
import OpenCombine
import ESUI

public final class SKVideoView: XibView {
    @IBOutlet private weak var videoImageView: UIImageView!
    @IBOutlet private weak var videoButton: UIButton!
    let didTapVideo = PassthroughSubject<Void, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setImageView(name: String, accesibilityId: String) {
        self.videoImageView.image = ESAssets.image(named: name)
        setAccessibilityIds(accesibilityId: accesibilityId)
    }
}

private extension SKVideoView {
    
    func setupView() {
        
    }
    
    @IBAction func didTouchVideo() {
        didTapVideo.send()
    }
    
    func setAccessibilityIds(accesibilityId: String) {
        self.videoImageView.accessibilityIdentifier = accesibilityId
    }
}
