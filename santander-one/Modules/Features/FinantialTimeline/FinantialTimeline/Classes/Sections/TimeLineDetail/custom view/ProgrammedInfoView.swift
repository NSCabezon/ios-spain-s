//
//  ProgrammedInfoView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/08/2019.
//

import UIKit

class ProgrammedInfoView: UIView {
    @IBOutlet var container: UIView!
    @IBOutlet weak var issueDateTitleLabel: UILabel!
    @IBOutlet weak var issueDateInfoLabel: UILabel!
    @IBOutlet weak var arrangmentDateTitleLabel: UILabel!
    @IBOutlet weak var arrangmentDateInfoLabel: UILabel!
    @IBOutlet weak var toTitleLabel: UILabel!
    @IBOutlet weak var toinfoLabel: UILabel!
    @IBOutlet weak var frecuencyTitleLabel: UILabel!
    @IBOutlet weak var frecuencyInfoLabel: UILabel!
    @IBOutlet weak var toView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: ProgrammedInfoView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
    
    private func prepareUI() {
        toView.isHidden = true
        prepareTitleLabels()
        prepareInfoLabels()
    }
    
    private func prepareTitleLabels() {
        prepare(issueDateTitleLabel, with: .greyishBrown, and: .santanderText(type: .regular, with: 14))
        issueDateTitleLabel.text = TimeLineDetailString().deferredIssueDate
        prepare(arrangmentDateTitleLabel, with: .greyishBrown, and: .santanderText(type: .regular, with: 14))
        arrangmentDateTitleLabel.text = TimeLineDetailString().arrangementDate
        prepare(toTitleLabel, with: .greyishBrown, and: .santanderText(type: .regular, with: 14))
        toTitleLabel.text = TimeLineDetailString().toTitle
        prepare(frecuencyTitleLabel, with: .greyishBrown, and: .santanderText(type: .regular, with: 14))
        frecuencyTitleLabel.text = TimeLineDetailString().frequency
    }
    
    private func prepareInfoLabels() {
        prepare(issueDateInfoLabel, with: .greyishBrown, and: .santanderText(type: .light, with: 14))
        prepare(arrangmentDateInfoLabel, with: .greyishBrown, and: .santanderText(type: .light, with: 14))
        arrangmentDateInfoLabel.text = TimeLineDetailString().undefined
        prepare(toinfoLabel, with: .greyishBrown, and: .santanderText(type: .light, with: 14))
        prepare(frecuencyInfoLabel, with: .greyishBrown, and: .santanderText(type: .light, with: 14))
    }
    
    private func prepare(_ label: UILabel, with color: UIColor, and font: UIFont) {
        label.textColor = color
        label.font = font
    }
    
    func set(_ deferred: TimeLineEvent.DeferredDetails) {
        issueDateInfoLabel.text = deferred.issueDate?.string(format: .ddMMyyyy)
        if deferred.receiverAccount != nil && deferred.receiverAccount != "" {
            toView.isHidden = false
            toinfoLabel.text = deferred.receiverAccount
        }        
        frecuencyInfoLabel.text = setFrequencyString(fromString: deferred.frequency)
        guard let arrangement = deferred.schedulingDate else { return }
        arrangmentDateInfoLabel.text = arrangement.string(format: .ddMMyyyy)
    }
    
    private func setFrequencyString(fromString string: String?) -> String {
        guard let thisString = string else { return "" }
        switch thisString {
        case Frequency.annually.rawValue: return IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.annually")
        case Frequency.monthly.rawValue: return IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.monthly")
        case Frequency.everyTwoWeeks.rawValue: return IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.twoweeks")
        case Frequency.weekly.rawValue: return IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.weekly")
        case Frequency.withoutFrequency.rawValue: return IBLocalizedString("timeline.timelinedetailSection.defferred.frequency.none")
        default: return ""
        }
    }
    
}
