//
//  PGBookMarkCollectionViewCell.swift
//  GlobalPosition
//
//  Created by César González Palomino on 08/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class TimeLineCollectionViewCell: UICollectionViewCell {
    
    private var timeLineView: TimeLineWidgetView?
    private var timeLineViewConfigured = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLineViewConfigured = false
        guard let timeLineView = timeLineView else { return }
        timeLineView.removeFromSuperview()
        self.timeLineView = nil
    }
    
    func configureImageWith(resolver: DependenciesResolver) {
        configureTimeLineView(resolver: resolver)
    }
    
    private func configureTimeLineView(resolver: DependenciesResolver) {
        guard timeLineViewConfigured == false else { return }
        let timeLineView = TimeLineWidgetView(frame: .zero)
        contentView.addSubview(timeLineView)
        self.timeLineView = timeLineView
        timeLineView.dependenciesResolver = resolver
        timeLineView.setup()
        timeLineView.fullFit()
        timeLineView.drawRoundedAndShadowedNew(borderColor: .mediumSkyGray)
        timeLineView.layer.masksToBounds = true
        
        timeLineViewConfigured = true
    }
}
