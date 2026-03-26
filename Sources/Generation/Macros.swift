// MARK: - @Generable Macro
// Conforms a type to Generable protocol
@attached(extension, conformances: Generable, names: named(init(_:)), named(generatedContent))
@attached(member, names: arbitrary)
public macro Generable(description: String? = nil) = #externalMacro(module: "GenerationMacrosImpl", type: "GenerableMacro")

@attached(extension, conformances: Generable, names: named(init(_:)), named(generatedContent))
@attached(member, names: arbitrary)
public macro Generable(
    description: String? = nil,
    representNilExplicitlyInGeneratedContent: Bool
) = #externalMacro(module: "GenerationMacrosImpl", type: "GenerableMacro")

// MARK: - @Guide Macros
// Allows for influencing the allowed values of properties of a generable type

@attached(peer)
public macro Guide(description: String) = #externalMacro(module: "GenerationMacrosImpl", type: "GuideMacro")

@attached(peer)
public macro Guide<T>(description: String? = nil, _ guides: GenerationGuide<T>...) = #externalMacro(module: "GenerationMacrosImpl", type: "GuideMacro") where T : Generable

@attached(peer)
public macro Guide<RegexOutput>(
    description: String? = nil,
    _ guides: Regex<RegexOutput>
) = #externalMacro(module: "GenerationMacrosImpl", type: "GuideMacro")

public enum GuideConstraint {
    case range(ClosedRange<Int>)
    case count(Int)
    case enumValues([String])
    case pattern(String)
}
