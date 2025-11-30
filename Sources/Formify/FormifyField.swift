//
//  FormifyField.swift
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

import Foundation

/// A structure representing the state, validation, and configuration of a single form field.
///
/// `FormifyField` encapsulates the value of a form field along with common validation requirements such as
/// required status, minimum and maximum length, pattern matching, and custom validation logic. It
/// automatically validates its value whenever it changes and tracks its validation errors, as well as whether
/// the field has been interacted with (`isTouched`).
///
/// - Note:
///   The field can be configured to automatically trim whitespace and newlines from its value unless
///   `disableTrimming` is set via the appropriate operator.
///
/// ### Example
///
/// ```swift
/// var field = FormifyField("Initial", operators: [.required, .minLength(3)])
/// field.value = "Test"
/// if field.isValid {
///     // Proceed if valid
/// }
/// ```
///
/// - Parameters:
///   - value: The current value of the form field. Setting this value triggers validation.
///   - errors: An array of validation errors currently present on the field.
///   - isRequired: Indicates whether the field is required.
///   - isTouched: Indicates whether the field has been interacted with (non-empty at least once).
///   - minLength: Optional minimum character length for the field's value.
///   - maxLength: Optional maximum character length for the field's value.
///   - pattern: Optional regular expression pattern that the value must match.
///   - customHandler: Optional custom validation handler for user-supplied validation logic.
///   - isValid: Returns `true` if the field passes all validation checks; otherwise, `false`.
///
/// - SeeAlso: `FormifyOperator`, `FormifyError`
public struct FormifyField {
    public var value: String {
        didSet {
            if value != oldValue {
                if !value.isEmpty {
                    isTouched = true
                }

                if !disableTrimming {
                    value = value.trimmingCharacters(in: .whitespacesAndNewlines)
                }

                validate()
            }
        }
    }

    public private(set) var errors = [FormifyError]()
    public private(set) var isRequired = false
    public private(set) var isTouched = false
    public private(set) var minLength: Int?
    public private(set) var maxLength: Int?
    public private(set) var pattern: String?
    public private(set) var customHandler: FormifyCustomValidationHandler?

    private var disableTrimming = false

    /// Indicates whether the form field is currently valid, based on all applied validation rules.
    ///
    /// - Returns: 
    ///   `true` if the field passes all validation checks, including required status, minimum and maximum length, 
    ///   pattern matching, and custom validation logic. If the field is required and empty, this will be `false`.
    ///   Otherwise, it is `true` only when the `errors` array is empty.
    ///
    /// - Note:
    ///   This property reflects the most recent validation state and is automatically updated whenever the field's
    ///   value changes.
    ///
    /// - SeeAlso: `errors`, `isRequired`
    public var isValid: Bool {
        isRequired && value.isEmpty ? false : errors.isEmpty
    }

    /// Initializes a new `FormifyField` instance with the provided initial value and validation operators.
    ///
    /// - Parameters:
    ///   - initialValue: The starting value of the field. Defaults to an empty string if not provided.
    ///   - operators: An array of `FormifyOperator` values that configure validation rules and field behavior.
    ///
    /// This initializer configures the form field's validation state based on the provided operators, such as
    /// requiring a value, setting minimum or maximum length, applying a regular expression pattern, or supplying
    /// a custom validation handler. The field is also marked as touched if the initial value is non-empty.
    ///
    /// - Note: Validation is performed immediately after initialization.
    ///
    /// - SeeAlso: `FormifyOperator`
    public init(_ initialValue: String = "", operators: [FormifyOperator] = []) {
        self.value = initialValue
        self.isTouched = !initialValue.isEmpty

        operators.forEach {
            switch $0 {
            case .required:
                isRequired = true
            case .minLength(let length):
                minLength = length
            case .maxLength(let length):
                maxLength = length
            case .pattern(let regex):
                pattern = regex
            case .email:
                pattern = FormifyDefaultPattern.email.rawValue
            case .phonenumber:
                pattern = FormifyDefaultPattern.phone.rawValue
            case .urlNoScheme:
                pattern = FormifyDefaultPattern.urlNoScheme.rawValue
            case .urlWithScheme:
                pattern = FormifyDefaultPattern.urlWithScheme.rawValue
            case .disableTrimming:
                disableTrimming = true
            case .custom(let handler):
                customHandler = handler
            }
        }

        validate()
    }
}

// MARK: Validation

extension FormifyField {
    /// Validates the current state of the form field against all applied validation rules.
    ///
    /// This method checks the field's value for compliance with the configured validation operators,
    /// such as required status, minimum and maximum length, pattern matching, and custom validation logic.
    /// It automatically clears any existing errors and repopulates the `errors` array based on the result
    /// of each validation rule. If the field is not required and empty, validation is skipped and no errors are added.
    /// Otherwise, errors are appended for each rule that the value fails to satisfy.
    ///
    /// - Important: This method is called automatically whenever the value changes, but may also be
    ///   called manually to force revalidation.
    ///
    /// - SeeAlso: `errors`, `isValid`, `FormifyOperator`, `FormifyError`
    private mutating func validate() {
        errors = []

        if !isRequired && value.isEmpty {
            return
        }

        if isRequired && value.isEmpty {
            errors.append(.required)
            return
        }

        if let minLength, value.count < minLength {
            errors.append(.minLength(value.count))
        }

        if let maxLength, value.count > maxLength {
            errors.append(.maxLength(value.count))
        }

        if let customHandler, !customHandler(value) {
            errors.append(.custom)
        }

        if let pattern, let regex = try? Regex(pattern), (try? regex.wholeMatch(in: value)) == nil {
            errors.append(.pattern)
        }
    }
}

// MARK: Collection

public extension Collection where Element == FormifyField {
    /// Indicates whether the form field currently meets all of its validation requirements.
    ///
    /// - Returns: `true` if the field passes all configured validation rules (such as required, length, pattern, and custom validation).
    ///   If the field is required but empty, returns `false`. Otherwise, returns `true` if the `errors` array is empty.
    /// - Note: This property is automatically updated whenever the field's value changes.
    /// - SeeAlso: `errors`, `isRequired`
    var isValid: Bool {
        filter({ $0.errors.isEmpty }).isEmpty
    }
}
