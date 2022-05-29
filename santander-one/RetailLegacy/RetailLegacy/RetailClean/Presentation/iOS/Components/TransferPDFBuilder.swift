import Foundation
import UI

class TransferPDFBuilder {
    
    // MARK: - Private attributes
    
    private var html: String = ""
    private let stringLoader: StringLoader
    private let timeManager: TimeManager
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader, timeManager: TimeManager) {
        self.stringLoader = stringLoader
        self.timeManager = timeManager
    }
    
    func addHeader(title: String, office: String?, date: Date?) {
        html += """
        <style>
        @font-face {
            font-family: 'Lato-Regular';
            src: url('Lato-Regular.ttf') format('truetype');
            font-weight: normal;
            font-style: normal;
        }
        
        @font-face {
            font-family: 'Lato-Bold';
            src: url('Lato-Bold.ttf') format('truetype');
            font-weight: normal;
            font-style: normal;
        }
        body {
            background-color: #FFFFFF;
            color: #4A4A4A;
            font-family: 'Lato-Regular';
            font-size: 62.5%;
            line-height: 1.5;
        }
        
        .content_Data {
            float: left;
            width: 682px;
        }
        
        #content_Pdf {
            background: #FFFFFF;
            font-size: 14px;
            margin-left: auto;
            margin-right: auto;
            overflow:hidden;
            width: 842px;
        }
        
        .content_Data h1{
            color: #FF0000;
            font-size: 18px;
            margin-bottom: 0px;
            margin-top: 0px;
            padding-top: 35px;
        }
        .content_Data p{
            margin: 7px 0;
        }
        .content_Data .txt_right {
            float: right;
            padding-right: 0;
            text-align: right;
        }
        .content_Aviso {
            float: left;
            font-size: 12px;
            height: 550px;
            position: relative;
            width: 80px;
        }
        .content_Aviso .txt_rotar {
            -moz-transform-origin: 50% 50%;
            -moz-transform: rotate(-90deg);
            -ms-transform-origin: 50% 50%;
            -ms-transform: rotate(-90deg);
            -o-transform-origin: 50% 50%;
            -o-transform: rotate(-90deg);
            -webkit-transform-origin: 50% 50%;
            -webkit-transform: rotate(-90deg);
            font-size: 10px;
            left: -170px;
            overflow: hidden;
            position: absolute;
            text-align: center;
            top: 270px;
            transform-origin: 50% 50%;
            transform: rotate(-90deg);
            width: 420px;
        }
        .strong {
            font-family: 'Lato-Bold';
        }
        .content_Data img {
            width: 135px;
            padding-top: 15px;
        }
        .content_Data_1 section {
            background-color: #FFFFFF;
            padding-left: 0;
            padding-top: 0;
        }
        .content_Data_1 p {
            margin-bottom: 0;
            margin-top: 0;
        }
        .content_Data_5 p {
            font-size: 12px;
            padding-top: 10px;
        }
        </style>
        <head>
        </head>
        <body>
        <div id="content_Pdf">
        <div class="content_Aviso">
        <p class="txt_rotar">
        \(stringLoader.getString("pdf_text_datesBank").text)
        </p>
        </div>
        <header class="content_Data">
        <img src="data:image/png;base64, \(Assets.getBase64Image("logo_santander"))" alt="Santander">
        </header>
        <div class="content_Data content_Data_1">
        <section>
        <h1>\(stringLoader.getString(title).text)</h1>
        </section>
        <section class="txt_right">
        """
        if let office = office {
            html += """
            <p><span>\(stringLoader.getString("pdf_label_office").text)</span><br>
            <span>\(office)</span><br>
            """
        }
        if let dateText = timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) {
            html += "<span>\(stringLoader.getString("pdf_label_deliveryDate").text)</span> <span>\(dateText)</span></p>"
        }
        html += "</section></div>"
        html += "<table width=\"82%\">"
    }
    
    func addAccounts(originAccountAlias: String, originAccountIBAN: String, destinationAccountAlias: String, destinationAccountIBAN: String) {
        html += """
        <tr style="width:100%;display: inline-table;">
        <td style="width:49.5%; background-color: #F5F7FA;">
        <div style="margin: 10px">
        <span style="display:block;">\(stringLoader.getString("pdf_label_of").text)</span>
        <span class=\"strong\">\(originAccountAlias)</span>
        <span style="display:block;">\(originAccountIBAN)</span>
        </div>
        </td>
        <td style="width:1%; background-color:#ffffff"></td>
        <td style="width:49.5%; background-color: #F5F7FA;">
        <div style="margin: 10px">
        <span style="display:block;">\(stringLoader.getString("pdf_label_to").text)</span>
        <span class=\"strong\">\(destinationAccountAlias)</span>
        <span style="display:block;">\(destinationAccountIBAN)</span>
        </div>
        </td>
        </tr>
        """
    }
    
    func addAccounts(originAccount: Account, destinationAccount: Account) {
        addAccounts(originAccountAlias: originAccount.getAlias() ?? "", originAccountIBAN: originAccount.getAsteriskIban(), destinationAccountAlias: destinationAccount.getAlias() ?? "", destinationAccountIBAN: destinationAccount.getAsteriskIban())
    }
    
    func addExpenses(_ expenses: [(key: String, value: PDFStringConvertible?)]) {
        add(info: expenses.compactMap(pdfInfo), numberOfItemsInRow: 3, isFirst: true)
    }
    
    func addTransferInfo(_ info: [(key: String, value: PDFStringConvertible?)]) {
        add(info: info.compactMap(pdfInfo), numberOfItemsInRow: 2, isFirst: true)
    }
    
    func build() -> String {
        html += """
        </table>
        <footer class="content_Data content_Data_5">
        <p>\(stringLoader.getString("pdf_text_seePdf").text)</p>
        </footer>
        </div>
        </section>
        </body>
        </html>
        """
        return html
    }
    
    // MARK: - Private
    
    /// Recursive method to create an element for the table with the number of elements in the array
    ///
    /// - Parameters:
    ///   - info: the array of elements to be added
    ///   - itemsInRow: the max number of items in each row
    ///   - isFirst: if it is the first element
    private func add(info: [PDFInfo], numberOfItemsInRow itemsInRow: Int, isFirst: Bool = false) {
        guard info.count > 0 else { return }
        let items = info.prefix(itemsInRow)
        let percentage = (1 / Float(itemsInRow)) * 100
        html += "<tr style=\"width:100%; background-color: #F5F7FA; display: inline-table; \(isFirst ? "margin-top:10px;" : "")\">"
        for index in 0..<itemsInRow {
            if items.indices.contains(index) {
                html += htmlCell(for: items[index], withPercentage: percentage)
            } else {
                html += emptyCell(withPercentage: percentage)
            }
        }
        html += "</tr>"
        let filteredItems = info.filter({ !items.contains($0) })
        add(info: filteredItems, numberOfItemsInRow: itemsInRow)
    }
    
    private func htmlCell(for info: PDFInfo, withPercentage percentage: Float) -> String {
        return """
        <td style="width:\(percentage)%; display: inline-table;">
        <div style="margin: 10px">
        <span style="display:block;">\(stringLoader.getString(info.key).text)</span>
        <span class=\"strong\">\(info.value.pdfString)</span>
        </div>
        </td>
        """
    }
    
    private func emptyCell(withPercentage percentage: Float) -> String {
        return """
        <td style="width:\(percentage)%; display: inline-table;">
        <div style="margin: 10px"/>
        </td>
        """
    }
    
    private func pdfInfo(from info: (String, PDFStringConvertible?)) -> PDFInfo? {
        guard let value = info.1 else { return nil }
        return PDFInfo(key: info.0, value: value)
    }
}
