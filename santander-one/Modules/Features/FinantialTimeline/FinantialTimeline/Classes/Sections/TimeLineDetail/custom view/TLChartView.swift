//
//  ChartView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 09/10/2019.
//

import UIKit
//import Charts

class TLChartView: UIView {
    @IBOutlet var container: UIView!
    @IBOutlet weak var chartViewTLDetail: UIView!
    @IBOutlet weak var disclaimerLabel: UILabel!
    @IBOutlet weak var disclaimerView: UIView!
    
    weak var delegate: TLChartViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
       
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
       
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: TLChartView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        preapreDisclaimer()
    }
    
    func preapreDisclaimer() {
        disclaimerLabel.font = .santanderText(type: .regular, with: 12)
        disclaimerLabel.textColor = .brownishGrey
        disclaimerLabel.text = TimeLine.dependencies.textsEngine.getGroupedMonthsDisclaimer()
    }
    
    func renderChartWith(_ activity: [TimeLineEvent.Activity], event: TimeLineEvent, delegate: TLChartViewDelegate?, hasGroupedMonths: Bool) {
        self.delegate = delegate
        self.disclaimerView.isHidden = !hasGroupedMonths
    }
    
    func getGradient() -> CGGradient? {
        // Fill Gradient Color
        let colorTop =  UIColor.blueGraphic.cgColor
        let colorBottom = UIColor.white.cgColor
        let gradientColors = [colorTop, colorBottom] as CFArray
        let colorLocations: [CGFloat] = [1.0, 0.2]
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
    }

}

protocol TLChartViewDelegate: AnyObject {
    func onTapXAxis(_ axis: Double)
}
