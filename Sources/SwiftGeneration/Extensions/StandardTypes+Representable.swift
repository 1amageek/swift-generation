import Foundation

// MARK: - Array

extension Array: InstructionsRepresentable where Element: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        let components = self.flatMap { $0.instructionsRepresentation.components }
        return Instructions(components: components)
    }
}

extension Array: PromptRepresentable where Element: PromptRepresentable {
    public var promptRepresentation: Prompt {
        let components = self.flatMap { $0.promptRepresentation.components }
        return Prompt(components: components)
    }
}

// MARK: - Bool

extension Bool: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(self ? "true" : "false")
    }
}

extension Bool: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(self ? "true" : "false")
    }
}

// MARK: - Int

extension Int: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(String(self))
    }
}

extension Int: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(String(self))
    }
}

// MARK: - Float

extension Float: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(String(self))
    }
}

extension Float: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(String(self))
    }
}

// MARK: - Double

extension Double: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(String(self))
    }
}

extension Double: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(String(self))
    }
}

// MARK: - Decimal

extension Decimal: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(String(describing: self))
    }
}

extension Decimal: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(String(describing: self))
    }
}

// MARK: - UUID

extension UUID: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(self.uuidString)
    }
}

extension UUID: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(self.uuidString)
    }
}

// MARK: - Date

extension Date: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return Instructions(formatter.string(from: self))
    }
}

extension Date: PromptRepresentable {
    public var promptRepresentation: Prompt {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return Prompt(formatter.string(from: self))
    }
}

// MARK: - URL

extension URL: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(self.absoluteString)
    }
}

extension URL: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(self.absoluteString)
    }
}

// MARK: - Never

extension Never: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        fatalError("Never has no instances")
    }
}

extension Never: PromptRepresentable {
    public var promptRepresentation: Prompt {
        fatalError("Never has no instances")
    }
}
