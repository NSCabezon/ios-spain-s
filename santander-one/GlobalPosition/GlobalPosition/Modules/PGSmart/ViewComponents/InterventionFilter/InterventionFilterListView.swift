//
//  InterventionFilterListView.swift
//  GlobalPosition
//
//  Created by alvola on 07/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol InterventionFilterListViewDelegate: AnyObject {
    func filterPressed(_ filter: PGInterventionFilter)
}

final class InterventionFilterListView: DesignableView {

    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet var filterLabels: [UILabel]?
    
    weak var delegate: InterventionFilterListViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureLabels()
    }
    
    func setInterventionFilter(_ filter: PGInterventionFilter) {
        setFilterLabel(filter)
    }
    
    func refreshLabels() {
        let filterKeys = PGInterventionFilter.allCases
        filterLabels?.enumerated().forEach({
            guard $0.offset < filterKeys.count else { return }
            $0.element.text = localized(filterKeys[$0.offset].desc())
        })
    }
    
    // MARK: - privateMethods
    
    private func configureView() {
        backgroundColor = UIColor.lightGray40
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameStrokeColor = UIColor.lightSkyBlue.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.roundBottomCornersJoined()
        
        frameView?.layer.masksToBounds = false
        frameView?.layer.shadowRadius = 4
        frameView?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        frameView?.layer.shadowOpacity = 0.5
        frameView?.layer.shadowColor = UIColor.lightSanGray.cgColor
    }
    
    private func setFilterLabel(_ filter: PGInterventionFilter?) {
        let filterKeys = PGInterventionFilter.allCases
        filterLabels?.enumerated().forEach({
            guard $0.offset < filterKeys.count else { return }
            $0.element.font = UIFont.santander(family: .text, type: ((filter == filterKeys[$0.offset]) ? .bold : .regular), size: 15.0)
            $0.element.textColor = (filter == filterKeys[$0.offset]) ? UIColor.darkTorquoise : UIColor.lisboaGray
        })
    }
    
    private func configureLabels() {
        let filterKeys = PGInterventionFilter.allCases
        filterLabels?.enumerated().forEach({
            guard $0.offset < filterKeys.count else { return }
            $0.element.font = UIFont.santander(family: .text, size: 15.0)
            $0.element.textColor = UIColor.lisboaGray
            $0.element.text = localized(filterKeys[$0.offset].desc())
            $0.element.tag = $0.offset
            $0.element.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelDidPressed(_:))))
            $0.element.isUserInteractionEnabled = true
            $0.element.accessibilityIdentifier = filterKeys[$0.offset].desc()
        })
    }
    
    @objc private func labelDidPressed(_ sender: UITapGestureRecognizer) {
        let filterKeys = PGInterventionFilter.allCases
        guard let tag = sender.view?.tag, tag < filterKeys.count else { return }
        delegate?.filterPressed(filterKeys[tag])
    }
}
