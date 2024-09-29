# Printer SDK

- This repository served as a wrapper to the epson SDK for printing purpose.

### Setup

#### 1. Import XCFramework to APP Project

- Download this repo
- Drag and drop `PrinterFramework.xcframework` to the APP project.
- Make sure in your target's General Tab that the option `Embed & Sign` is selected under "Frameworks, Libraries, and Embedded Content".

#### 2. Set Info.plist

```MD
<dict>

	<key>UISupportedExternalAccessoryProtocols</key>
	<array>
		<string>com.epson.escpos</string>
	</array>

	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>Our app needs Bluetooth access to use the Printer.</string>

</dict>

```

### Example

#### 1. Initiate the printer to use, default will use the `TM-m30II` model.

```swift
let printer = Printer(configuration: .m30II)
```

#### 2. Assign delegate to listen printer event

```swift
printer.printerEventDelegate = self
```

#### 3. Feeds the template

```swift

try printer.setTemplate(
	templates: [
		Printer.Template(
			kind: .text("Starbucks"),
			textStyle: .normal,
			lineBreakAfter: true
		),
		Printer.Template(
			kind: .text("\n #13972 \n"),
			textStyle: .header,
			lineBreakAfter: true
		),
		Printer.Template(
			kind: .text("Placed On 1 Jun 2024, 11:44"),
			textStyle: .normal,
			lineBreakAfter: true
		)]
)
```

#### 4. Print

##### Async way
```swift
try await printer.print()
```

##### Closure way
```swift
try printer.print { result in 
	// Handle result
}
```

#### Full Example

```swift
do {
            let printer = Printer(configuration: .m30II)
            printer.printerEventDelegate = self

            let columnWidth = 42

            let lineText = Array(repeating: String.self, count: columnWidth)
                .reduce(into: "") { partialResult, str in
                    partialResult += "-"
                }

            try printer.setTemplate(
                templates: [
                    Printer.Template(
                        kind: .text("Starbucks"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("\n #13972 \n"),
                        textStyle: .header,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("Placed On 1 Jun 2024, 11:44"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("John Doe"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("Company A"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("Total Item: 5"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text(lineText),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text("Delivery Option: "),
                        textStyle: .normal,
                        lineBreakAfter: false
                    ),
                    Printer.Template(
                        kind: .text("In store pickup"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                    Printer.Template(
                        kind: .text(lineText),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "12x Chicken Parmigiana",
                            right: "$15.50",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "Cranberry Chicken Salad",
                            right: "$95.50",
                            columnWidth: columnWidth,
                            tabIndent: 4
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "This is super long long long Avocado",
                            right: "$955.50",
                            columnWidth: columnWidth,
                            tabIndent: 4
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .text(lineText),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "1x Earl Grey",
                            right: "$15.50",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "50%",
                            right: "$0.50",
                            columnWidth: columnWidth,
                            tabIndent: 4
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "Less Ice",
                            right: "$5.50",
                            columnWidth: columnWidth,
                            tabIndent: 4
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .text(lineText),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "Sub Total",
                            right: "$15.50",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "Promo Code",
                            right: "(10%)$",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: nil,
                            right: "$5.00",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .textWith(
                            left: "Total",
                            right: "$18.00",
                            columnWidth: columnWidth,
                            tabIndent: nil
                        ),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),

                    Printer.Template(
                        kind: .text("\n\(lineText)\n"),
                        textStyle: .normal,
                        lineBreakAfter: true
                    ),
                ]
            )
            try await printer.print()
        } catch {
            print(error.localizedDescription)
        }
```
