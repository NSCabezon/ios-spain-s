import CoreFoundationLib
import Foundation
import SANLegacyLibrary

protocol MifidClauseProtocol {
    var primaryCode: String? { get }
    var secondaryCode: String? { get }
    var text: String? { get }
}

protocol Mifid1ResponseProtocol {
    var clauses: [MifidClauseProtocol]? { get }
}

private struct MifidCasesContants {
    static let complexCases = ["MF0017", "MF0018"]
    static let mfmCases = "MFM"
}

class Mifid1UseCase<Input: Mifid1UseCaseInputProtocol, ResponseData: Mifid1ResponseProtocol>: UseCase<Input, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
    private enum MifidType {
        case simple, complex, mfm
    }
    
    let appConfigRepository: AppConfigRepository
    let provider: BSANManagersProvider
    
    private lazy var isMifid1Enabled: Bool = {
        return checkMifidAppConfigEnabled(key: DomainConstant.enableMifid1) ?? true
    }()
    private var quotedComplexTextPattern: NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: "\".*?\"")
        } catch let error {
            RetailLogger.e(String(describing: type(of: self)), "Invalid regular expression: \(error.localizedDescription). Dying.")
            fatalError()
        }

    }
    
    init(appConfigRepository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Input) throws -> UseCaseResponse<Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        let isPBResponse = try provider.getBsanSessionManager().isPB()
        guard isPBResponse.isSuccess(), let isPB = try isPBResponse.getResponseData() else {
            return UseCaseResponse.error(Mifid1UseCaseErrorOutput(try isPBResponse.getErrorCode()))
        }
        
        var mifid1Status: Mifid1Status = .none
        if isMifid1Enabled {
            let mifidResponse = try getMifidResponse(requestValues: requestValues)
            guard mifidResponse.isSuccess(), let data = try mifidResponse.getResponseData() else {
                let errorDescription =  try mifidResponse.getErrorMessage() ?? ""
                return UseCaseResponse.error(Mifid1UseCaseErrorOutput(errorDescription))
            }
            mifid1Status = processResponseData(isPB: isPB, data: data)
        }
        
        let mifid1Data = Mifid1Data(userIsPb: isPB,
                                    mifid1Status: mifid1Status)
        
        return UseCaseResponse.ok(Mifid1UseCaseOkOutput(mifid1Data: mifid1Data))
    }
    
    private func processResponseData(isPB: Bool, data: Mifid1ResponseProtocol) -> Mifid1Status {
        func removeUnncessaryLineBreaks(in string: String?) -> String? {
            if var altered = string, !altered.isEmpty {
                altered.removeSubrange(altered.index(altered.endIndex, offsetBy: -2)..<altered.endIndex)
                return altered
            }
            return string
        }
        
        var simpleVariableText = data.clauses?.reduce("", {
            return $0 + (text(forClause: $1, mifidType: .simple) ?? "")
        })
        simpleVariableText = removeUnncessaryLineBreaks(in: simpleVariableText)
        
        var complexText = data.clauses?.reduce("", {
            return $0 + (text(forClause: $1, mifidType: .complex) ?? "")
        })
        complexText = removeUnncessaryLineBreaks(in: complexText)
        
        let mfmTexts: [String] = data.clauses?.compactMap({ (clause) -> String? in
            return text(forClause: clause, mifidType: .mfm)
        }) ?? []
        
        return evaluateTexts(isPB: isPB, simple: simpleVariableText, complex: complexText, mfm: mfmTexts)
    }
    
    private func evaluateTexts(isPB: Bool, simple: String?, complex: String?, mfm: [String]) -> Mifid1Status {
        // If there is no simple clausule, we ask whether has MFM.
        guard clausuleHasSimpleType(simple, isPB: isPB) else {
            let mfmClausules = extractMfm(mfm)
            if mfmClausules.isEmpty {
                return .none
            }
            return .mfm(mfmClausules)
        }
        
        let simpleText = simple
        let complexInfo = extractComplex(complex)
        let mfmInfo = extractMfm(mfm)
        
        return getMifidStatus(simpleText, complexInfo, mfmInfo)
    }
    
    private func text(forClause clause: MifidClauseProtocol, mifidType: MifidType) -> String? {
        func isValid(code: String?, secondaryCode: String?, mifidType: MifidType) -> Bool {
            var isComplexCase: Bool {
                if let code = code, MifidCasesContants.complexCases.contains(code) {
                    return true
                } else if let secondaryCode = secondaryCode, MifidCasesContants.complexCases.contains(secondaryCode) {
                    return true
                }
                return false
            }
            switch mifidType {
            case .complex:
                return isComplexCase
            case .mfm:
                return code?.starts(with: MifidCasesContants.mfmCases) == true || secondaryCode?.starts(with: MifidCasesContants.mfmCases) == true
            case .simple:
                guard let code = code else { return false }
                let isMfmCase = code.starts(with: MifidCasesContants.mfmCases) || secondaryCode?.starts(with: MifidCasesContants.mfmCases) == true
                return !isComplexCase && !isMfmCase && !(code.count >= 3 && code.uppercased()[2] == "M")
            }
        }
        
        guard let text = clause.text, isValid(code: clause.primaryCode, secondaryCode: clause.secondaryCode, mifidType: mifidType) else {
            return nil
        }
        
        return "\(text)\n\n"
    }
    
    private enum ExtractionResult {
        case success(normalizedComplexText: String, quotedComplexText: String)
        case error
    }
    
    private func extractQuotedComplexText(from complexText: String) -> ExtractionResult {
        guard let match = quotedComplexTextPattern.firstMatch(in: complexText, options: [], range: NSRange(complexText.startIndex..., in: complexText)) else {
            return .error
        }
        guard let quoted = complexText.substring(with: match.range(at: 0)) else {
            return .error
        }
        return .success(normalizedComplexText: complexText.replace(quoted, ""), quotedComplexText: quoted.replacingOccurrences(of: "\"", with: ""))
    }
    
    func clausuleHasSimpleType(_ simple: String?, isPB: Bool) -> Bool {
        return !(simple?.isEmpty ?? true) || !isPB
    }
    
    private func extractComplex(_ complex: String?) -> (questionText: String, textToValidate: String)? {
        guard let complexText = complex, !complexText.isEmpty else { return nil }
        
        if case let .success(normalized, quoted) = extractQuotedComplexText(from: complexText) {
            return (questionText: normalized, textToValidate: quoted)
        }
        
        return nil
    }
    
    private func extractMfm(_ clausules: [String]) -> [(String, String)] {
        guard !clausules.isEmpty else { return [] }
        
        var results: [(String, String)] = []
        
        for mfm in clausules {
            if case let .success(normalized, quoted) = extractQuotedComplexText(from: mfm) {
                results.append((normalized, quoted))
            }
        }
        
        return results
    }
    
    private func getMifidStatus(_ simpleText: String?, _ complexInfo: (String, String)?, _ mfmInfo: [(String, String)]) -> Mifid1Status {
        switch complexInfo {
        case .none:
            if mfmInfo.isEmpty {
                return .simple(simpleVariableText: simpleText)
            } else {
                return .simpleMfm(simpleVariableText: simpleText, mfmClausules: mfmInfo)
            }
            
        case .some(let questionText, let textToValidate):
            if mfmInfo.isEmpty {
                return .complex(simpleVariableText: simpleText, questionText: questionText, textToValidate: textToValidate)
            } else {
                return .complexMfm(simpleVariableText: simpleText, questionText: questionText, textToValidate: textToValidate, mfmClausules: mfmInfo)
            }
        }
    }
    
    func getMifidResponse(requestValues: Input) throws -> BSANResponse<ResponseData> {
        fatalError()
    }
}

extension Mifid1UseCase: MifidAppConfigChecker {}

protocol Mifid1UseCaseInputProtocol {
    associatedtype Data
    var data: Data { get }
}

struct Mifid1UseCaseOkOutput {
    let mifid1Data: Mifid1Data?
}

class Mifid1UseCaseErrorOutput: StringErrorOutput { }
