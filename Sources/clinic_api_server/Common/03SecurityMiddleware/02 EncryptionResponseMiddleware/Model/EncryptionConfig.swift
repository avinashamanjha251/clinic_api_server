import Foundation

struct EncryptionConfig {
    let encryptedPaths: [String]
    let excludedPaths: [String]
    
    static let `default` = EncryptionConfig(
        encryptedPaths: ["/api"],
        excludedPaths: ["/health", "/metrics"]
    )
}
