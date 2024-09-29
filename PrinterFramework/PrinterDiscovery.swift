//
//  PrinterDiscovery.swift
//  PrinterFramework
//
//  Created by nyuksoon.vong on 19/3/24.
//

import Foundation

final class PrinterDiscovery: NSObject {
    
    weak var delegate: Epos2DiscoveryDelegate?
    
    func start() {
        Epos2Discovery.stop()
        
        let filterOption = Epos2FilterOption()
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        let result = Epos2Discovery.start(
            filterOption,
            delegate: delegate
        )
        if result != EPOS2_SUCCESS.rawValue {
            return
        }
        
    }
}
