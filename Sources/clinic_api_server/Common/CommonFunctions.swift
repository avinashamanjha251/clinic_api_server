//
//  CommonFunctions.swift
//  clinic_api_server
//
//  Created by Avinash Aman on 25/01/26.
//


import Foundation
import CryptoSwift
import Vapor

class CommonFunctions {
    
    //MARK:- FOR ENCRYPTION_DECRYPTION
    //=================================
    static func encryptParams(data: String) throws -> String {
        guard let encryptionKey = Environment.get(environmentKey: .ENCRYPTION_KEY) else {
            throw Abort(.internalServerError, reason: "ENCRYPTION_KEY not set")
        }
        var encryptedData = ""
        let keys = encryptionKey
        do {
            let aes = try AES(key: keys, iv: keys)
            let ciphertext = try aes.encrypt(Array(data.utf8))
            encryptedData = ciphertext.toBase64()
        } catch {
            print(error)
        }
        return encryptedData
    }
    
    static func decryptData(data: String) throws -> Data {
        guard let encryptionKey = Environment.get(environmentKey: .ENCRYPTION_KEY) else {
            throw Abort(.internalServerError, reason: "ENCRYPTION_KEY not set")
        }
        var decryptValue = Data()
        let keys = encryptionKey
        do {
            let aes = try AES(key: keys, iv: keys)
            let dcrypt = try data.decryptBase64(cipher: aes)
            let datas = Data(dcrypt)
            decryptValue = datas
        } catch {
            print(error)
        }
        return decryptValue
    }
    
}

extension Date {
    
    // MARK:- DATE FORMAT ENUM
    //==========================
    enum DateFormat : String {
        case ddMMyyyy = "ddMMyyyy"
    }
}

extension Date {
    func toMillis() -> Double {
        return Double(self.timeIntervalSince1970 * 1000).rounded()
    }
}

extension String {
    
    func toDate(format: Date.DateFormat,
                timeZone: TimeZone = TimeZone.current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = .autoupdatingCurrent
        let date = dateFormatter.date(from: self)
        return date
    }
    
    ///Converts a given Date into String based on the date format and timezone provided
    func toDateString(inFormat: Date.DateFormat,
                      outFormat: Date.DateFormat,
                      timeZone: TimeZone = TimeZone.current) -> String {
        let date = self.toDate(format: inFormat) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.dateFormat = outFormat.rawValue
        let finalString = dateFormatter.string(from: date)
        return finalString
    }
}
