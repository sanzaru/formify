//
//  FormifyOperator.swift
//  Formify
//
//  This file is part of the Formify Swift library: https://github.com/sanzaru/formify
//  Created by Martin Albrecht on 15.10.24.
//  Licensed under Apache License v2.0
//

public enum FormifyOperator {
    case required
    case pattern(String)
    case minLength(Int)
    case maxLength(Int)
    case email
    case phonenumber
}
