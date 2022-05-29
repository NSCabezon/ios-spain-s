//
//  TimeLineListStrategy.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 07/01/2020.
//

import Foundation

class TimeLineListStrategy {
    var view: TimeLineViewController
    
    init(view: TimeLineViewController) {
        self.view = view
    }
}

extension TimeLineListStrategy: TLStrategy {
    
    func onFailure(with title: String, error: Error, type: TimeLineEventsErrorType) {
        view.errorView.layer.borderWidth = 0.0
        view.errorImageWidth.constant = 53
        view.errorImageHeight.constant = 54
        view.titleErrorLabel.font = .santanderHeadline(type: .bold, with: 22)
        view.titleErrorLabel.text = GeneralString().timeLineErrorTitle
        view.titleErrorLabel.textColor = UIColor(white: 0.36, alpha: 1.0)
        view.errorLabel.font = .santanderHeadline(type: .regular, with: 16)
        view.errorLabel.textColor = UIColor(white: 0.36, alpha: 1.0)
        view.errorLabel.text = GeneralString().timeLineErrorDescripcion
        view.errorView.isHidden = false
        view.loadingContainerView.isHidden = true
        view.timelineTableView.isHidden = true
        view.errorImage.image =  UIImage(fromModuleWithName: "icnAlert")
        view.monthsSelectorContainer.isHidden = false
        view.monthsSelectorContainer.isUserInteractionEnabled = false
        view.menuView.isHidden = type == .error
        view.errorWidgetView.isHidden = true
        view.stackViewError.isHidden = false
        view.errorView.backgroundColor = .white
        view.view.backgroundColor = .white
        view.monthSeparatorView.isHidden = false
        view.loadingLabelContainerView.isHidden = true
    }
    
    func onLoading() {
        view.view.backgroundColor = .sky30
        view.timelineTableView.backgroundColor = .white
        view.loadingContainerView.isHidden = false
        view.loadingTitle.text = GeneralString().loading
        view.loadingDescription.text = GeneralString().loadingLabel
        view.safeConnectionLabel.text = GeneralString().safeConnectionLabel
        view.loadingView.setAnimationImagesWith(prefixName: "BS_", range: 1...154, format: "%03d")
        view.loadingView.startAnimating()
        view.errorView.isHidden = true
        view.timelineTableView.isHidden = true
        view.monthsSelectorContainer.isHidden = true
        view.monthsSelectorContainer.isUserInteractionEnabled = false
        view.menuView.isHidden = true
        view.monthSeparatorView.isHidden = true
        view.loadingLabelContainerView.isHidden = false
    }
    
    func onSucces(with sections: [TimeLineSection], completion: @escaping () -> Void) {
        view.view.backgroundColor = .sky30
        view.monthSeparatorView.isHidden = false
        view.timelineTableView.backgroundColor = .white
        view.timelineTableView.isHidden = false
        view.errorView.isHidden = true
        view.loadingContainerView.isHidden = true
        view.timeLineSections = sections
        view.monthsSelectorContainer.isHidden = false
        view.monthsSelectorContainer.isUserInteractionEnabled = true
        view.menuView.isHidden = false
        view.loadingLabelContainerView.isHidden = true
        view.timelineTableView.alpha = 0.0
        view.timelineTableView.reloadData { [weak self] in
            guard let self = self else { return }
            if self.view.didScrool {
                self.view.scrollToLastDate()
            }
            self.view.selectCurrentFirstMonth()
            self.view.presenter?.timeLineLoaded()
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.view.timelineTableView.alpha = 1.0
                }, completion: { finished in
                    guard finished == true else { return }
                    completion()
                }
            )
        }
    }
    
    func mapComingResult(_ timeLine: TimeLineEvents) -> TimeLineEvents {
        return timeLine
    }
    
    func isList() -> Bool {
        return true
    }
    
    func shouldPresentFooter() -> Bool {
        return true
    }
    
    func getTopLoaderHeight() -> CGFloat {
        return 43
    }
    
    func timeLineEventNumberOfLines() -> Int {
        return 0
    }
    
    func timeLineEventLineHeightMultiplier() -> CGFloat {
        return 1.0
    }
}
