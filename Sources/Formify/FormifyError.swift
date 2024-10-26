//
//  FormifyError.swift
//  Formify
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

public enum FormifyError: Error, Hashable {
    case required
    case pattern
    case minLength(Int)
    case maxLength(Int)
    case custom
}
