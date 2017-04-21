import PackageDescription

let package = Package(
    name: "Sparrow",
    targets: [

        Target(
            name: "Sparrow",
            dependencies: [
                "POSIX",
                "Core",
                "OpenSSL",
                "HTTP",
                "IP",
                "TCP",
            ]
        ),

        Target(name: "Core"),
        Target(name: "POSIX", dependencies: ["Core"]),
        Target(name: "OpenSSL", dependencies: ["Core"]),
        Target(name: "HTTP", dependencies: ["Core"]),
        Target(name: "IP", dependencies: ["Core", "POSIX"]),
        Target(name: "TCP", dependencies: ["IP", "OpenSSL", "POSIX"]),
        ],
    dependencies: [
        .Package(url: "https://github.com/formbound/Venice.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/CDNS.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/COpenSSL", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/CPOSIX.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0),
        .Package(url: "https://github.com/formbound/Powerline.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/CYAJL.git", majorVersion: 0)
        ]
)
