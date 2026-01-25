// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "clinic_api_server",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🍃 MongoDB driver for Vapor
        .package(url: "https://github.com/mongodb/mongodb-vapor.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.9.0"),
        .package(url: "https://github.com/Mikroservices/Smtp.git", from: "3.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "clinic_api_server",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MongoDBVapor", package: "mongodb-vapor"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "Smtp", package: "Smtp"),
            ]
        ),
    ]
)
