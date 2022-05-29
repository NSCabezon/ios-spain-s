//
//  FavRicipientsHeaderView.swift
//  Transfer
//
//  Created by Ignacio González Miró on 26/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

public protocol FavRecipientsHeaderViewProtocol: AnyObject {
    func didTapOnBack()
}
public final class FavRecipientsHeaderView: UIDesignableView {

    @IBOutlet weak private var titleHeader: UILabel!
    @IBOutlet weak private var backBtn: UIButton!
    @IBOutlet weak private var separatorView: UIView!
    
    weak var delegate: FavRecipientsHeaderViewProtocol?
    
    public override func getBundleName() -> String {
        return "Transfer"
    }
    
    public override func commonInit() {
        super.commonInit()
        self.setupUI()
        self.setIdentifiers()
    }
    
    public func textInHeader(_ title: String) {
        self.titleHeader.text = title
        self.backBtn.addTarget(self, action: #selector(didTapOnCancel), for: .touchUpInside)
    }
    
    @objc func didTapOnCancel() {
        self.backBtn.accessibilityIdentifier = AccessibilityFavRecipientsHeader.backButton.rawValue
        delegate?.didTapOnBack()
    }
}

private extension FavRecipientsHeaderView {
    func setupUI() {
        self.backBtn.setImageName("icnClose", withTintColor: .santanderRed)
        self.titleHeader.setSantanderTextFont(type: .bold, size: 18, color: .santanderRed)
        self.separatorView.backgroundColor = .mediumSkyGray
        self.backgroundColor = .skyGray
    }
    
    func setIdentifiers() {
        self.titleHeader.accessibilityIdentifier = AccessibilityFavRecipientsHeader.headerTitle.rawValue
    }
}
