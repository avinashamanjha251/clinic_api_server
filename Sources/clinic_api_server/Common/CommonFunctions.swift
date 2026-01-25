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
