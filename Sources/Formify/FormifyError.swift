//
//  FormifyError.swift
//  Formify
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

/// An enumeration representing validation errors for form inputs in the Formify library.
/// 
/// `FormifyError` is used to describe the various kinds of validation failures that can occur
/// when validating form fields. Each case represents a different validation rule that may fail.
/// 
/// - `required`: Indicates that a required field was left empty.
/// - `pattern`: Indicates that the input does not match a required regular expression pattern.
/// - `minLength(Int)`: Indicates that the input does not meet the minimum required length. The associated value is the required minimum length.
/// - `maxLength(Int)`: Indicates that the input exceeds the maximum allowed length. The associated value is the maximum allowed length.
/// - `custom`: Indicates a custom validation error, for rules not covered by other cases.
public enum FormifyError: Error, Hashable {
    case required
    case pattern
    case minLength(Int)
    case maxLength(Int)
    case custom
}
