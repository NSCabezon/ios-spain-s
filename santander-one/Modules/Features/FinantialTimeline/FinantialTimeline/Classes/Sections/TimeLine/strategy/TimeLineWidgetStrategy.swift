//
//  TimeLineWidgetStrategy.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 07/01/2020.
//

import Foundation

class TimeLineWidgetStrategy {
    var view: TimeLineViewController
    var numEvents: Int
    var numDays: Int
    var isMaxElements = false
    
    init(view: TimeLineViewController, numEvents: Int, numDays: Int) {
        self.view = view
        self.numEvents = numEvents
        self.numDays = numDays
    }
    
    func prepareUI() {
        view.view.backgroundColor = .white
        view.timelineTableView.backgroundColor = .white
        view.view.isUserInteractionEnabled = false
        view.menuView.isHidden = true
        view.monthsSelectoHeight.constant = 0
        view.monthsSelectorContainer.isHidden = true
        view.monthsSelectorContainer.isUserInteractionEnabled = false
    }
}

extension TimeLineWidgetStrategy: TLStrategy {
    
    func onFailure(with title: String, error: Error, type: TimeLineEventsErrorType) {
        prepareUI()
        view.errorView.layer.borderWidth = 0.0
        view.titleErrorWidgetLabel.font = .santanderHeadline(type: .bold, with: 18)
        view.titleErrorWidgetLabel.text = GeneralString().timeLineErrorWidgetTitle
        view.titleErrorWidgetLabel.textColor = .black
        view.subtitleErrorWidgetLabel.font = .santanderText(type: .regular, with: 16)
        view.subtitleErrorWidgetLabel.textColor = .black
        view.subtitleErrorWidgetLabel.text = GeneralString().timeLineErrorWidgetDescripcion
        view.errorWidgetView.isHidden = false
        view.errorView.isHidden = false
        view.loadingContainerView.isHidden = true
        view.timelineTableView.isHidden = true
        view.stackViewError.isHidden = true
        view.errorWidgetImageView.image =  UIImage(fromModuleWithName: "imgLeaves")
        view.menuView.isHidden = type == .error
    }
    
    func onLoading() {
        prepareUI()
        view.view.backgroundColor = .sky30
        view.timelineTableView.backgroundColor = .white
        view.loadingContainerView.isHidden = false
        view.loadingTitle.text = GeneralString().loading
        view.loadingDescription.text = GeneralString().loadingLabel
        view.loadingView.setAnimationImagesWith(prefixName: "BS_", range: 1...154, format: "%03d")
        view.loadingView.startAnimating()
        view.errorView.isHidden = true
        view.timelineTableView.isHidden = true
    }
    
    func onSucces(with sections: [TimeLineSection], completion: @escaping () -> Void) {
        prepareUI()
        guard sections.count > 0 else {
            view.timelineTableView.isHidden = true
            return onFailure(with: "", error: NSError(), type: .noEvents)
        }
        view.timelineTableView.isHidden = false
        view.errorView.isHidden = true
        view.loadingContainerView.isHidden = true
        view.timeLineSections = sections
        view.timelineTableView.reloadData { [weak self] in
            self?.view.selectCurrentFirstMonth()
            self?.view.presenter?.timeLineLoaded()
            if self?.view.didScrool ?? false {
                self?.view.scrollToLastDate()
            }
            completion()
        }
    }
    
    func mapComingResult(_ timeLine: TimeLineEvents) -> TimeLineEvents {
        guard self.isMaxElements == false else { return TimeLineEvents(offset: timeLine.offset, events: FailableCodableArray(elements: [])) }
        let filteredAndSortedEvents = timeLine.events
            .filter { $0.date < Date().adding(.day, value: numDays - 1) }
            .sorted(by: { $0.date < $1.date })
            .prefix(numEvents)
        let events = Array(filteredAndSortedEvents)
        self.isMaxElements = events.count == numEvents
        let tlEvents: FailableCodableArray<TimeLineEvent> = FailableCodableArray(elements: events)
        let timeLineItem = TimeLineEvents(offset: timeLine.offset, events: tlEvents)
        return timeLineItem
    }
    
    func isList() -> Bool {
        false
    }
    
    func shouldPresentFooter() -> Bool {
//        return !isMaxElements
        return false
    }
    
    func getTopLoaderHeight() -> CGFloat {
        return 0
    }
    
    func timeLineEventNumberOfLines() -> Int {
        return 6
    }
    
    func timeLineEventLineHeightMultiplier() -> CGFloat {
        return 0.75
    }
}
