import Foundation

public struct Instructions: Sendable, Copyable, SendableMetatype, InstructionsRepresentable {

    @_spi(Internal)
    public struct Text: Sendable, Equatable {
        @_spi(Internal)
        public let value: String

        @_spi(Internal)
        public init(value: String) {
            self.value = value
        }
    }

    @_spi(Internal)
    public struct Image: Sendable, Equatable {
        @_spi(Internal)
        public enum Source: Sendable, Equatable {
            case base64(data: String, mediaType: String)
            case url(URL)
        }
        @_spi(Internal)
        public let source: Source

        @_spi(Internal)
        public init(source: Source) {
            self.source = source
        }
    }

    @_spi(Internal)
    public enum Component: Sendable, Equatable {
        case text(Text)
        case image(Image)
    }

    @_spi(Internal)
    public let components: [Component]

    public init(_ content: String) {
        self.components = [.text(Text(value: content))]
    }

    @_spi(Internal)
    public init(components: [Component]) {
        self.components = components
    }

    public init(@InstructionsBuilder _ content: () throws -> Instructions) rethrows {
        let builtInstructions = try content()
        self.components = builtInstructions.components
    }

    public var instructionsRepresentation: Instructions {
        return self
    }
}
