import Foundation

protocol EmailStringConvertible {
    var emailString: String { get }
}

class TransferEmailBuilder {
    
    // MARK: - Private attributes
    
    private var html: String = ""
    private let stringLoader: StringLoader
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader) {
        self.stringLoader = stringLoader
    }
    
    func addHeader(title: String) {
        html += """
        <table width="100%" cellspacing="0" cellpadding="0" border="0" height="100%" style="min-width:348px">
        <tbody>
        <tr height="32px"></tr>
        <tr align="center">
        <td width="32px"></td>
        <td>
        <table cellspacing="0" cellpadding="0" border="0" style="overflow-x:auto;max-width:600px;">
        <tbody>
        <tr>
        <td>
        <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
        <tr>
        <td align="center">
        <img alt="Logo Santander" width="155" height="28" style="display:block;width:155px;min-height:28px" src="data:image/png;base64,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"/><br /><br />
        <img alt="Img Notificaci&oacute;n de transferencia a su favor" width="204" height="204" style="display:block;width:204px;min-height:204px" src="data:image/png;base64,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"/>
        </td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        <tr>
        <td>
        <table align="center" width="60%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF" style="min-width:332px;overflow-x:auto;max-width:600px; text-align: center">
        <tbody>
        <tr>
        <td height="30px" colspan="3"></td>
        </tr>
        <tr>
        <td style="font-family:'Santander Headline', 'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:28px;color:#444444;line-height: 30px"><span th:text="${static_text.get('t0')}">\(stringLoader.getString("mail_title_transfer").text)</span></td>
        </tr>
        <tr>
        <td height="18px" colspan="3"></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        <tr>
        <td>
        <table align="center" width="70%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF" style="min-width:332px;overflow-x:auto;max-width:600px; text-align: center">
        <tbody>
        <tr>
        <td height="18px" colspan="3"></td>
        </tr>
        <tr>
        <td style="font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:16px;color:#727272;line-height:26px"><span th:text="${static_text.get('t0')}">\(title)</span></td>
        </tr>
        <tr>
        <td height="20px" colspan="3"></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        
        <tr>
        <td>
        <table width="100%" bgcolor="#DEEDF2" cellspacing="0" cellpadding="0" border="0" style="text-align:center;">
        <tr>
        <td height="18px" colspan="3"></td>
        </tr>
        <tr>
        <td>
        <table style="font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif; display: inline-block; max-width: 270px; width: 100%;">
        <tr>
        <td>
        <span style="font-family:'Santander Headline', 'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:18px;color:#EC0000;line-height:1.5" th:text="${static_text.get('t0')}">\(stringLoader.getString("mail_title_dataTransfer").text)</span><br />
        </td>
        </tr>
        </table>
        <table style="font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif; display: inline-block; max-width: 270px; width: 100%;">
        <tr>
        <td></td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        """
    }
    
    func addTransferInfo(_ info: [EmailInfo?]) {
        html += """
        <tr>
        <td>
        <table valign="top" width="100%" bgcolor="#DEEDF2" cellspacing="0" cellpadding="0" border="0" style="text-align:center;">
        <tr>
        <td>
        """
        let infoArray = info.compactMap({ $0 })
        let halfIndex = Int(ceil(Float(infoArray.count) / 2))
        let firstColumInfo = infoArray.prefix(halfIndex)
        let secondColumInfo = infoArray.filter { !firstColumInfo.contains($0) }
        addColumn(with: Array(firstColumInfo))
        addColumn(with: secondColumInfo)
        html += """
        </td>
        </tr>
        </table>
        </td>
        </tr>
        """
    }
    
    func build() -> String {
        html += """
        <tr>
        <td>
        <table align="center" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#EC0000" style="min-width:332px;overflow-x:auto;max-width:600px; text-align: center">
        <tbody>
        <tr>
        <td height="18px" colspan="3"></td>
        </tr>
        <tr>
        <td style="font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;color:#FFFFFF;line-height:1.5">
        <span style="font-size:28px;" th:text="${static_text.get('t101')}">\(stringLoader.getString("mail_label_titleFooter").text)</span><br />
        <span style="font-size:18px;" th:text="${static_text.get('t12')}">\(stringLoader.getString("mail_label_descFooter").text)</span>
        </td>
        </tr>
        <tr>
        <td height="18px" colspan="3"></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        
        <tr height="16"></tr>
        <tr>
        <td style="overflow-x:auto;max-width:600px;font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:10px;color:#bcbcbc;line-height:1.5"></td>
        </tr>
        <tr>
        <td>
        <table align="center" width="80%" style="font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif;font-size:10px;color:#666666;line-height:18px;padding-bottom:10px">
        <tbody>
        <tr>
        <td><span th:text="${static_text.get('t13')}">\(stringLoader.getString("mail_text_disclaimer").text)</span></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        </tbody>
        </table>
        </td>
        <td width="32px"></td>
        </tr>
        <tr height="32px"></tr>
        </tbody>
        </table>
        """
        return html
    }
    
    // MARK: - Private
    
    private func addColumn(with info: [EmailInfo]) {
        html += """
        <table valign="top" style="font-family:'Santander Text', 'Lato', Tahoma, Verdana, Segoe, sans-serif; display: inline-block; max-width: 270px; width: 100%; text-align:left;">
        <tr>
        <td>
        \(info.map(htmlCell).joined(separator: "\n"))
        </td>
        </tr>
        </table>
        """
    }
    
    private func htmlCell(for info: EmailInfo) -> String {
        return """
        <span style="font-size: 12px; color: #727272" th:text="${static_text.get('t1')}">\(stringLoader.getString(info.key).text)</span><br />
        <span style="font-size: 16px; color:#444444" th:text="${pvalue1}">\(info.value.emailString)</span><br />
        <span style="font-size: \(info.detail != nil ? "14px" : "18px"); color:#444444;" th:text="${pvalue2}">\(info.detail?.emailString ?? "&nbsp;")</span><br />
         <span style="font-size: \(info.detail != nil ? "4px" : "0px"); color:#444444;" th:text="${pvalue2}">&nbsp;</span><br />
        """
    }
}

struct EmailInfo: Equatable, Hashable {
    
    let key: String
    let value: EmailStringConvertible
    let detail: EmailStringConvertible?
    
    init?(key: String, value: EmailStringConvertible?, detail: EmailStringConvertible?) {
        guard let value = value else { return nil }
        self.key = key
        self.value = value
        self.detail = detail
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: EmailInfo, rhs: EmailInfo) -> Bool {
        return lhs.key == rhs.key
    }
}

extension Amount: EmailStringConvertible {
    
    var emailString: String {
        return getAbsFormattedAmountUI()
    }
}

extension String: EmailStringConvertible {
    
    var emailString: String {
        return description
    }
}
