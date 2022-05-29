import Foundation
import UI

class BillPDFBuilder {
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
        <!DOCTYPE html>
        <html lang="es">
            <head>
                <meta charset="utf-8">
                <meta name="description" content="\(stringLoader.getString(title).text) - Santander">
                <meta name="keywords" content="HTML5">
                <title>\(stringLoader.getString(title).text) - Santander</title>
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
        
                    #content_Pdf {
                    /*height: 595px;*/
                    background: #FFFFFF;
                    font-size: 14px;
                    margin-left: auto;
                    margin-right: auto;
                    overflow:hidden;
                    width: 842px;
                    }
        
                    .content_Data {
                    float: left;
                    width: 682px;
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
        
                    .strong {
                    font-family: 'Lato-Bold';
                    }
        
                    .content_Data section {
                    float: left;
                    overflow:hidden;
                    width: 321px;
                    background-color: #F5F7FA;
                    margin-bottom: 5px;
                    padding: 10px;
                    }
        
                    .content_Data img {
                    width: 135px;
                    padding-top: 15px;
                    }
        
                    .content_Data .txt_right {
                    float: right;
                    padding-right: 0;
                    text-align: right;
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
        
                    .content_Data_2 section {
                    width: 318px;
                    }
        
                    .content_Data_2 section:nth-child(2) {
                    border-left: 5px solid #FFFFFF;
                    float: left;
                    }
        
                    .content_Data_4 {
                    background-color: #F5F7FA;
                    }
        
                    .content_Data_4 .flotar_izq {
                    margin-right: 45px;
                    }
        
                    .flotar_izq {
                    float: left;
                    }
        
                    .content_Data_5 p {
                    font-size: 12px;
                    padding-top: 10px;
                    }
        
                    .content_Aviso {
                    float: left;
                    font-size: 12px;
                    height: 450px;
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
                    top: 190px;
                    transform-origin: 50% 50%;
                    transform: rotate(-90deg);
                    width: 420px;
                    }
                </style>
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
    }
    
    func addAccountInfo(issuerName: String, issuerCode: String, account: Account) {
        html += """
        <div class="content_Data content_Data_2">
        <section>
        <p><span>\(stringLoader.getString("summary_item_EntityIssuing").text)</span><br>
        <span class=\"strong\">\(issuerName)</span><br>
        <span>\(stringLoader.getString("pdf_label_code", [StringPlaceholder(.value, "\(issuerCode)")]).text)</span></p>
        </section>
        <section>
        <p><span>\(stringLoader.getString("summary_item_originAccount").text)</span><br>
        <span class=\"strong\">\(account.getAlias()?.camelCasedString ?? "")</span><br>
        <span>\(account.getAsteriskIban())</span></p>
        </section>
        </div>
        """
    }
    
    func addTransferInfo(_ info: [(key: String, value: PDFStringConvertible)]) {
        var items = info
        while items.count > 0 {
            html += "<div class=\"content_Data content_Data_3\">"
            var sectionLeft: String = "<section>"
            var sectionRight: String = "<section>"
            if let item = items.first {
                sectionLeft += """
                <p>
                <span>\(stringLoader.getString(item.key).text)</span><br>
                <span class=\"strong\">\(item.value.pdfString)</span>
                </p>
                """
                items = Array(items.dropFirst())
                if let item = items.first {
                    sectionRight += """
                    <p>
                    <span>\(stringLoader.getString(item.key).text)</span><br>
                    <span class=\"strong\">\(item.value.pdfString)</span>
                    </p>
                    """
                    items = Array(items.dropFirst())
                } else {
                    sectionRight += "<p> <br> <br> </p>"
                }
            }
            sectionLeft += "</section>"
            sectionRight += "</section>"
            html += sectionLeft
            html += sectionRight
            html += "</div>"
        }
    }
    
    func build() -> String {
        html += """
        <footer class="content_Data content_Data_5">
        <p>\(stringLoader.getString("pdf_text_seePdf").text)</p>
        </footer>
        </div>
        """
        return html
    }
}
