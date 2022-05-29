import UI

enum DetailCardCellAndViewThemeFont {
    
    case headliners
    case bodyText
    case subHeadings
    case callButton
    case appointmentButton
    case blueButtons
    case closestBranchLabel
    case santanderLbl
    case branchInfoLbl
    case streetDataLbl
    case rightAndLeftStatusLabelTitle
    case rightAndLeftStatusLabelBody
    case daysOfWeek
    case openingTimesOfWeek
    case statusBranchBranchView
    case newAddtionalInfoForFirstRelatedPOITitle
    case newAddtionalInfoForFirstRelatedPOIBody
    case newAddtionalInfoForMainRelatedPOITitle
    case newAddtionalInfoForMainRelatedPOIBody
    case newAddtionalInfoForMainRelatedPOIBodyFormat2
    case closingInLabel
    
}

extension DetailCardCellAndViewThemeFont {
    var value: UIFont {
        var fonts: UIFont
        switch self {
        case .headliners:
            fonts = .santander(family: .headline, type: .regular, size: 14)
        case .bodyText:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .subHeadings:
            fonts = .santander(family: .headline, type: .bold, size: 16)
        case .callButton:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .appointmentButton:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .blueButtons:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .closestBranchLabel:
            fonts = .santander(family: .headline, type: .bold, size: 14)
        case .santanderLbl:
            fonts = .santander(family: .text, type: .bold, size: 16)
        case .branchInfoLbl:
            fonts = .santander(family: .text, type: .light, size: 14)
        case .streetDataLbl:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .rightAndLeftStatusLabelTitle:
            fonts = .santander(family: .text, type: .bold, size: 15)
        case .rightAndLeftStatusLabelBody:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .daysOfWeek:
            fonts = .santander(family: .text, type: .bold, size: 15)
        case .openingTimesOfWeek:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .statusBranchBranchView:
            fonts = .santander(family: .text, type: .regular, size: 14)
        case .newAddtionalInfoForFirstRelatedPOITitle:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .newAddtionalInfoForFirstRelatedPOIBody:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .newAddtionalInfoForMainRelatedPOITitle:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .newAddtionalInfoForMainRelatedPOIBody:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .newAddtionalInfoForMainRelatedPOIBodyFormat2:
            fonts = .santander(family: .text, type: .bold, size: 15)
        case .closingInLabel:
            fonts = .santander(family: .text, type: .regular, size: 14)
        }
        return fonts
    }
}


enum MapViewControllerThemeFont {
    case searchAgainButton
    case buttonFilterAttrString
}

extension MapViewControllerThemeFont {
    var value: UIFont {
        var fonts: UIFont
        switch  self {
        case .searchAgainButton:
            fonts = .santander(family: .text, type: .italic, size: 14)
        case .buttonFilterAttrString:
            fonts = .santander(family: .text, type: .regular, size: 16)
        }
        return fonts
    }
}



enum  MapBarContainerViewFont {
    case rightLeftLabelsSelected
    case rightLeftLabelsUnselected
}


extension MapBarContainerViewFont {
    var value: UIFont {
        var fonts: UIFont
        switch self {
        case .rightLeftLabelsSelected:
            fonts = .santander(family: .text, type: .bold, size: 16)
        case .rightLeftLabelsUnselected:
            fonts = .santander(family: .text, type: .regular, size: 16)
        }
        return fonts
    }
}


enum  DetailButtonsSectionTableViewFont {
    case rightLeftLabelsSelected
    case rightLeftLabelsUnselected
}



extension DetailButtonsSectionTableViewFont {
    var value: UIFont {
        var fonts: UIFont
        switch self {
        case .rightLeftLabelsSelected:
            fonts = .santander(family: .text, type: .bold, size: 16)
        case .rightLeftLabelsUnselected:
            fonts = .santander(family: .text, type: .regular, size: 16)
        }
        return fonts
    }
}


enum  FilterTableViewCellFont {
    case titleUnselected
    case titleSelected
}

extension FilterTableViewCellFont {
    var value: UIFont {
        var fonts: UIFont
        switch self {
        case .titleUnselected:
            fonts = .santander(family: .text, type: .regular, size: 16)
        case .titleSelected:
            fonts = .santander(family: .text, type: .bold, size: 18)
        }
        return fonts
    }
}


enum FilterTableViewFont {
    case filterTitle
    case clearButton
    case headerText
    case applyButtonTitle
}
extension FilterTableViewFont {
    var value: UIFont {
        var fonts: UIFont
        switch self {
        case .filterTitle:
            fonts = .santander(family: .text, type: .bold, size: 16)
        case .clearButton:
            fonts = .santander(family: .text, type: .regular, size: 12)
        case .headerText:
            fonts = .santander(family: .text, type: .bold, size: 16)
        case .applyButtonTitle:
            fonts = .santander(family: .text, type: .bold, size: 16)
        }
        return fonts
    }
}


enum ListViewFont {
    case title
    case subtitle
    case distanceLabel
}

extension ListViewFont {
    var value: UIFont{
        var fonts: UIFont
        switch self {
        case .title:
           fonts = .santander(family: .text, type: .bold, size: 16)
        case .subtitle:
            fonts = .santander(family: .text, type: .regular, size: 15)
        case .distanceLabel:
            fonts = .santander(family: .text, type: .regular, size: 14)
        }
        return fonts
    }
}
