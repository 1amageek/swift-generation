import Foundation

extension GeneratedContent: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(self.jsonString)
    }
}

extension GeneratedContent: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(self.jsonString)
    }
}

extension GenerationID {
    public var instructionsRepresentation: Instructions {
        return Instructions("A unique identifier: \(self.description)")
    }

    public var promptRepresentation: Prompt {
        return Prompt(self.description)
    }
}
