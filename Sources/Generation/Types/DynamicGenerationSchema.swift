
import Foundation


public struct DynamicGenerationSchema: Sendable, SendableMetatype {
    
    internal let name: String

    internal let description: String?

    internal let schemaType: SchemaType

    internal let representNilExplicitlyInGeneratedContent: Bool
    
    // MARK: - Nested Types
    
    internal indirect enum SchemaType: Sendable {
        case object(properties: [Property])
        case array(element: DynamicGenerationSchema, minItems: Int?, maxItems: Int?)
        case reference(to: String)
        case anyOf([DynamicGenerationSchema])
        case generic(type: any Generable.Type, guides: [AnyGenerationGuide])
    }
    
    public init(name: String, description: String? = nil, properties: [DynamicGenerationSchema.Property]) {
        self.name = name
        self.description = description
        self.schemaType = .object(properties: properties)
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    public init(arrayOf itemSchema: DynamicGenerationSchema, minimumElements: Int? = nil, maximumElements: Int? = nil) {
        self.name = "Array"
        self.description = nil
        self.schemaType = .array(
            element: itemSchema,
            minItems: minimumElements,
            maxItems: maximumElements
        )
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    public init(referenceTo name: String) {
        self.name = name
        self.description = nil
        self.schemaType = .reference(to: name)
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    public init(name: String, description: String? = nil, anyOf: [DynamicGenerationSchema]) {
        self.name = name
        self.description = description
        self.schemaType = .anyOf(anyOf)
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    public init(name: String, description: String? = nil, anyOf choices: [String]) {
        self.name = name
        self.description = description

        // Create DynamicGenerationSchema for each choice
        let schemas = choices.map { value in
            DynamicGenerationSchema(
                name: value,
                description: nil,
                schemaType: .generic(
                    type: String.self,
                    guides: [AnyGenerationGuide(GenerationGuide<String>.constant(value))]
                )
            )
        }
        self.schemaType = .anyOf(schemas)
        self.representNilExplicitlyInGeneratedContent = false
    }

    public init<Value>(type: Value.Type, guides: [GenerationGuide<Value>] = []) where Value: Generable {
        self.name = String(describing: type)
        self.description = nil
        let anyGuides = guides.map { AnyGenerationGuide($0) }
        self.schemaType = .generic(type: type, guides: anyGuides)
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    /// Creates an object schema that controls how nil properties are represented.
    ///
    /// When `representNilExplicitlyInGeneratedContent` is `true`, the model will produce
    /// a property with a null value. When `false`, nil properties are omitted entirely.
    public init(
        name: String,
        description: String? = nil,
        representNilExplicitlyInGeneratedContent explicitNil: Bool,
        properties: [DynamicGenerationSchema.Property]
    ) {
        self.name = name
        self.description = description
        self.schemaType = .object(properties: properties)
        self.representNilExplicitlyInGeneratedContent = explicitNil
    }

    /// Creates a null schema.
    public static var null: DynamicGenerationSchema {
        DynamicGenerationSchema(name: "null", description: nil, schemaType: .generic(type: String.self, guides: []))
    }

    // Internal init for creating resolved schemas
    internal init(name: String, description: String?, schemaType: SchemaType) {
        self.name = name
        self.description = description
        self.schemaType = schemaType
        self.representNilExplicitlyInGeneratedContent = false
    }
    
    public struct Property: Sendable, SendableMetatype {
        internal let name: String
        
        internal let description: String?
        
        internal let schema: DynamicGenerationSchema
        
        internal let isOptional: Bool
        
        public init(name: String, description: String? = nil, schema: DynamicGenerationSchema, isOptional: Bool = false) {
            self.name = name
            self.description = description
            self.schema = schema
            self.isOptional = isOptional
        }
    }
}

