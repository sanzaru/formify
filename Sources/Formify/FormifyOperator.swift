//
//  FormifyOperator.swift
//  Formify
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

/// An enumeration that defines various validation rules and operators 
/// used for form fields in the Formify framework.
///
/// `FormifyOperator` is typically used to specify constraints and validation
/// requirements for user input within forms. Each case represents a different
/// kind of validation or input modifier, some of which can be parameterized.
///
/// - Cases:
///   - `required`: Marks the field as mandatory and disallows empty values.
///   - `pattern(String)`: Requires the field value to match the given regular expression pattern.
///   - `minLength(Int)`: Ensures the field value has at least the specified number of characters.
///   - `maxLength(Int)`: Ensures the field value has at most the specified number of characters.
///   - `email`: Validates that the input conforms to an email address format.
///   - `phonenumber`: Validates that the input conforms to a phone number format.
///   - `urlNoScheme`: Validates the input as a URL without requiring a scheme (e.g., "www.example.com").
///   - `urlWithScheme`: Validates the input as a URL and requires a valid URL scheme (e.g., "https://example.com").
///   - `disableTrimming`: Disables automatic whitespace trimming of the field value before validation.
///   - `custom(FormifyCustomValidationHandler)`: Allows for custom validation logic via a user-supplied handler.
public enum FormifyOperator {
    case required
    case pattern(String)
    case minLength(Int)
    case maxLength(Int)
    case email
    case phonenumber
    case urlNoScheme
    case urlWithScheme
    case disableTrimming
    case custom(FormifyCustomValidationHandler)
}
