//
//  FormifyDefaultPattern.swift
//  Formify
//
//  Created by Martin Albrecht on 16.10.24.
//

enum FormifyDefaultPattern: String {
    case email = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    case phone = "\\+?([0-9]{1,3})?[-.\\s]?(\\(?[0-9]{1,4}\\)?)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{0,9}"
    case urlWithScheme = "[a-zA-Z]+:\\/\\/{1}[a-zA-Z0-9_\\-.?=&\\/]+"
    case urlNoScheme = "[a-zA-Z0-9-_.?=&\\/]+"
}
