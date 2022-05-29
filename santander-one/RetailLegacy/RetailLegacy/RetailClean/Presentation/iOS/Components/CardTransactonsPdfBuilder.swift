import Foundation
import CoreFoundationLib

class CardTransactionsPdfBuilder {
    // MARK: - Private attributes
    
    private var html: String = ""
    private let stringLoader: StringLoader
    private let timeManager: TimeManager
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader, timeManager: TimeManager) {
        self.stringLoader = stringLoader
        self.timeManager = timeManager
    }
    
    func addHeader() {
        html += """
        <!DOCTYPE html>
        <html lang="es">
            <head>
                <meta charset="utf-8" />
                <title th:text="${t0}"></title>
                <meta http-equiv="X-UA-Compatible" content="IE=edge" />
                <base href="" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <meta name="format-detection" content="telephone=no" />
                <link rel="shortcut icon" type="image/x-icon" href="favicon.ico" />
                <meta
                    http-equiv="Cache-Control"
                    content="no-cache, no-store, must-revalidate"
                />
                <meta http-equiv="Pragma" content="no-cache" />
                <meta http-equiv="Expires" content="0" />
        
                <!-- import global css -->
                <link rel="stylesheet" type="text/css" href="css/styles.css"/>
        
                <script>
                    var isjQuery = false;
                    window.onload = function() {
                        if (window.jQuery) {
                            isjQuery = true;
                        }
                    };
                </script>
                <style>
        
        @font-face {
        font-family: 'Lato Regular';
        font-style: normal;
        font-weight: normal;
        src: url('Lato-Regular.ttf') format('truetype');
        }
        
        @font-face {
        font-family: 'Lato Bold';
        font-style: normal;
        font-weight: normal;
        src: url('Lato-Bold.ttf') format('truetype');
        }
        @font-face {
        font-family: 'Lato SemiBold';
        src: url('Lato-Semibold.ttf') format('truetype');
        font-weight: normal;
        font-style: normal;
        
        }
        @font-face {
        font-family: 'Lato Light';
        src: url('Lato-Light.ttf') format('truetype');
        font-weight: normal;
        font-style: normal;
        }
        
        * {
        margin: 0;
        padding: 0;
        }
        body {
        font-family: 'Lato Regular';
        }
        /*  Head code  */
        .headPrint{
        display: block;
        /* float: left; */
        width: 100%;
        height: auto;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #eaeaea;
        overflow: hidden;
        }
        .margins {
        margin: 0% 6.4% 0% 6.1%;
        }
        .table-margins {
        margin-bottom: 1%;
        }
        .logoContainer{
        display: inline-block;
        float: left;
        width: 30%;
        }
        .headerBox{
        width: 70%;
        display: inline-block;
        float: left;
        }
        .headerContainer{
        display: inline-block;
        /* float: left; */
        width: calc(100% - 3%);
        margin-left: 3%;
        font-size: 12px;
        }
        .nameContainer{
        /* width: 54%;
        display: inline-block; */
        }
        img{
        margin-bottom: 10px;
        }
        .bodyPrint{
        /* float: left; */
        display: block;
        width: 100%;
        font-family: 'Lato Regular';
        }
        .tableTitleContainer{
        /* float: left; */
        display: block;
        width: 100%;
        min-width: 100%;
        max-width: 100%;
        margin-bottom: 10px;
        overflow: auto;
        }
        .tableTitleContainer p:first-child {
        
        }
        .tableTitle{
        color: #444;
        font-size: 16px;
        text-transform: uppercase;
        padding-right: 5px;
        /* width: 50%; */
        font-family: 'Lato Bold';
        display: inline-block;
        /* float: left; */
        }
        .dateTimeContainer{
        color: #4a4a4a;
        font-size: 12px;
        font-family: 'Lato Bold';
        text-transform: uppercase;
        width: 50%;
        display: inline-block;
        /* float: left; */
        }
        /*  Body Code  */
        
        table{
        border-spacing: unset !important;
        font-size: 12px;
        display: block;
        /* float: left; */
        width: 100%;
        border: 1px solid #eaeaea;
        }
        
        .fondoHeader{
        position: relative;
        display: inline-block;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        }
        p{
        word-break: break-word;
        }
        .tableHeader{
        width: 100%;
        display: inline-table;
        }
        .tableHeader tr{
        position: relative;
        border-spacing: unset !important;
        }
        .tableHeader tr th{
        position: relative;
        background: #eaeaea;
        font-family: 'Lato Bold'!important;
        font-weight: 400;
        color: #4A4A4A;
        padding: 3px;
        }
        .tableHeader tr th .fondoHeader{
        position: absolute;
        left: 0;
        right: 0;
        bottom: 0;
        top: 0;
        width: 100%;
        height: 100%;
        z-index: -1;
        }
        .cellHeaderContent{
        height: auto;
        }
        .tableBody{
        width: 100%;
        display: inline-table;
        }
        .tableBody tr{
        border-bottom: 1px solid #4A4A4A;
        margin-bottom: 3px;
        margin-top: 3px;
        font-size: 12px;
        }
        .tableBody .cell{
        border-bottom: 1px solid #eaeaea;
        padding: 3px;
        overflow: hidden;
        word-break: break-all;
        text-overflow: ellipsis;
        }
        .tableBody .cell span{
        overflow: hidden;
        word-break: break-word;
        text-overflow: ellipsis;
        line-height: 16.2px;
        }
        .cellTableContent{
        max-height: 33px !important;
        min-height: 33px !important;
        height: 33px !important;
        overflow: hidden;
        position: relative;
        }
        .tableBody tr{
        border-bottom: 1px solid #4A4A4A;
        }
        
        .tableBody .dateContainer {
        font-size: 10px;
        color: #767676;
        }
        .dateContainer .fValue{
        font-size: 12px;
        }
        /*  Foo code  */
        
        .fooPrint{
        display: block;
        /* float: left; */
        width: 100%;
        }
        
        .fooPrint p{
        font-size: 9px;
        text-align: justify;
        text-align-last: left;
        }
        .c-header .c-header__logo{
        width: 135px;
        float: left;
        }
        section.c-header.c-header--border {
        height: 55px;
        }
        .c-header .c-header__info {
        width: 70%;
        float: left;
        margin-left: 30px;
        }
        /* .c-header .c-header__info .c-header__info-fullData {
        width: 100%;
        float: left;
        }
        
        .c-header .c-header__info .c-header__info-rightData{
        width: 40%;
        float: left;
        display: block;
        overflow: hidden;
        text-align: left;
        } */
        
        .c-header .c-header__info .c-header__info_data {
        color: #999999;
        font-size: 12px;
        }
        .c-header .c-header__info .c-header__info_data--uppercase {
        text-transform: uppercase;
        }
        .c-header .c-header__info .c-header__info_data--big {
        font-size: 16px;
        }
        .c-header .c-header__info .c-header__info_data--bold{
        color:#4a4a4a;
        font-family:'Lato Bold'!important;
        }
        .c-header .c-header__info .c-header__info_data--light {
        color: #9e9e9e;
        }
        .c-header .c-header__info .c-header__info_data--titular {
        font-family: 'Lato SemiBold' !important;
        font-weight: 700;
        color: #4A4A4A;
        line-height: 15px;
        /* font-size: 11.5px; */
        }
        .c-header .c-header__info .c-header__info_data--titular::after {
        content: ":";
        }
        .c-header .c-header__info .c-header__info_data--titular--nopoints::after {
        content: " ";
        }
        .c-header .c-header__info .c-header__info_data--mgLeft {
        margin-left: 3px;
        color: #4A4A4A;
        }
        
        .c-header__logo img {
        margin:0px !important;
        }
        
        
        /*  Commons  */
        .r-al{
        text-align: right !important;
        }
        .l-al{
        text-align: left !important;
        }
        .l-al span{
        margin-left: .5px;
        }
        .f-op{
        width: 20%;
        min-width: 20%;
        max-width: 20%;
        }
        .c-op{
        width: 48%;
        min-width: 48%;
        max-width: 48%;
        }
        .c-op span{
        font-size: 12px;
        }
        .i-op{
        width: 16%;
        min-width: 16%;
        max-width: 16%;
        }
        .s-op{
        width: 16%;
        min-width: 16%;
        max-width: 16%;
        }
        .kvtitle{
        display: inline-block;
        /* float: left; */
        }
        .kvtitle span{
        color: #000;
        }
        .nameBox{
        display: inline-block;
        /* float: left; */
        margin-left: 1%;
        }
        .titular{
        margin-right: 3px;
        font-family: 'Lato SemiBold';
        font-weight: 700;
        color: #8a8a8a;
        line-height: 15px;
        margin-top: 0px;
        margin-bottom: 0px;
        }
        table, tbody, tr{
        width: 100% !important;
        }
        .textBlock{
        display: block;
        width: 100%;
        }
        .dateContainer.fValue{
        font-size: 10px;
        }
        .sort{
        margin-left: 5px;
        }
        
        .title_secundary {
        color:#ec0000;
        text-transform: uppercase;
        margin-bottom: 0px;
        }
        .u-inline.c-tableHeader__title--secondary.title_secundary {
        color:#ec0000;
        text-transform: initial;
        font-family: 'Lato Regular' !important;
        font-size: 13px;
        margin-top:20px;
        }
        .disclaimer p {
        font-size: 12px;
        font-family: 'Lato Regular' !important;
        text-align: center;
        margin-top: 10px;
        }
                </style>
            </head>
            <body class="t-pdf__list margins">
                <!-- content -->
                <section class="bodyPrint">
        """
    }
    
    private func addNewTableHeader() {
        html += """
        <table border="0" cellspacing="0" cellpadding="0" class="table-margins">
        <thead class="tableHeader">
        <!-- table TITULOS -->
        <tr>
        <th class="cell l-al f-op">
        <div class="cellHeaderContent">
        <span th:text="${t3}">\(stringLoader.getString("pdf_label_operationDate").text)</span>
        <svg class="fondoHeader">
        <rect width="100%" height="100%" style="fill:#eaeaea !important"/>
        </svg>
        </div>
        
        </th>
        <th class="cell l-al c-op">
        <div class="cellHeaderContent">
        <span th:text="${t4}">\(stringLoader.getString("pdf_label_operation").text)</span>
        <svg class="fondoHeader">
        <rect width="100%" height="100%" style="fill:#eaeaea !important"/>
        </svg>
        </div>
        </th>
        <th class="cell r-al i-op">
        <div class="cellHeaderContent">
        <span th:text="${t5}">\(stringLoader.getString("pdf_label_amount").text)</span>
        <svg class="fondoHeader">
        <rect width="100%" height="100%" style="fill:#eaeaea !important"/>
        </svg>
        </div>
        </th>
        </tr>
        </thead>
        <tbody class="tableBody">
        """
    }
        
    func addTransactionsInfo(_ info: [CardTransactionEntityProtocol]) {
        guard !info.isEmpty else { return }
        for i in 0..<info.count {
            if i % 20 == 0 {
                if i != 0 {
                    html += "</tbody></table>"
                }
                addNewTableHeader()
            }
            guard let description = info[i].description, let value = info[i].amount else { return }
            html += """
            <tr th:each="statement : ${statements}">
                <td class="cell l-al f-op">
                    <div class="cellTableContent">
                        <span th:text="${statement.p2}">\(timeManager.toString(date: info[i].transactionDate, outputFormat: .dd_MM_yyyy) ?? "")</span>
                        <div class="dateContainer fValue">
                            <span th:text="${t6}">\(stringLoader.getString("pdf_label_valueDate").text) \(dateFrom(dateStr: info[i].valueDate ?? "") ?? "")</span>
                            <span th:text="${statement.p1}"></span>
                        </div>
                    </div>
                </td>
                <td class="cell l-al c-op">
                    <div class="cellTableContent">
                        <span th:text="${statement.p5}">\(description.camelCasedString)</span>
                    </div>
                </td>
                <td class="cell r-al i-op">
                    <div class="cellTableContent">
                        <span th:text="${statement.p7}" class="quantity">\(value.dto.wholePart) \(value.dto.currency?.currencyName ?? "")</span>
                    </div>
                </td>
            </tr>
            """
        }
        html += "</tbody></table>"
    }
    
    func addDisclaimer() {
        html += """
        <section class="disclaimer">
            <p th:text="${t7}">\(stringLoader.getString("pdf_text_legalFooter").text)</p>
        </section>
        """
    }
    
    func build() -> String {
        html += """
            </body>
        </html>
        """
        return html
    }
    
    // MARK: - Private Methods
    
    private func dateFrom(dateStr: String) -> String? {
        let date =  dateFromString(input: dateStr, inputFormat: .yyyyMMdd)
        let dateStr = dateToString(date: date, outputFormat: .dd_MM_yyyy) ?? ""
        return dateStr
    }
    
    private func dateFromString(input: String?, inputFormat: TimeFormat) -> Date? {
        return self.fromString(input: input, inputFormat: inputFormat.rawValue)
    }
    
    private func fromString(input: String?, inputFormat: String) -> Date? {
        return timeManager.fromString(input: input, inputFormat: inputFormat)
    }
}
