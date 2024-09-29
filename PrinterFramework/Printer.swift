//
//  Printer.swift
//  PrinterFramework
//
//  Created by nyuksoon.vong on 19/3/24.
//
//
//  Printer.swift
//  PrinterFramework
//
//  Created by nyuksoon.vong on 19/3/24.
//

import CoreBluetooth
import Foundation

public enum PrinterError: LocalizedError {
    case runTimeError(String)
    
    public var errorDescription: String? {
        switch self {
        case .runTimeError(let string):
            return string
        }
    }
}

public protocol PrinterEventDelegate: AnyObject {
    func onError(message: String) -> Void
    func onSuccessPrinted() -> Void
}

public final class Printer: NSObject {
    
    public enum TextFont {
        case A, B, C, D, E
        
        public var rawValue: Int32 {
            switch self {
            case .A:
                EPOS2_FONT_A.rawValue
            case .B:
                EPOS2_FONT_B.rawValue
            case .C:
                EPOS2_FONT_C.rawValue
            case .D:
                EPOS2_FONT_D.rawValue
            case .E:
                EPOS2_FONT_E.rawValue
            }
        }
    }
    
    public enum TextStyle {
        case header, large, medium, normal
        
        public var size: Int {
            switch self {
            case .header:
                4
            case .large:
                3
            case .medium:
                2
            case .normal:
                1
            }
        }
    }
    
    public struct Configuration {
        public let printerSeries: Epos2PrinterSeries
        public let printerModelLang: Epos2ModelLang
        
        public init(printerSeries: Epos2PrinterSeries, printerModelLang: Epos2ModelLang) {
            self.printerSeries = printerSeries
            self.printerModelLang = printerModelLang
        }
        
        public static var m30II: Configuration {
            Configuration(
                printerSeries: EPOS2_TM_M30II,
                printerModelLang: EPOS2_MODEL_ANK
            )
        }
    }
    
    public struct Template {
        
        public enum Kind {
            case text(String)
            case textWith(
                left: String? = nil,
                right: String? = nil,
                columnWidth: Int,
                tabIndent: Int?
            )
            case line(columnWidth: Int)
            
            var value: String {
                switch self {
                case .text(let string):
                    return string
                case .textWith(let left, let right, let columnWidth, let tabIndent):
                    let padded = "".leftPadding(toLength: tabIndent ?? 0, withPad: " ")
                    return padLine(
                        partOne: "\(padded)\(left ?? "")",
                        partTwo: right,
                        columnsPerLine: columnWidth,
                        tabIndent: tabIndent ?? 0
                    )
                case .line(let columnWidth):
                    let lineText = Array(repeating: String.self, count: columnWidth)
                        .reduce(into: "") { partialResult, str in
                            partialResult += "-"
                        }
                    return lineText
                }
            }
        }
        
        public let kind: Kind
        public let textStyle: TextStyle
        public let textFont: TextFont
        public let lineBreakAfter: Bool
        
        public init(kind: Kind, textStyle: TextStyle, textFont: TextFont, lineBreakAfter: Bool) {
            self.kind = kind
            self.textFont = textFont
            self.textStyle = textStyle
            self.lineBreakAfter = lineBreakAfter
        }
    }
    
    private var printer: Epos2Printer?
    private var printerDiscovery: PrinterDiscovery?
    private var centralManager: CBCentralManager?
    private var isDeviceFound = false
    
    public weak var printerEventDelegate: PrinterEventDelegate?
    
    ///
    /// Default will use the ``Configuration.m30II`` configuration
    ///
    public init(
        configuration: Configuration = .m30II
    ) {
        super.init()
        self.requestPermissionIfNeeded {
            self.setupPrinter(with: configuration)
        }
    }
    
    private func requestPermissionIfNeeded(completion: @escaping () -> Void) {
        self.searchPrinter()
        self.printerDiscovery?.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
            cleanup()
            completion()
        }
    }
    
    private func setupPrinter(with configuration: Configuration) {
        printer = Epos2Printer(
            printerSeries: configuration.printerSeries.rawValue,
            lang: configuration.printerModelLang.rawValue
        )
        printer?.setReceiveEventDelegate(self)
    }
    
    private func searchPrinter() {
        debugPrint("PRINT -> searchPrinter")
        isDeviceFound = false
        
        centralManager = CBCentralManager()
        printerDiscovery = PrinterDiscovery()
        
        printerDiscovery?.delegate = self
        centralManager?.delegate = self
        
        debugPrint("PRINT -> delegate is set")
        
        let timeout: DispatchTime = .now() + 15
        DispatchQueue.main.asyncAfter(deadline: timeout) { [self] in
            if !isDeviceFound {
                notifyError(message: "Unable to discover connected printer")
            }
        }
    }
    
    @discardableResult
    private func handleError(
        _ resultCode:Int32,
        method: String,
        reason: String = ""
    ) -> String {
        let bundle = Bundle(for: type(of: self))
        let msg = String(format: "%@ %@ %@ %@\n",
                         method,
                         NSLocalizedString("methoderr_errcode", bundle: bundle, comment:""),
                         getEposErrorText(resultCode),
                         reason
        )
        return msg
    }
    
    fileprivate func getEposErrorText(_ error : Int32) -> String {
        var errText = ""
        switch (error) {
        case EPOS2_SUCCESS.rawValue:
            errText = "SUCCESS"
            break
        case EPOS2_ERR_PARAM.rawValue:
            errText = "ERR_PARAM"
            break
        case EPOS2_ERR_CONNECT.rawValue:
            errText = "ERR_CONNECT"
            break
        case EPOS2_ERR_TIMEOUT.rawValue:
            errText = "ERR_TIMEOUT"
            break
        case EPOS2_ERR_MEMORY.rawValue:
            errText = "ERR_MEMORY"
            break
        case EPOS2_ERR_ILLEGAL.rawValue:
            errText = "ERR_ILLEGAL"
            break
        case EPOS2_ERR_PROCESSING.rawValue:
            errText = "ERR_PROCESSING"
            break
        case EPOS2_ERR_NOT_FOUND.rawValue:
            errText = "ERR_NOT_FOUND"
            break
        case EPOS2_ERR_IN_USE.rawValue:
            errText = "ERR_IN_USE"
            break
        case EPOS2_ERR_TYPE_INVALID.rawValue:
            errText = "ERR_TYPE_INVALID"
            break
        case EPOS2_ERR_DISCONNECT.rawValue:
            errText = "ERR_DISCONNECT"
            break
        case EPOS2_ERR_ALREADY_OPENED.rawValue:
            errText = "ERR_ALREADY_OPENED"
            break
        case EPOS2_ERR_ALREADY_USED.rawValue:
            errText = "ERR_ALREADY_USED"
            break
        case EPOS2_ERR_BOX_COUNT_OVER.rawValue:
            errText = "ERR_BOX_COUNT_OVER"
            break
        case EPOS2_ERR_BOX_CLIENT_OVER.rawValue:
            errText = "ERR_BOXT_CLIENT_OVER"
            break
        case EPOS2_ERR_UNSUPPORTED.rawValue:
            errText = "ERR_UNSUPPORTED"
            break
        case EPOS2_ERR_FAILURE.rawValue:
            errText = "ERR_FAILURE"
            break
        default:
            errText = String(format:"%d", error)
            break
        }
        return errText
    }
    
    private func disconnect() {
        guard let printer else { return }
        
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        let printerStatus = printer.getStatus()
        let isConnected = printerStatus?.connection == EPOS2_TRUE
        if isConnected {
            //Note: This API must be used from background thread only
            result = printer.disconnect()
            if result != EPOS2_SUCCESS.rawValue {
                DispatchQueue.main.async {
                    let msg = self.handleError(result, method: "Disconnect")
                    self.notifyError(message: msg)
                }
            }
        }
        
        printer.clearCommandBuffer()
    }
    
    private func align() throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        
        var result = EPOS2_SUCCESS.rawValue
        result = printer.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            let msg = handleError(result, method: "addTextAlign")
            throw PrinterError.runTimeError(msg)
        }
    }
    
    private func nextLine(line: Int) throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        
        var result = EPOS2_SUCCESS.rawValue
        result = printer.addFeedLine(line)
        if result != EPOS2_SUCCESS.rawValue {
            printer.clearCommandBuffer()
            let msg = handleError(result, method: "feedLine")
            throw PrinterError.runTimeError(msg)
        }
    }
    
    private func configureFont(with font: TextFont) throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        
        var result = EPOS2_SUCCESS.rawValue
        result = printer.addTextFont(font.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            printer.clearCommandBuffer()
            let msg = handleError(result, method: "addTextFont")
            throw PrinterError.runTimeError(msg)
        }
    }
    
    private func configureText(style: TextStyle) throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        
        var result = EPOS2_SUCCESS.rawValue
        
        switch style {
        case .header:
            fallthrough
        case .large:
            fallthrough
        case .medium:
            fallthrough
        case .normal:
            result = printer.addTextSize(
                style.size,
                height: style.size
            )
            if result != EPOS2_SUCCESS.rawValue {
                printer.clearCommandBuffer()
                let msg = handleError(result, method: "addTextSize")
                throw PrinterError.runTimeError(msg)
            }
        }
    }
    
    private func cutFeed() throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        
        var result = EPOS2_SUCCESS.rawValue
        result = printer.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            printer.clearCommandBuffer()
            let msg = handleError(result, method: "addCut")
            throw PrinterError.runTimeError(msg)
        }
    }
    
    public func setTemplate(templates: [Template]) throws {
        guard let printer else {
            throw PrinterError.runTimeError("Printer not found")
        }
        var text = ""
        
        try templates.forEach { template in
            try align()
            try configureText(style: template.textStyle)
            try configureFont(with: template.textFont)
            
            var result = EPOS2_SUCCESS.rawValue
            result = printer.addText(template.kind.value)
            text += template.kind.value
            if result != EPOS2_SUCCESS.rawValue {
                printer.clearCommandBuffer()
                let msg = handleError(result, method: "addText")
                throw PrinterError.runTimeError(msg)
            }
            
            if template.lineBreakAfter {
                try nextLine(line: 1)
            }
        }
        
        debugPrint(text)
    }
    
    public func print() {
        do {
            try cutFeed()
            searchPrinter()
        } catch {
            debugPrint("PRINT -> print err")
            notifyError(message: error.localizedDescription)
            return
        }
    }
    
    private func printData(using printer: Epos2Printer) {
        let result = printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            let msg = self.handleError(result, method: "sendData")
            debugPrint("PRINT -> printData error")
            notifyError(message: msg)
        }
    }
    
    private func cleanup() {
        debugPrint("PRINT -> clean delegate")
        Epos2Discovery.stop()
        
        disconnect()
        
        printerDiscovery = nil
        printerDiscovery?.delegate = nil
        
        centralManager = nil
        centralManager?.delegate = nil
    }
    
    private func notifyOk() {
        debugPrint("PRINT -> notifyOk on Threadh: \(Thread.current)")
        printerEventDelegate?.onSuccessPrinted()
        cleanup()
    }
    
    private func notifyError(message: String) {
        debugPrint("PRINT -> notifyError")
        printerEventDelegate?.onError(message: message)
        cleanup()
    }
}

// MARK: - Epos2DiscoveryDelegate
extension Printer: Epos2DiscoveryDelegate {
    public func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        debugPrint("PRINT -> onDiscovery")
        guard let printer else { return }
        Epos2Discovery.stop()
        
        let result = printer.connect(
            deviceInfo.target,
            timeout: Int(EPOS2_PARAM_DEFAULT)
        )
        if result != EPOS2_SUCCESS.rawValue {
            let msg = self.handleError(result, method: "Connect")
            notifyError(message: msg)
            return
        }
        
        isDeviceFound = true
        printData(using: printer)
    }
}

// MARK: - CBCentralManagerDelegate
extension Printer: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        debugPrint("PRINT -> centralManagerDidUpdateState")
        switch central.state {
        case .poweredOn:
            debugPrint("PRINT -> centralManagerDidUpdateState ok")
            self.printerDiscovery?.start()
        default:
            debugPrint("PRINT -> centralManagerDidUpdateState not ok")
            self.notifyError(message: "Bluetooth not turned on.")
        }
    }
}

// MARK: - Epos2PtrReceiveDelegate
extension Printer: Epos2PtrReceiveDelegate {
    public func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        DispatchQueue.main.async { [self] in
            let msg = makeErrorMessage(status)
            if msg != "" {
                debugPrint("PRINT -> onPtrReceive err")
                notifyError(message: msg)
            } else {
                notifyOk()
            }
        }
    }
    
    func makeErrorMessage(_ status: Epos2PrinterStatusInfo?) -> String {
        let bundle = Bundle(for: type(of: self))
        let errMsg = NSMutableString()
        if status == nil {
            return ""
        }
        
        if status!.online == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_offline", bundle: bundle, comment:""))
        }
        if status!.connection == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_no_response", bundle: bundle, comment:""))
        }
        if status!.coverOpen == EPOS2_TRUE {
            errMsg.append(NSLocalizedString("err_cover_open", bundle: bundle, comment:""))
        }
        if status!.paper == EPOS2_PAPER_EMPTY.rawValue {
            errMsg.append(NSLocalizedString("err_receipt_end", bundle: bundle, comment:""))
        }
        if status!.paperFeed == EPOS2_TRUE || status!.panelSwitch == EPOS2_SWITCH_ON.rawValue {
            errMsg.append(NSLocalizedString("err_paper_feed", bundle: bundle, comment:""))
        }
        if status!.errorStatus == EPOS2_MECHANICAL_ERR.rawValue || status!.errorStatus == EPOS2_AUTOCUTTER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_autocutter", bundle: bundle, comment:""))
            errMsg.append(NSLocalizedString("err_need_recover", bundle: bundle, comment:""))
        }
        if status!.errorStatus == EPOS2_UNRECOVER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_unrecover", bundle: bundle, comment:""))
        }
        
        if status!.errorStatus == EPOS2_AUTORECOVER_ERR.rawValue {
            if status!.autoRecoverError == EPOS2_HEAD_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", bundle: bundle, comment:""))
                errMsg.append(NSLocalizedString("err_head", bundle: bundle, comment:""))
            }
            if status!.autoRecoverError == EPOS2_MOTOR_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", bundle: bundle, comment:""))
                errMsg.append(NSLocalizedString("err_motor", bundle: bundle, comment:""))
            }
            if status!.autoRecoverError == EPOS2_BATTERY_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", bundle: bundle, comment:""))
                errMsg.append(NSLocalizedString("err_battery", bundle: bundle, comment:""))
            }
            if status!.autoRecoverError == EPOS2_WRONG_PAPER.rawValue {
                errMsg.append(NSLocalizedString("err_wrong_paper", bundle: bundle, comment:""))
            }
        }
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_0.rawValue {
            errMsg.append(NSLocalizedString("err_battery_real_end", bundle: bundle, comment:""))
        }
        if (status!.removalWaiting == EPOS2_REMOVAL_WAIT_PAPER.rawValue) {
            errMsg.append(NSLocalizedString("err_wait_removal", bundle: bundle, comment:""))
        }
        if (status!.unrecoverError == EPOS2_HIGH_VOLTAGE_ERR.rawValue ||
            status!.unrecoverError == EPOS2_LOW_VOLTAGE_ERR.rawValue) {
            errMsg.append(NSLocalizedString("err_voltage", bundle: bundle, comment:""));
        }
        
        return errMsg as String
    }
}
