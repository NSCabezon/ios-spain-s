import UI

extension CGColor {
    func toUIColor() -> UIColor {
        return UIColor(cgColor: self)
    }
}

extension UIColor {
    @nonobjc class var popularMagenta: UIColor {
        return UIColor(red: 229 / 255, green: 0, blue: 83 / 255, alpha: 1.0)
    }
    
    static func fromHex(_ hexColor: String) -> UIColor {
        var rgbValue: UInt32 = 0
        Scanner(string: hexColor.replacingOccurrences(of: "#", with: "")).scanHexInt32(&rgbValue)
        let components = (
            R: CGFloat((rgbValue >> 16) & 0xff) / 255,
            G: CGFloat((rgbValue >> 08) & 0xff) / 255,
            B: CGFloat((rgbValue >> 00) & 0xff) / 255
        )
        let cgColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [components.R, components.G, components.B, 1])!
        return cgColor.toUIColor()
    }
}


enum DetailCardCellAndViewThemeColor {
    case headliners
    case bodyText
    case subHeadings
    case iconTints
    case iconBackgrounds
    case tableViewSeperators
    case callButton
    case appointmentButton
    case buttonBackground
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
    case newAddtionalInfoForMainRelatedPOIBodyFormat1
    case dragButton
    case closingInLabel
    case closingLabelCircleViewOrange
    case closingLabelCircleViewRed
    case closingLabelCircleViewGreen
}

extension DetailCardCellAndViewThemeColor {
    var value: UIColor {
        var colors = UIColor.clear
        switch self {
        case .headliners:
            colors = .mediumSanGray
        case .bodyText:
            colors = .lisboaGray
        case .subHeadings:
            colors = .lisboaGray
        case .iconTints:
            colors = .santanderRed
        case .iconBackgrounds:
            colors = .white
        case .tableViewSeperators:
            colors = .mediumSky
        case .callButton:
            colors = .santanderRed
        case .appointmentButton:
            colors = .santanderRed
        case .buttonBackground:
            colors = .white
        case .blueButtons:
            colors = .lisboaBlue
        case .closestBranchLabel:
            colors = .santanderRed
        case .santanderLbl:
            colors = .mediumSanGray
        case .branchInfoLbl:
            colors = .mediumSanGray
        case .streetDataLbl:
            colors = .mediumSanGray
        case .rightAndLeftStatusLabelTitle:
            colors = .lisboaGray
        case .rightAndLeftStatusLabelBody:
            colors = .mediumSanGray
        case .daysOfWeek:
            colors = .lisboaGray
        case .openingTimesOfWeek:
            colors = .lisboaGray
        case .statusBranchBranchView:
            colors = .lisboaGray
        case .newAddtionalInfoForFirstRelatedPOITitle:
            colors = .lisboaGray
        case .newAddtionalInfoForFirstRelatedPOIBody:
            colors = .lisboaGray
        case .newAddtionalInfoForMainRelatedPOITitle:
            colors = .lisboaGray
        case .newAddtionalInfoForMainRelatedPOIBody:
            colors = .lisboaGray
        case .newAddtionalInfoForMainRelatedPOIBodyFormat1:
            colors = .santanderRed
        case .dragButton:
            colors = .lisboaGray
        case .closingInLabel:
            colors = .lisboaGray
        case .closingLabelCircleViewOrange:
            colors = .santanderYellow
        case .closingLabelCircleViewRed:
            colors = .santanderRed
        case .closingLabelCircleViewGreen:
            colors = .limeGreen
        }
        return colors
    }
}


enum MapViewControllerThemeColor {
    case searchAgainButtonSelected
    case searchAgainButtonUnselected
    case buttonFilterAttrString
    case locationMapButtonTintColor
    case locationMapButtonWhenInUse
    case locationMapButtonBackgroundColor
    case locationMapButtonNotDetermined
    case iconColors
    case filterIcon
    case clusterViewBackground
    case clusterViewTextColor
}

extension MapViewControllerThemeColor {
    var value: UIColor {
        var colors = UIColor.clear
        switch  self {
            
        case .searchAgainButtonSelected:
            colors = .mediumSanGray
        case .searchAgainButtonUnselected:
            colors = .lightSanGray
        case .buttonFilterAttrString:
            colors = .mediumSanGray
        case .locationMapButtonTintColor:
            colors = .lisboaGray
        case .locationMapButtonWhenInUse:
            colors = .lisboaGray
        case .locationMapButtonBackgroundColor:
            colors = .white
        case .locationMapButtonNotDetermined:
            colors = .lightSanGray
        case .iconColors:
            colors = UIColor.santanderRed
        case .filterIcon:
            colors = .mediumSanGray
        case .clusterViewBackground:
            colors = .white
        case .clusterViewTextColor:
            colors = .santanderRed
        }
        return colors
    }
}

enum  MapBarContainerViewColor {
    case bottomSeperatorView
    case bottomSeperatorViewSelected
    case bottomSeperatorViewUnselected
    case centerView
    case rightLeftLabelsSelected
    case rightLeftLabelsUnselected
}

extension MapBarContainerViewColor {
    var value: UIColor {
        var colors = UIColor.clear
        
        switch self {
            
        case .bottomSeperatorView:
            colors = .mediumSky
        case .bottomSeperatorViewSelected:
            colors = .santanderRed
        case .bottomSeperatorViewUnselected:
            colors = .mediumSky
        case .centerView:
            colors = .mediumSky
        case .rightLeftLabelsSelected:
            colors = .lisboaGray
        case .rightLeftLabelsUnselected:
            colors = .mediumSanGray
            
        }
        return colors
    }
}

enum  DetailButtonsSectionTableViewColor {
    case bottomSeperatorView
    case bottomSeperatorViewSelected
    case bottomSeperatorViewUnselected
    case centerView
    case rightLeftLabelsSelected
    case rightLeftLabelsUnselected
}

extension DetailButtonsSectionTableViewColor {
    var value: UIColor {
        var colors = UIColor.clear
        
        switch self {
            
        case .bottomSeperatorView:
            colors = .mediumSky
        case .bottomSeperatorViewSelected:
            colors = .santanderRed
        case .bottomSeperatorViewUnselected:
            colors = .mediumSky
        case .centerView:
            colors = .mediumSky
        case .rightLeftLabelsSelected:
            colors = .lisboaGray
        case .rightLeftLabelsUnselected:
            colors = .mediumSanGray
            
        }
        return colors
    }
}

enum  FilterTableViewCellColor {
    case titleUnselected
    case titleSelected
    case iconBorderSelected
    case iconSelectedBackground
    case iconBorderUnselected
    case tableViewCellBackground
}

extension FilterTableViewCellColor {
    var value: UIColor {
        var colors = UIColor.clear
        switch self {
        case .titleUnselected:
            colors = .mediumSanGray
        case .titleSelected:
            colors = .lisboaGray
        case .iconBorderSelected:
            colors = .santanderRed
        case .iconSelectedBackground:
            colors = .white
        case .iconBorderUnselected:
            colors = .mediumSanGray
        case .tableViewCellBackground:
            colors = UIColor.paleGrey
        }
        return colors
    }
}

enum FilterTableViewColor {
    case filterTitle
    case applyButton
    case clearButton
    case filterTableViewBackgroundColor
    case headerText
    case customBorder
    case viewBackground
    case applyButtonTitle
}
extension FilterTableViewColor {
    var value: UIColor {
        var colors = UIColor.clear
        switch self {
        case .filterTitle:
            colors = .lisboaGray
        case .applyButton:
            colors = .santanderRed
        case .clearButton:
            colors = .santanderRed
        case .filterTableViewBackgroundColor:
            colors = .paleGrey
        case .headerText:
            colors = .lisboaGray
        case .customBorder:
            colors = .mediumSky
        case .viewBackground:
            colors = .paleGrey
        case .applyButtonTitle:
            colors = .white
        }
        return colors
    }
}

enum ListViewColor {
    case title
    case subtitle
    case arrow
    case distanceLabel
}

extension ListViewColor {
    var value: UIColor{
        var colors = UIColor.clear
        switch self {
        case .title:
            colors = .santanderRed
        case .subtitle:
            colors = .mediumSanGray
        case .arrow:
            colors = .mediumSanGray
        case .distanceLabel:
            colors = .mediumSanGray
        }
        return colors
    }
}
