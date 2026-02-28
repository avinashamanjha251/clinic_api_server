//
//  AdminRegistrationError.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 26/01/26.
//

import Foundation

enum AdminRegistrationError {
    static var nameNotAllowedToBeEmpty: String { "Name is required and cannot be empty" }
    static var nameTooShort: String { "Name must be at least 2 characters long" }
    static var nameTooLong: String { "Name cannot exceed 100 characters" }
    
    static var usernameNotAllowedToBeEmpty: String { "Username is required and cannot be empty" }
    static var usernameTooShort: String { "Username must be at least 3 characters long" }
    static var usernameTooLong: String { "Username cannot exceed 50 characters" }
    static var usernameInvalidFormat: String { "Username can only contain letters, numbers, and underscores" }
    
    static var passwordNotAllowedToBeEmpty: String { "Password is required and cannot be empty" }
    static var passwordTooShort: String { "Password must be at least 8 characters long" }
    static var passwordTooLong: String { "Password cannot exceed 100 characters" }
    static var passwordInvalidFormat: String { "Password must be at least 8 characters long, and contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character" }
}
