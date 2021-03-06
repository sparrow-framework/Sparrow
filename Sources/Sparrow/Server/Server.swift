@_exported import Zewo

extension Server {
    /// Creates a new HTTP server
    public convenience init<C>(
        router: Router<C>,
        header: String? = nil,
        parserBufferSize: Int = 4096,
        serializerBufferSize: Int = 4096,
        parseTimeout: Duration = 5.minutes,
        serializeTimeout: Duration = 5.minutes,
        closeConnectionTimeout: Duration = 1.minute
    ) {
        self.init(
            header: header ?? Server.defaultHeader,
            parserBufferSize: parserBufferSize,
            serializerBufferSize: serializerBufferSize,
            parseTimeout: parseTimeout,
            serializeTimeout: serializeTimeout,
            closeConnectionTimeout: closeConnectionTimeout,
            respond: router.respond
        )
    }
    
    private static var defaultHeader: String {
        var header = "\n"
        header += "      _____                                          \n"
        header += "     / ___/ ____   ____ _ _____ _____ ____  _      __\n"
        header += "     \\__ \\ / __ \\ / __ `// ___// ___// __ \\| | /| / /\n"
        header += "    ___/ // /_/ // /_/ // /   / /   / /_/ /| |/ |/ / \n"
        header += "   /____// .___/ \\__,_//_/   /_/    \\____/ |__/|__/  \n"
        header += "        /_/                                          \n"
        header += "-------------------------------------------------------\n"
        return header
    }
}
