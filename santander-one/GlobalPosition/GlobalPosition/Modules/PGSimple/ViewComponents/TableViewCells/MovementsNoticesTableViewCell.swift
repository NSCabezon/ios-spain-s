//
//  MovementsNoticesTableViewCell.swift
//  toTest
//
//  Created by alvola on 14/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib

final class MovementsNoticesTableViewCell: UITableViewCell, GeneralPGCellProtocol {
    
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var noMovementsLabel: UILabel?
    @IBOutlet weak var loadingImageView: UIImageView?
    
    private var state: PGMovementsNoticesCellState = .none {
        didSet {
            refreshState()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        state = .none
    }
    
    func setCellInfo(_ info: Any?) {
        guard let state = info as? PGMovementsNoticesCellState else { return }
        self.state = state
    }
    
    private func commonInit() {
        configureView()
        configureLabel()
        refreshState()
        configureLoadingImg()
    }
    
    private func configureView() {
        selectionStyle = .none
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.paleGray.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor

        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.botonRedLight.cgColor
    }
    
    private func configureLabel() {
        noMovementsLabel?.text = localized("pg_text_noAvailableActivity")
        noMovementsLabel?.font = UIFont.santander(family: .text, type: .italic, size: 15.0)
        noMovementsLabel?.textColor = UIColor.lisboaGray
    }
    
    private func configureLoadingImg() {
        loadingImageView?.isHidden = true
        loadingImageView?.setPointsLoader()
    }
    
    private func refreshState() {
        state != .loading ? loadingImageView?.removeLoader() : loadingImageView?.setPointsLoader()
        
        loadingImageView?.isHidden = state != .loading
        noMovementsLabel?.isHidden = state != .noResults
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 73.0)
    }
}

// MARK: - RoundedCellProtocol

extension MovementsNoticesTableViewCell: RoundedCellProtocol {
    func roundCorners() { frameView?.roundAllCorners() }
    func roundTopCorners() { frameView?.roundTopCorners() }
    func roundBottomCorners() { frameView?.roundBottomCorners() }
    func removeCorners() { frameView?.removeCorners() }
    func onlySideFrame() { frameView?.onlySideFrame() }
}
