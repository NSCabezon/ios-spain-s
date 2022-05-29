import Foundation
import CoreFoundationLib
import RetailLegacy

extension NormalizedStyling {
    
    init?(style: LocaleManager.StringStyling) {
        let start = style.startPosition
        let length = style.length
        switch style.attribute {
        case .underline:
            self.init(start: start, length: length, attribute: .underline)
        case .color:
            guard let hex = style.extra else {
                return nil
            }
            self.init(start: start, length: length, attribute: .color(hex: hex))
        case .link:
            guard let link = style.extra else {
                return nil
            }
            self.init(start: start, length: length, attribute: .link(link))
        default:
            return nil
        }
    }
}

struct StringLoaderNotifications {
    static let languageDidChange = Notification.Name(rawValue: "LanguageDidChange")
}

public class LocaleManager {

    private var currentLanguage: Language {
        didSet {
            getLiterals(localizableName: currentLanguage.appLanguageCode)
            NotificationCenter.default.post(name: StringLoaderNotifications.languageDidChange, object: nil)
        }
    }
    private var literals: [String: String] = [:]
    private var wsErrors: [String: String] = [WSErrors.operativeErrorMp0598: "operative_error_MP_0598",
                                              WSErrors.operativeErrorMd1112: "operative_error_MD_1112",
                                              WSErrors.operativeErrorMd0327: "operative_error_MD_0327",
                                              WSErrors.operativeErrorMp8157: "operative_error_MP_8157",
                                              WSErrors.operativeErrorMd1113: "operative_error_MD_1113",
                                              WSErrors.operativeErrorMd8080: "operative_error_MD_8080",
                                              WSErrors.operativeErrorM41265: "operative_error_M4_1265",
                                              WSErrors.operativeErrorSv0106: "operative_error_SV_0106",
                                              WSErrors.operativeErrorSv0003: "operative_error_SV_0003",
                                              WSErrors.operativeErrorMd7009: "operative_error_MD_7009",
                                              WSErrors.operativeErrorCrypto1: "operative_error_CRYPTO_1",
                                              WSErrors.operativeErrorM41371: "operative_error_M4_1371",
                                              WSErrors.operativeErrorM44752: "operative_error_M4_4752",
                                              WSErrors.operativeErrorM44687: "operative_error_M4_4687",
                                              WSErrors.operativeErrorM42843: "operative_error_M4_2843",
                                              WSErrors.operativeErrorM44788: "operative_error_M4_4788",
                                              WSErrors.operativeErrorM41504: "operative_error_M4_1504",
                                              WSErrors.operativeErrorM40610: "operative_error_M4_0610",
                                              WSErrors.operativeErrorM40018: "operative_error_M4_0018",
                                              WSErrors.operativeErrorA50475: "operative_error_A5_0475",
                                              WSErrors.operativeErrorM40566: "operative_error_M4_0566",
                                              WSErrors.operativeErrorM44594: "operative_error_M4_4594",
                                              WSErrors.operativeErrorM44754: "operative_error_M44754",
                                              WSErrors.operativeErrorM40000: "operative_error_M4_0000",
                                              WSErrors.operativeErrorSv0173: "operative_error_SV_0173",
                                              WSErrors.operativeErrorM44622: "operative_error_M4_4622",
                                              WSErrors.operativeErrorFacseg40201009: "generic_error_FACSEG_40201009",
                                              WSErrors.operativeErrorFacseg50201001: "operative_error_FACSEG_50201001",
                                              WSErrors.operativeErrorFacseg50300012: "operative_error_FACSEG_50300012",
                                              WSErrors.operativeErrorFacseg50201014: "operative_error_FACSEG_50201014",
                                              WSErrors.operativeErrorFacseg50201003: "operative_error_FACSEG_50201003",
                                              WSErrors.operativeErrorFacseg50300015: "operative_error_FACSEG_50300015",
                                              WSErrors.operativeErrorFacseg50300016: "operative_error_FACSEG_50300016",
                                              WSErrors.operativeErrorFacseg30300023: "operative_error_FACSEG_30300023",
                                              WSErrors.operativeErrorSigbro00003: "operative_error_SIGBRO_00003",
                                              WSErrors.operativeErrorSigbro00004: "operative_error_SIGBRO_00004",
                                              WSErrors.operativeErrorSv0108: "operative_error_SV_0108",
                                              WSErrors.operativeErrorFacseg50200072: "operative_error_FO_0693",
                                              WSErrors.operativeErrorFo0693: "operative_error_FO_0693",
                                              WSErrors.operativeErrorXx1111: "operative_error_FO_0693",
                                              WSErrors.operativeErrorFi4021: "operative_error_FO_0693",
                                              WSErrors.operativeErrorM4_4754: "operative_error_M4_4754",
                                              WSErrors.operativeErrorM40315: "operative_error_M4_0315",
                                              WSErrors.operativeErrorMP8170: "operative_error_MP_8170",
                                              WSErrors.operativeErrorMP1385: "operative_error_MP_1385",
                                              WSErrors.operativeErrorMP1387: "operative_error_MP_1387"]

    private lazy var pattern: NSRegularExpression = {
        do {
            return try NSRegularExpression(pattern: "\\{\\{([^\\{\\}:]+):?([^\\{\\}]+)?\\}\\}")
        } catch let error {
            RetailLogger.e(String(describing: type(of: self)), "Invalid regular expression: \(error.localizedDescription). Dying.")
            fatalError()
        }
    }()

    struct StringStyling {
        enum StyleAttribute: String {
            case bold
            case italic
            case size
            case color
            case underline
            case link
        }

        var startPosition: Int
        var endPosition = -1
        var length: Int {
            return endPosition - startPosition
        }
        var extra: String?
        var attribute: StyleAttribute
        var numberFormatter: NumberFormatter {
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = "."
            return numberFormatter
        }

        init(startPosition: Int, extra: String?, attribute: StyleAttribute) {
            self.startPosition = startPosition
            self.extra = extra
            self.attribute = attribute
        }
    }

    private let useCaseProvider: WidgetUseCaseProvider
    private let useCaseHandler: UseCaseHandler
    
    var locale: Locale {
        return currentLanguage.languageType.locale
    }
    
    init(localAppConfig: LocalAppConfig, useCaseProvider: WidgetUseCaseProvider, useCaseHandler: UseCaseHandler) {
        currentLanguage = Language.createDefault(isPb: nil, defaultLanguage: localAppConfig.language)
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        getLiterals(localizableName: currentLanguage.appLanguageCode)
        UseCaseWrapper(with: useCaseProvider.getLanguagesSelectionUseCase(), useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { [weak self] response in
            guard let strongSelf = self else {
                return
            }

            strongSelf.updateCurrentLanguage(language: response.current)
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.getKeyboardResponderButtons(notifiction:)), name: KeyboardNotifications.globalKeyboardCreateNotification, object: nil)
        })
    }

    public func updateCurrentLanguage(language: Language) {
        currentLanguage = language
    }

    @objc func getKeyboardResponderButtons(notifiction: Notification) {
        if var keyboard = notifiction.object as? KeyboardTextFieldResponderButtons {
            keyboard.doneButtonTitle = getString("generic_button_acceptKeyboard").plainText
            keyboard.nextButtonTitle = getString("generic_button_nextKeyboard").plainText
        }
    }
}

extension LocaleManager: StringLoader {
    public func getCurrentLanguage() -> Language {
        return currentLanguage
    }

    public func getString(_ key: String) -> LocalizedStylableText {
        return processStyles(in: getPlainString(key))
    }

    public func getString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return processStyles(in: getPlainString(key, stringPlaceholders))
    }

    public func getQuantityString(_ key: String, _ count: Int, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return processStyles(in: getPlainQuantityString(key, Double(count), stringPlaceholders))
    }

    public func getQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return processStyles(in: getPlainQuantityString(key, count, stringPlaceholders))
    }
    
    public func getWsErrorIfPresent(_ key: String) -> LocalizedStylableText? {
        guard let errorKey = wsErrors[key] else { return nil }
        return getString(errorKey)
    }

    public func getWsErrorString(_ key: String) -> LocalizedStylableText {
        let errorKey: String
        if let errorString = wsErrors[key] {
            errorKey = errorString
        } else {
            errorKey = key
        }
        return getString(errorKey)
    }

    public func getWsErrorWithNumber(_ key: String, _ phone: String) -> LocalizedStylableText {
        let errorKey: String
        if let errorString = wsErrors[key] {
            errorKey = errorString
        } else {
            errorKey = key
        }

        return getString(errorKey, [StringPlaceholder(StringPlaceholder.Placeholder.phone, phone)])
    }
}

extension LocaleManager: TimeManager {    
    public func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
        if let input = input {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = inputFormat.rawValue
            if timeZone == .utc {
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
            }
            dateFormatter.locale = currentLanguage.languageType.locale
            return dateFormatter.date(from: input)
        }
        return nil
    }
    
    public func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        if let input = input {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = inputFormat.rawValue
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.locale = currentLanguage.languageType.locale
            return dateFormatter.date(from: input)
        }
        return nil
    }

    public func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        if let input = input, let date = fromString(input: input, inputFormat: inputFormat) {
            return toString(date: date, outputFormat: outputFormat)
        }
        return nil
    }

    public func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return toString(date: date, outputFormat: outputFormat, timeZone: .utc)
    }
    
    public func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        if let date = date, isValidDate(date) {
            switch outputFormat {
            case .MMM:
                return getShortenedMonth(date: date)
            case .MMMM:
                return getMonth(date: date)
            case .asteriskedDate:
                return getAsteriskedDate(date: date)
            default:
                let formatter = DateFormatter()
                formatter.dateFormat = outputFormat.rawValue
                if timeZone == .utc {
                    formatter.timeZone = TimeZone(identifier: "UTC")
                }
                formatter.locale = currentLanguage.languageType.locale
                return formatter.string(from: date).lowercased()
            }
        }
        return nil
    }

    public func getShortenedMonth(date: Date) -> String? {
        return getMonth(date: date).substring(0, 3)
    }

    public func getMonth(date: Date) -> String {
        switch date.getMonth() {
        case 1:
            return getPlainString("generic_label_january")
        case 2:
            return getPlainString("generic_label_february")
        case 3:
            return getPlainString("generic_label_march")
        case 4:
            return getPlainString("generic_label_april")
        case 5:
            return getPlainString("generic_label_may")
        case 6:
            return getPlainString("generic_label_june")
        case 7:
            return getPlainString("generic_label_july")
        case 8:
            return getPlainString("generic_label_august")
        case 9:
            return getPlainString("generic_label_september")
        case 10:
            return getPlainString("generic_label_october")
        case 11:
            return getPlainString("generic_label_november")
        case 12:
            return getPlainString("generic_label_december")
        default:
            return ""
        }
    }

    public func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        if let date = date, isValidDate(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = outputFormat.rawValue
            formatter.timeZone = TimeZone.current
            formatter.locale = currentLanguage.languageType.locale
            return formatter.string(from: date).lowercased()
        }
        return nil
    }
    
    public func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        let todayString = toString(date: inputDate, outputFormat: .yyyy_MM_ddHHmmss, timeZone: .local)
        return fromString(input: todayString, inputFormat: TimeFormat.yyyy_MM_ddHHmmss, timeZone: .utc)
    }

    public func isValidDate(_ date: Date) -> Bool {
        return isValidYear(date.getYear())
    }

    public func isValidYear(_ year: Int) -> Bool {
        return !(year == 9999 || year == 1)
    }
}

// MARK: - Private Methods
private extension LocaleManager {

    private func getLiterals(localizableName: String) {
        guard let localizablePath = Bundle.main.path(forResource: localizableName, ofType: "strings"),
              let database = NSDictionary(contentsOfFile: localizablePath),
              let literals = database as? [String: String] else {
            fatalError("Could not load localizable file: \(localizableName).strings")
        }
        self.literals = literals
    }

    private func getPlainString(_ key: String) -> String {
        return literals[key] ?? key
    }

    private func getPlainString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> String {
        if let string = literals[key] {
            return replacePlaceholder(string, stringPlaceholders)
        }
        return key
    }

    private func getPlainQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> String {
        var finalKey = key

        if count == 1 {
            finalKey = key + "_one"
        } else {
            finalKey = key + "_other"
        }

        return getPlainString(finalKey, stringPlaceholders)
    }

    private func replacePlaceholder(_ originalString: String, _ stringPlaceholder: [StringPlaceholder]) -> String {
        var replacedString = originalString
        for placeholder in stringPlaceholder {
            replacedString = replacedString.replaceFirst(placeholder.placeholder.rawValue, placeholder.replacement)
        }
        return replacedString
    }

    private func processStyles(in text: String) -> LocalizedStylableText {
        var text = text
        let styles = normalizeStyles(styles: findStyles(text: text))
        text = cleanStyles(in: text)
        return LocalizedStylableText(plainText: text, styles: styles)
    }

    private func normalizeStyles(styles: [StringStyling]) -> [NormalizedStyling]? {
        let fontRelatedTypes: [StringStyling.StyleAttribute] = [.bold, .italic, .size]
        let fontRelatedStyles = styles.filter {
            return fontRelatedTypes.contains($0.attribute)
        }
        let rest = styles.filter {
            return !fontRelatedTypes.contains($0.attribute)
        }.compactMap {
            NormalizedStyling(style: $0)
        }
        let result = join(fonts: fontRelatedStyles) + rest
        return result.isEmpty ? nil : result
    }

    private func join(fonts: [StringStyling]) -> [NormalizedStyling] {

        func createNormalizedFonts(from fontsByRange: [NSRange: [StringStyling]]) -> [NormalizedStyling] {
            var normalizedFonts = [NormalizedStyling]()
            for range in fontsByRange.keys {
                guard let fontsOfRange = fontsByRange[range] else {
                    continue
                }

                var fontEmphasis = ""
                var fontFactor: Float = 1.0
                if !fontsOfRange.filter({ $0.attribute == .bold }).isEmpty {
                    fontEmphasis = "Bold"
                }
                if !fontsOfRange.filter({ $0.attribute == .italic }).isEmpty {
                    fontEmphasis += "Italic"
                }
                if let size = fontsOfRange.first(where: { $0.attribute == .size }) {
                    if let factor = size.extra, let conversion = size.numberFormatter.number(from: factor) {
                        fontFactor = conversion.floatValue
                    }
                }
                let emphasisType = FontEmphasis(rawValue: fontEmphasis) ?? .regular
                let styleType = StyleType.font(emphasis: emphasisType, factor: fontFactor)
                normalizedFonts += [NormalizedStyling(start: range.location, length: range.length, attribute: styleType)]
            }
            return normalizedFonts
        }

        var fonts = fonts.sorted {
            $0.startPosition < $1.startPosition
        }
        var fontsByRange = [NSRange: [StringStyling]]()
        for i in 0..<fonts.count {
            let font = fonts[i]
            var fontRange = NSRange(location: font.startPosition, length: font.length)
            var j = i + 1
            let validRange = fontRange.length > 0
            let otherFontsToCompare = j < fonts.count
            if otherFontsToCompare && validRange {
                while j < fonts.count {
                    var otherFont = fonts[j]
                    let otherRange = NSRange(location: otherFont.startPosition, length: otherFont.length)
                    if let intersection = fontRange.intersection(otherRange) {
                        //limit ranges to not invade intersection domain
                        fontRange.length = intersection.location - fontRange.location
                        otherFont.startPosition = intersection.location + intersection.length

                        //update other font in array to have new range for further checkings
                        fonts[j] = otherFont

                        //save new style in its intersection list
                        var intersectedFonts = fontsByRange[intersection] ?? [font]
                        intersectedFonts += [otherFont]
                        fontsByRange[intersection] = intersectedFonts
                    }
                    j += 1
                }
            }
            if fontRange.length > 0 {
                var fontsOfRange = fontsByRange[fontRange] ?? []
                fontsOfRange += [font]
                fontsByRange[fontRange] = fontsOfRange
            }
        }
        return createNormalizedFonts(from: fontsByRange)
    }

    private func findStyles(text: String) -> [StringStyling] {
        var text = text
        var stylingTable = [String: StringStyling]()
        var styles = [StringStyling]()

        while let match = pattern.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            guard var tag = text.substring(with: match.range(at: 1)) else {
                return []
            }
            let extra = text.substring(with: match.range(at: 2))
            if tag.starts(with: "/") == true {
                //closing tag
                tag = tag.replace("/", "")

                if stylingTable.keys.contains(tag), var stringStyling = stylingTable[tag] {
                    stringStyling.endPosition = match.range.location
                    styles.append(stringStyling)
                    stylingTable.removeValue(forKey: tag)
                }
            } else if let attribute = StringStyling.StyleAttribute(rawValue: tag.lowercased()) {
                stylingTable[tag] = StringStyling(startPosition: match.range.location, extra: extra, attribute: attribute)
            }
            guard let range = Range(match.range, in: text) else {
                return []
            }
            text = text.replacingCharacters(in: range, with: "")
        }

        for tag in stylingTable.keys {
            guard var stringStyling = stylingTable[tag] else {
                continue
            }
            stringStyling.endPosition = text.count
            styles.append(stringStyling)
        }

        return styles

    }

    private func cleanStyles(in text: String) -> String {
        return pattern.stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: "")
    }
    
    func getAsteriskedDate(date: Date) -> String {
        let day = date.toString(format: "dd")
        let month = date.toString(format: "MM")
        let year = date.toString(format: "yyyy")
        return asteriskLastChar(of: day) + "/" + asteriskLastChar(of: month) + "/" + asteriskLastChar(of: year)
    }
    
    func asteriskLastChar(of string: String) -> String {
        var chars = Array(string)
        chars[chars.count-1] = "*"
        return String(chars)
    }
}
