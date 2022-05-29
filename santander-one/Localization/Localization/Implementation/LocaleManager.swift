import CoreFoundationLib
import OpenCombine

fileprivate enum LocalManagerError: Error {
    case literal(description: String)
}

public enum StringLoaderNotifications {
    public static let languageDidChange = Notification.Name(rawValue: "LanguageDidChange")
}

public class LocaleManager {
    
    private var currentLanguage: Language {
        didSet {
            self.literals = getLiterals(localizableName: currentLanguage.appLanguageCode)
            NotificationCenter.default.post(name: StringLoaderNotifications.languageDidChange, object: nil)
        }
    }
    private var defaultLanguage: Language {
        didSet {
            self.defaultLiterals = getLiterals(localizableName: defaultLanguage.appLanguageCode)
        }
    }
    private var literals: [String: String] = [:]
    private var defaultLiterals: [String: String] = [:]
    private var wsErrors: [String: String] = [
        WSErrors.operativeErrorMp0598: "operative_error_MP_0598",
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
        WSErrors.operativeErrorSigbro00006: "operative_error_SIGBRO_00006",
        WSErrors.operativeErrorSv0108: "operative_error_SV_0108",
        WSErrors.operativeErrorFacseg50200072: "operative_error_FO_0693",
        WSErrors.operativeErrorFo0693: "operative_error_FO_0693",
        WSErrors.operativeErrorXx1111: "operative_error_FO_0693",
        WSErrors.operativeErrorFi4021: "operative_error_FO_0693",
        WSErrors.operativeErrorM404754: "operative_error_M4_4754",
        WSErrors.operativeErrorM40315: "operative_error_M4_0315",
        WSErrors.operativeErrorMP8170: "operative_error_MP_8170",
        WSErrors.operativeErrorMP1385: "operative_error_MP_1385",
        WSErrors.operativeErrorMP1387: "operative_error_MP_1387"
    ]
    
    var locale: Locale {
        return currentLanguage.languageType.locale
    }
    
    public init(dependencies: DependenciesResolver) {
        let defaultLanguage = dependencies.resolve(for: LocalAppConfig.self).language
        let languageList = dependencies.resolve(for: LocalAppConfig.self).languageList
        self.currentLanguage = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList)
        self.defaultLanguage = Language.createFromType(languageType: defaultLanguage, isPb: nil)
        self.literals = getLiterals(localizableName: self.currentLanguage.appLanguageCode)
        self.defaultLiterals = getLiterals(localizableName: self.defaultLanguage.appLanguageCode)
        Scenario(useCase: dependencies.resolve(for: GetLanguagesSelectionUseCaseProtocol.self))
            .execute(on: dependencies.resolve(for: UseCaseHandler.self))
            .onSuccess(self.onLoadedSelectedLanguage)
    }
    
    private func onLoadedSelectedLanguage(_ response: GetLanguagesSelectionUseCaseOkOutput) {
        updateCurrentLanguage(language: response.current)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getKeyboardResponderButtons(notifiction:)),
            name: KeyboardNotifications.globalKeyboardCreateNotification,
            object: nil
        )
    }
    
    public func updateCurrentLanguage(language: Language) {
        currentLanguage = language
    }
    
    public func updateDefaultLanguage(language: Language) {
        defaultLanguage = language
    }
    
    @objc func getKeyboardResponderButtons(notifiction: Notification) {
        guard var keyboard = notifiction.object as? KeyboardTextFieldResponderButtons else { return }
        keyboard.doneButtonTitle = getString("generic_button_acceptKeyboard").text
        keyboard.nextButtonTitle = getString("generic_button_nextKeyboard").text
    }
}

extension LocaleManager: StringLoader {
    public func getCurrentLanguage() -> Language {
        return currentLanguage
    }
    
    public func getString(_ key: String) -> LocalizedStylableText {
        return StylesManager.processStyles(in: getPlainString(key))
    }
    
    public func getString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return StylesManager.processStyles(in: getPlainString(key, stringPlaceholders))
    }
    
    public func getQuantityString(_ key: String, _ count: Int, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return StylesManager.processStyles(in: getPlainQuantityString(key, Double(count), stringPlaceholders))
    }
    
    public func getQuantityString(_ key: String, _ count: Double, _ stringPlaceholders: [StringPlaceholder]) -> LocalizedStylableText {
        return StylesManager.processStyles(in: getPlainQuantityString(key, count, stringPlaceholders))
    }
    
    public func getWsErrorString(_ key: String) -> LocalizedStylableText {
        let errorKey = wsErrors[key] ?? key
        return getString(errorKey)
    }
    
    public func getWsErrorIfPresent(_ key: String) -> LocalizedStylableText? {
        guard let errorKey = wsErrors[key] else { return nil }
        return getString(errorKey)
    }
    
    public func getWsErrorWithNumber(_ key: String, _ phone: String) -> LocalizedStylableText {
        let errorKey = wsErrors[key] ?? key
        return getString(errorKey, [StringPlaceholder(StringPlaceholder.Placeholder.phone, phone)])
    }
}

extension LocaleManager: StringLoaderReactive {
    public func getCurrentLanguage() -> AnyPublisher<Language, Never> {
        return Just(currentLanguage).eraseToAnyPublisher()
    }
}

extension LocaleManager: TimeManager {
    public func fromString(input: String?, inputFormat: String, timeZone: TimeManagerTimeZone) -> Date? {
        guard let input = input else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        if timeZone == .utc {
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
        }
        dateFormatter.locale = currentLanguage.languageType.locale
        return dateFormatter.date(from: input)
    }
    
    public func fromString(input: String?, inputFormat: String) -> Date? {
        guard let input = input else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = currentLanguage.languageType.locale
        return dateFormatter.date(from: input)
    }
    
    public func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
        guard let input = input else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat.rawValue
        if timeZone == .utc {
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
        }
        dateFormatter.locale = currentLanguage.languageType.locale
        return dateFormatter.date(from: input)
    }
    
    public func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        guard let input = input else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat.rawValue
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = currentLanguage.languageType.locale
        return dateFormatter.date(from: input)
    }
    
    public func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        guard let input = input,
              let date = fromString(input: input, inputFormat: inputFormat)
        else { return nil }
        return toString(date: date, outputFormat: outputFormat)
    }
    
    public func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return toString(date: date, outputFormat: outputFormat, timeZone: .utc)
    }
    
    public func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        guard let date = date, isValidDate(date) else { return nil }
        switch outputFormat {
        case .MMM:
            return getShortenedMonth(date: date)
        case .MMMM:
            return getMonth(date: date)
        case .asteriskedDate:
            return getAsteriskedDate(date: date)
        case .eeee:
            return getWeekday(date: date)
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = outputFormat.rawValue
            if timeZone == .utc {
                formatter.timeZone = TimeZone(identifier: "UTC")
            }
            formatter.locale = currentLanguage.languageType.locale
            return formatter.string(from: date).replacingOccurrences(of: ".", with: "").lowercased()
        }
    }
    
    public func getShortenedMonth(date: Date) -> String? {
        return getMonth(date: date).substring(0, 3)
    }
    
    public func getMonth(date: Date) -> String {
        switch date.month {
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
    
    public func getWeekday(date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1:
            return getPlainString("generic_label_sunday")
        case 2:
            return getPlainString("generic_label_monday")
        case 3:
            return getPlainString("generic_label_tuesday")
        case 4:
            return getPlainString("generic_label_wednesday")
        case 5:
            return getPlainString("generic_label_thursday")
        case 6:
            return getPlainString("generic_label_friday")
        case 7:
            return getPlainString("generic_label_saturday")
        default:
            return ""
        }
        }
    
    public func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        guard let date = date, isValidDate(date) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat.rawValue
        formatter.timeZone = TimeZone.current
        formatter.locale = currentLanguage.languageType.locale
        return formatter.string(from: date).lowercased()
    }
    
    public func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        let todayString = toString(date: inputDate, outputFormat: .yyyy_MM_ddHHmmss, timeZone: .local)
        return fromString(input: todayString, inputFormat: TimeFormat.yyyy_MM_ddHHmmss, timeZone: .utc)
    }
    
    public func isValidDate(_ date: Date) -> Bool {
        return  isValidYear(date.year)
    }
    
    public func isValidYear(_ year: Int) -> Bool {
        return !(year == 9999 || year == 1)
    }
}

// MARK: - Private Methods
private extension LocaleManager {
    
    func getLiterals(localizableName: String) -> [String: String] {
        do {
            return try getLiterals(languageCode: localizableName)
        } catch {
            return getDefaultLanguageLiterals()
        }
    }
    
    func getDefaultLanguageLiterals() -> [String: String] {
        let defaultLanguageCode = self.defaultLanguage.appLanguageCode
        guard let literals = try? getLiterals(languageCode: defaultLanguageCode) else {
            fatalError("Could not load localizable file: \(defaultLanguageCode).strings")
        }
        return literals
    }
    
    private func getLiterals(languageCode: String) throws -> [String: String] {
        guard let localizablePath = Bundle.main.path(forResource: languageCode, ofType: "strings"),
              let database = NSDictionary(contentsOfFile: localizablePath),
              let literals = database as? [String: String]
        else {
            throw LocalManagerError.literal(description: "Could not load localizable file: \(languageCode).strings")
        }
        return literals
    }
    
    private func getPlainString(_ key: String) -> String {
        return literals[key] ?? defaultLiterals[key] ?? key
    }
    
    private func getPlainString(_ key: String, _ stringPlaceholders: [StringPlaceholder]) -> String {
        guard let string = literals[key] ?? defaultLiterals[key] else { return key }
        return StylesManager.replacePlaceholder(string, stringPlaceholders)
    }
    
    private func getPlainString(string: String, _ stringPlaceholders: [StringPlaceholder]) -> String {
        return StylesManager.replacePlaceholder(string, stringPlaceholders)
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
    
    private func getAsteriskedDate(date: Date) -> String {
        let day = date.toString(format: "dd")
        let month = date.toString(format: "MM")
        let year = date.toString(format: "yyyy")
        return asteriskLastChar(of: day) + "/" + asteriskLastChar(of: month) + "/" + asteriskLastChar(of: year)
    }
    
    private func asteriskLastChar(of string: String) -> String {
        var chars = Array(string)
        chars[chars.count-1] = "*"
        return String(chars)
    }
}
