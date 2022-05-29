//
//  Created by SYS_CIBER_ADMIN on 3/5/18.
//  Commons
//
//  Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public enum TimeManagerTimeZone {
    case local
    case utc
}

public protocol TimeManager {
    
    func fromString(input: String?, inputFormat: String) -> Date?
    
    func fromString(input: String?, inputFormat: String, timeZone: TimeManagerTimeZone) -> Date?

    func fromString(input: String?, inputFormat: TimeFormat) -> Date?
    
    func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date?
    
    func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String?

    func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String?

    func toString(date: Date?, outputFormat: TimeFormat) -> String?
    
    func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String?
    
    func getCurrentLocaleDate(inputDate: Date?) -> Date?
}

// swiftlint:disable identifier_name
public enum TimeFormat: String {
    case ddMMMyyyyHHmmss = "dd-MMM-yyyy HH:mm:ss"
    case ddMMyyyy = "dd-MM-yyyy"
    case dd_MM_yyyy = "dd/MM/yyyy"
    case HHmm = "HH:mm"
    case HHmmss = "HH:mm:ss"
    case HHmmssZ = "HH:mm:ssZ"
    case yyyyMMdd = "yyyy-MM-dd"
    case d_MMM_yyyy = "d MMM yyyy"
    case dd_MMM = "dd MMM"
    case dd_MMM_yyyy = "dd MMM yyyy"
    case dd_MMM_yy = "dd MMM yy"
    case dd_MMM_yyyy_point_HHmm = "dd MMM yyyy · HH:mm"
    case dd_MMM_yyyy_HHmm = "dd MMM yyyy HH:mm"
    case dd_MMMM_yyyy_comma_HHmm = "dd MMMM yyyy, HH:mm"
    case MMM_d = "MMM d"
    case d = "d"
    case dd_7_MM = "dd/MM"
    case d_MMM = "d MMM"
    case d_MMMM = "d MMMM"
    case d_MMM_yy = "d MMM yy"
    case MMM = "MMM"
    case MMyy = "MM/yy"
    case yyyyMM = "yyyyMM"
    case yyyy = "yyyy"
    case YYYYMMDD_T_HHMM = "yyyy-MM-dd'T'HH:mm:ss"
    case D_MMM_YYYY_7_HH_mm_ss = "d MMM yyyy / HH:mm:ss"
    case MMMM = "MMMM"
    case MMMM_YYYY = "MMMM yyyy"
    case dd_MMMM_YYYY = "dd MMMM yyyy"
    case d_MMMM_YYYY = "d MMMM yyyy"
    case dd_MM_yyyy_HH_mm = "dd-MM-yyy_HH:mm"
    case yyyy_MM_ddHHmmss = "yyyy-MM-dd HH:mm:ss"
    case yyyyMMddHHmmss = "yyyyMMddHHmmss"
    case eeee = "EEEE"
    case EEE_dd_MM = "EEEE, dd MMM"
    case EEE_dd_MM_yy = "EEEE, dd MMM yyyy"
    case d_MMM_eeee = "d MMM | EEEE"
    case d_MMM_eee = "d MMM | EEE"
    case d_MMM_yy_eee = "d MMM yy | EEE"
    case d_MMM_yyyy_eeee = "dd MMM yyyy | EEEE"
    case dd_MM_yy_HHmm = "dd MMM yy HH:mm"
    case eeee_HHmm = "EEEE HH:mm"
    case EEE_ddMM_HHmm = "EEE, dd/MM - HH:mm"
    case dd_MM_yyyy_HHmm = "dd/MM/yyyy HH:mm"
    case ddMMyyyy_HHmm = "dd-MM-yyyy HH:mm"
    case ddMMyyyy_HHmmss = "dd-MM-yyyy HH:mm:ss"
    case dd_MM_yy = "dd/MM/yy"
    case asteriskedDate = "d*/M*/yyy*"
    case dd_MMM_yyyy_hyphen_HHmm_h = "dd MMM yyyy - HH:mm'h'"
    case HH_mm_h = "HH:mm'h.'"
    case yyyy_MM_dd_HHmmSSms = "yyyy-MM-dd-HH.mm.ss.SSSSSS"
    case yyyyMMddTHHmmssSSSSSSZ = "yyyyMMdd'T'HHmmssSSSZ"
    case eeee_MMMM_YYYY = "eeee, d MMMM YYYY"
    case EEEEdMMMMYYYY = "EEEE d MMMM YYYY"
    case M = "M"
    case yyyy_MM_dd = "yyyyMMdd"
    case MM_YYYY = "MMM. yyyy"
    case dd_MM_yyyy_hyphen_HHmm_h = "dd/MM/yyyy - HH:mm'h'"
    case yyyy_MM_ddTHHmmssSSSSSS = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case MMM_yyyy = "MMM yyyy"
    case yyyy_MMdd = "yyyy/MM/dd"
}
// swiftlint:enable identifier_name
