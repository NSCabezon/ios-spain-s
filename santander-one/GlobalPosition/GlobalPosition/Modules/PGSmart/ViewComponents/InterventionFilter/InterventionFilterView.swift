//
//  InterventionFilterView.swift
//  GlobalPosition
//
//  Created by alvola on 07/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol InterventionFilterViewDelegate: AnyObject {
    func filterHeaderPressed()
}

class InterventionFilterView: DesignableView {
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var optionLabel: UILabel?
    @IBOutlet weak var expandImage: UIImageView?
    @IBOutlet weak var separationView: UIView?
    
    weak var delegate: InterventionFilterViewDelegate?
    
    private var open: Bool = true {
        didSet {
            updateArrow()
            separationView?.isHidden = !open
        }
    }
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabels()
        configureImages()
        setAccessibilityIdentifiers()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        open = !open
        delegate?.filterHeaderPressed()
    }
    
    func setInterventionFilter(_ filter: PGInterventionFilter) {
        optionLabel?.text = localized(filter.desc())
    }
    
    func invertOpen() { open = !open }
    
    // MARK: - privateMethods
    
    private func configureView() {
        backgroundColor = UIColor.lightGray40
        separationView?.backgroundColor = UIColor.mediumSanGray
    }
    
    private func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, size: 16.0)
        titleLabel?.textColor = UIColor.mediumSanGray
        titleLabel?.text = localized("pg_label_filter_pb")
        optionLabel?.font = UIFont.santander(family: .text, size: 16.0)
        optionLabel?.textColor = UIColor.darkTorquoise
    }
    
    private func configureImages() {
        iconImage?.image = Assets.image(named: "icnUser")
        expandImage?.image = Assets.image(named: "icnExpandMore")
    }
    
    private func updateArrow() {
        let rotation = open ? CGAffineTransform.identity : self.transform.rotated(by: CGFloat.pi)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.expandImage?.transform = rotation
        }
        expandImage?.accessibilityIdentifier = open ? "interventionFilter_expendImageOpen" : "interventionFilter_expendImageClose"
    }
    
    private func setAccessibilityIdentifiers() {
        iconImage?.isAccessibilityElement = true
        expandImage?.isAccessibilityElement = true
        setAccessibility {
            self.iconImage?.isAccessibilityElement = false
            self.expandImage?.isAccessibilityElement = false
        }
        iconImage?.accessibilityIdentifier = "userIcn"
        titleLabel?.accessibilityIdentifier = "interventionFilter_titleLabel"
        optionLabel?.accessibilityIdentifier = "interventionFilter_optionLabel"
        expandImage?.accessibilityIdentifier = open ? "interventionFilter_expendImageOpen" : "interventionFilter_expendImageClose"
    }
}

extension InterventionFilterView: AccessibilityCapable { }
