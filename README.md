# 📃 Formify - Swift library for fast and easy form and input validation

Formify is a Swift library designed for easy form and input validation. With Formify, you can easily validate all your
TextField or TextEditor elements without needing to add any special changes or modifiers.

### Key facts:

* **👌 Ease of use:** It is very easy to implement Formify into your views and validate inputs - even in existing ones.
* **🏎️ Speed:** With no special magic or any ObservableObjects and subscribers, the library is very fast
* **📐 Size:** Very small footprint
* **🚀 Performance:** Minimal performance impact

## Requirements

* XCode 16
* Swift 6
* iOS 16.0 / macOS 13.0 / tvOS 16.0 / watchOS 9.0

## Installation

### Swift Package Manager

Add the following to the Package.swift of your Swift package:

```
dependencies: [
    .package(url: "https://github.com/sanzaru/formify.git", from: "0.0.1")
]
```

### XCode

Add the following package to your project:

    https://github.com/sanzaru/formify.git

## Usage

Formify uses `FormifyField` objects with `FormifyOperator` operators for input management and validation.
All `FormifyField` objects come with a `value` attribute of type String. This value can be used as a binding inside a
`TextField` or `TextEditor` view.

You can check the validity by simply checking the `isValid` attribute or the `errors` array of the field.

The simplest form of validation would be to declare a state variable inside a view, use the `value` of the
`FormifyField` inside a TextField, and check the `isValid` attribute:

```swift
...

@State private var formField = FormifyField(operators: [.required, .pattern(/[A-Za-z ]+/)])

...

TextField("", text: $formField.value)
    .textFieldStyle(.plain)

...

Button { } label: {
    Text("Submit")
}
.disabled(!formField.isValid)

...

```

> [!NOTE]
> You can also pass the `FormifyField` as a `@Binding` into views or use the object inside an `@ObservableObject` as a
`@Published` variable. See the example for more information.


## Operators

| Name | Description | Example |
| --- | --- | --- |
| .required | If set, the field becomes required and cannot be left empty. | ```.required``` |
| .minLength(Int) | If set, the value must be longer than the provided length. | ```.minLength(10)``` |
| .maxLength(Int) | If set, the value must be shorter than the provided length. | ```.maxLength(10)``` |
| .pattern(RegEx) | If set, the value must match the provided regular expression. | ```.pattern(/[a-zA-Z]/)``` |


## Example

The following example shows a simple view with a form containing three fields: a name, an email address, and a custom
value. The name and email fields are required and validated against specific patterns. The name field also has minimum
and maximum length validation, while the custom field is only required without additional validation:

```swift
import SwiftUI
import Formify

struct ContentView: View {
    struct FormFields {
        var name = FormifyField(operators: [.required, .minLength(10), .maxLength(20), .pattern(/[A-Za-z ]+/)])
        var email = FormifyField("foo@bar.com", operators: [.pattern(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/)])
        var custom = FormifyField("Preset value", operators: [.required])

        var isValid: Bool {
            name.isValid && email.isValid && custom.isValid
        }
    }
    @State private var formFields = FormFields()

    var body: some View {
        NavigationStack {
            Form {
                // Name text field
                VStack(alignment: .leading) {
                    Text("Name*")
                        .foregroundColor(.teal)

                    TextField("John Doe", text: $formFields.name.value)
                        .textFieldStyle(.plain)
                        .modifier(FormValidationErrorWrapperModifier(formField: $formFields.name))
                }

                // Email text field
                VStack(alignment: .leading) {
                    Text("Email*")
                        .foregroundColor(.teal)

                    TextField("example@mail.com", text: $formFields.email.value)
                        .textFieldStyle(.plain)
                        .modifier(FormValidationErrorWrapperModifier(formField: $formFields.email))
                }

                // Custom text field
                VStack(alignment: .leading) {
                    Text("Custom")
                        .foregroundColor(.teal)

                    TextField("Some value", text: $formFields.custom.value)
                        .textFieldStyle(.plain)
                        .modifier(FormValidationErrorWrapperModifier(formField: $formFields.custom))
                }
            }
            .navigationTitle("Example Form")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { print("Submit") } label: {
                        Text("Submit")
                    }
                    .disabled(!formFields.isValid)
                }
            }
        }
    }
}
```

Additionally, the following example shows a simple ViewModifier that wraps all errors and displays a message underneath
the TextField:

```swift
import SwiftUI
import Formify

struct FormValidationErrorWrapperModifier: ViewModifier {
    @Binding var formField: FormifyField

    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content

            let errors = formField.errors
            if !errors.isEmpty, formField.isTouched {
                ForEach(errors, id: \.self) { error in
                    Group {
                        switch error {
                        case .pattern: Text("Invalid pattern")
                        case .required: Text("Required")
                        case .minLength(let length): Text("Min length \(length) / \(formField.minLength ?? 0)")
                        case .maxLength(let length): Text("Max length \(length) / \(formField.maxLength ?? 0)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
    }
}
```
