//
//  OneInputCodeBoxViewBorderBuilder.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 2/3/22.
//

import CoreFoundationLib

enum OneInputCodeBoxViewBorderBuilder {
    private enum Constants {
        static let cornerRadius: CGFloat = 8.0
        static let internalBorderWidth: CGFloat = 0.5
        static let externalBorderWidth: CGFloat = 1.0
    }
    
    static func configureBorder(for view: UIView, position: OneInputCodeBoxViewPosition, status: OneInputCodeBoxViewStatus) {
        switch position {
        case .first:
            self.addFirstBorders(for: view, status: status)
        case .middle:
            self.addMiddleBorders(for: view, status: status)
        case .last:
            self.addLastBorders(for: view, status: status)
        }
    }
    
    private static func addFirstBorders(for view: UIView,
                                        status: OneInputCodeBoxViewStatus) {
        view.addLayer(path: CGMutablePath.rightLessRoundedPath(in: view.bounds, radius: Constants.cornerRadius),
                      color: status.externalBorderColor,
                      width: Constants.externalBorderWidth)
        view.addLayer(path: CGMutablePath.rightPath(in: view.bounds),
                      color: status.internalBorderColor,
                      width: Constants.internalBorderWidth)
    }
    
    private static func addMiddleBorders(for view: UIView,
                                         status: OneInputCodeBoxViewStatus) {
        view.addLayer(path: CGMutablePath.topBottomPath(in: view.bounds),
                      color: status.externalBorderColor,
                      width: Constants.externalBorderWidth)
        view.addLayer(path: CGMutablePath.leftPath(in: view.bounds),
                      color: status.internalBorderColor,
                      width: Constants.internalBorderWidth)
        view.addLayer(path: CGMutablePath.rightPath(in: view.bounds),
                      color: status.internalBorderColor,
                      width: Constants.internalBorderWidth)
    }
    
    private static func addLastBorders(for view: UIView,
                                       status: OneInputCodeBoxViewStatus) {
        view.addLayer(path: CGMutablePath.leftLessRoundedPath(in: view.bounds, radius: Constants.cornerRadius),
                            color: status.externalBorderColor,
                            width: Constants.externalBorderWidth)
        view.addLayer(path: CGMutablePath.leftPath(in: view.bounds),
                      color: status.internalBorderColor,
                      width: Constants.internalBorderWidth)
    }
}
