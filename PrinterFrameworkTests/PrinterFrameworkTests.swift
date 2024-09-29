//
//  PrinterFrameworkTests.swift
//  PrinterFrameworkTests
//
//  Created by nyuksoon.vong on 30/5/24.
//

import XCTest
@testable import PrinterFramework

final class PrinterFrameworkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPrinter_print_shouldHandleWrapOnRightSide() throws {
        // given
        let printer = Printer()
        let templates = [
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    "Chicken Stop"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    "\n #30003 \n"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.header,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    "Placed on 30 May 2024, 09:47 AM \n"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    " Kenton android"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    " \n"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    "Total Item: 1"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.line(
                    columnWidth: 24
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "Payment Method:"
                    ),
                    right: Optional(
                        "Visa"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "Delivery Option:"
                    ),
                    right: Optional(
                        "In-store pickup"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.line(
                    columnWidth: 24
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "1x 1pc. Chicken Meal"
                    ),
                    right: Optional(
                        "$20"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "Green Tea"
                    ),
                    right: Optional(
                        "$0"
                    ),
                    columnWidth: 24,
                    tabIndent: Optional(
                        3
                    )
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.line(
                    columnWidth: 24
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "Sub Total"
                    ),
                    right: Optional(
                        "$20.00"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "asdasdasd asdlasdh jahskljdhjaskd Promo Code"
                    ),
                    right: Optional(
                        "(20%)$ -$undefined"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.textWith(
                    left: Optional(
                        "Total"
                    ),
                    right: Optional(
                        "$0.00"
                    ),
                    columnWidth: 24,
                    tabIndent: nil
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.line(
                    columnWidth: 24
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: true
            ),
            PrinterFramework.Printer.Template(
                kind: PrinterFramework.Printer.Template.Kind.text(
                    "\n\n\n"
                ),
                textStyle: PrinterFramework.Printer.TextStyle.medium,
                textFont: PrinterFramework.Printer.TextFont.A,
                lineBreakAfter: false
            )
        ]
        
        // When
        XCTAssertNoThrow(try printer.setTemplate(templates: templates), "Should not throw when left overflow")
        
        // Then
        printer.print()
    }

}
