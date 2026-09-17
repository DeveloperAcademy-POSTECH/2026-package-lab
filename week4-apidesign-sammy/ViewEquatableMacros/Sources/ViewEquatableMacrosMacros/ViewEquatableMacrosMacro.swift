import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

private enum EquatableMacroDiagnostic: DiagnosticMessage {
    case requiresStruct
    
    var message: String {
        "@Equatable macro can only be applied to a struct"
    }
    
    var diagnosticID: MessageID {
        MessageID(
            domain: "ViewEquatableMacros",
            id: "requiresStruct"
        )
    }
    
    var severity: DiagnosticSeverity {
        .error
    }
}

private extension VariableDeclSyntax {
    var hasSkipEquatableAttribute: Bool {
        attributes.contains { element in
            guard case .attribute(let attribute) = element else {
                return false
            }
            
            return attribute.attributeName.trimmedDescription == "SkipEquatable"
        }
    }
    
    var isTypeProperty: Bool {
        modifiers.contains { modifier in
            let modifierName = modifier.name.text
            
            return modifierName == "static" || modifierName == "class"
        }
    }
}

private extension PatternBindingSyntax {
    var isStoredProperty: Bool {
        guard let accessorBlock else {
            // accessor 가 없으면 일반 stored property
            return true
        }
        
        switch accessorBlock.accessors {
        case .getter:
            // computed property인 경우
            return false
            
        case .accessors(let accessors):
            // didSet/willSet 만 있는 stored property
            return accessors.allSatisfy { accessor in
                let specifier = accessor.accessorSpecifier.text
                
                return specifier == "willSet" || specifier == "didSet"
            }
            
        @unknown default:
            return false
        }
        

        
    }
}

private extension StructDeclSyntax {
    var equalityAccessModifier: String {
        let accessLevels = [
            "public",
            "package",
            "internal",
            "fileprivate",
            "private",
        ]
        
        guard let modifier = modifiers.first(
            where: { accessLevels.contains($0.name.text) }
        ) else {
            return ""
        }
        
        return "\(modifier.name.text) "
    }
}

public struct EquatableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDeclaration =
            declaration.as(StructDeclSyntax.self)
        else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: EquatableMacroDiagnostic.requiresStruct
                )
            )
            
            return []
        }

        let propertyNames = structDeclaration.memberBlock.members
            .flatMap { member -> [String] in
                guard let variable = member.decl.as(VariableDeclSyntax.self) else { return [] }
                
                guard !variable.hasSkipEquatableAttribute else { return [] }
                
                guard !variable.isTypeProperty else { return [] }
                
                return variable.bindings.compactMap { binding in
                    guard binding.isStoredProperty else { return nil }
                    
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
                    
                    return identifier.identifier.text
                }
                    
            }
        let comparison: String
        
        if propertyNames.isEmpty {
            comparison = "true"
        } else {
            comparison = propertyNames
                .map { "lhs.\($0) == rhs.\($0)" }
                .joined(separator: " &&\n")
        }
        
        let equalityAccessModifier = structDeclaration.equalityAccessModifier
        
        return [
            try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): Swift.Equatable {
                    \(raw: equalityAccessModifier)static func == (
                        lhs: Self,
                        rhs: Self
                    ) -> Bool {
                        \(raw: comparison)
                    }
                }
                """
            )
        ]
    }
}

public struct SkipEquatableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct ViewEquatableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EquatableMacro.self,
        SkipEquatableMacro.self
    ]
}
