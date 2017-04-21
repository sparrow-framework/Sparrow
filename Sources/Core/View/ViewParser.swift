import Venice

public enum ViewParserError : Error {
    case invalidInput
}

public enum ViewParserResult {
    case `continue`
    case done(View)
}

public protocol ViewParser {
    associatedtype Options: OptionSet
    init(options: Options)

    var options: Options { get }

    /// Use `parse` for incremental parsing. `parse` should be called
    /// many times with partial chunks of the source data. Send an empty buffer
    /// to signal you don't have any more chunks to send.
    ///
    /// The following example shows how you can implement incremental parsing:
    ///
    ///     let parser = JSONParser()
    ///
    ///     while true {
    ///         let buffer = try stream.read(upTo: bufferSize)
    ///         if let json = try parser.parse(buffer) {
    ///             return json
    ///         }
    ///     }
    ///
    /// - parameter buffer: `UnsafeBufferPointer` that points to the chunk
    ///   used to update the state of the parser.
    ///
    /// - throws: Throws when `buffer` is an invalid input for the given parser.
    ///
    /// - returns: Returns `nil` if the parser was not able to produce a result yet.
    ///   Otherwise returns the parsed value.
    @discardableResult func parse(buffer: UnsafeBufferPointer<Byte>) throws -> ViewParserResult
    func finish() throws -> View
}

extension ViewParser {
    public func finish() throws -> View {

        guard case .done(let view) = try parse(buffer: UnsafeBufferPointer()) else {
            throw ViewParserError.invalidInput
        }

        return view
    }

    @discardableResult func parse(buffer: UnsafeBufferPointer<Byte>) throws -> View {
        guard case .done(let view) = try parse(buffer: buffer) else {
            throw ViewParserError.invalidInput
        }

        return view
    }

    public func parse(bytes: [Byte]) throws -> View {
        return try bytes.withUnsafeBufferPointer { buffer in
            try parse(buffer: buffer)
        }
    }

    public func parse(data: DataRepresentable) throws -> View {
        return try parse(bytes: data.bytes)
    }

    public func parse(stream: InputStream, bufferSize: Int = 4096, deadline: Deadline) throws -> View {
        let buffer = UnsafeMutableBufferPointer<Byte>(capacity: bufferSize)
        defer { buffer.deallocate(capacity: bufferSize) }

        while true {
            let readBuffer = try stream.read(into: buffer, deadline: deadline)

            switch try parse(buffer: readBuffer) {
            case .continue:
                continue
            case .done(let view):
                return view
            }
        }
    }
}

extension ViewParser {
    public static func parse(buffer: UnsafeBufferPointer<Byte>, options: Options = []) throws -> View {
        let parser = Self(options: options)

        guard case .done(let view) = try parser.parse(buffer: buffer) else {
            throw ViewParserError.invalidInput
        }

        return view
    }

    public static func parse(stream: InputStream, bufferSize: Int = 4096, options: Options, deadline: Deadline) throws -> View {
        let parser = Self(options: options)

        return try parser.parse(stream: stream, bufferSize: bufferSize, deadline: deadline)
    }

    public static func parse(bytes: [Byte], options: Options = []) throws -> View {
        return try bytes.withUnsafeBufferPointer {
            try self.parse(buffer: $0, options: options)
        }
    }
}
