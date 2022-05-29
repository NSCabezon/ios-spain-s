//
//  TimeLineView.swift
//  GlobalPosition
//
//  Created by José Carlos Estela Anguita on 20/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class TimeLineWidgetView: UIView {
    @IBOutlet weak var favoriteIconImageView: UIImageView!
    @IBOutlet weak var widgetContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goToTimeLineLabel: UILabel!
    @IBOutlet weak var goToTimeLineImageView: UIImageView!
    @IBOutlet weak var headerView: RoundedView!
    var view: UIView?
    var dependenciesResolver: DependenciesResolver?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    private lazy var timeLineView: UIView? = {
        let view = self.dependenciesResolver?.resolve(optionalWithIdentifier: "TimeLineView", type: UIView.self)
        view?.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func setup() {
        self.headerView.frameBackgroundColor = UIColor.blueAnthracita.cgColor
        self.headerView.backgroundColor = .clear
        self.headerView.roundTopCorners()
        self.configureTimeLineView()
        self.favoriteIconImageView.image = Assets.image(named: "iconMarker")
        self.titleLabel.configureText(withKey: "timeline_title_nextDays",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0)))
        self.goToTimeLineLabel.textColor = .santanderRed
        self.goToTimeLineLabel.configureText(withKey: "timeline_label_financialAgenda",
                                             andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16.0)))
        self.goToTimeLineImageView.image = Assets.image(named: "icnGo")
        self.setAccessibility()
    }
}

private extension TimeLineWidgetView {
    func configureTimeLineView() {
        guard let timeLineView = self.timeLineView else { return }
        if self.widgetContainerView.subviews.contains(timeLineView) { return }
        self.widgetContainerView.addSubview(timeLineView)
        timeLineView.fullFit()
    }
    
    func setAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = self.titleLabel.text
        self.accessibilityLabel = self.titleLabel.attributedText?.string
        self.accessibilityValue = self.goToTimeLineLabel.attributedText?.string
        self.accessibilityTraits = .button
    }
}

extension TimeLineWidgetView: XibInstantiable {
    
    var bundle: Bundle? {
        Bundle(for: TimeLineWidgetView.self)
    }
}
