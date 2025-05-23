//
//  FormifyField.swift
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

import Foundation

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

    public var isValid: Bool {
        isRequired && value.isEmpty ? false : errors.isEmpty
    }

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
    var isValid: Bool {
        filter({ $0.errors.isEmpty }).isEmpty
    }
}
