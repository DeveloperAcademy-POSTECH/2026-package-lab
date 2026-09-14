import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// 실제 코드 생성 로직을 작성


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
            return []
        }

        let propertyNames = structDeclaration.memberBlock.members
            .compactMap { member -> String? in
                guard let variable =
                    member.decl.as(VariableDeclSyntax.self),
                    variable.bindings.count == 1,
                    let binding = variable.bindings.first,
                    binding.accessorBlock == nil,
                    let identifier =
                        binding.pattern.as(IdentifierPatternSyntax.self)
                else {
                    return nil
                }

                let shouldSkip = variable.attributes.contains { element in
                    guard case .attribute(let attribute) = element else {
                        return false
                    }

                    return attribute.attributeName.trimmedDescription
                        == "SkipEquatable"
                }

                return shouldSkip ? nil : identifier.identifier.text
            }

        let comparison = propertyNames
            .map { "lhs.\($0) == rhs.\($0)" }
            .joined(separator: " &&\n")

        return [
            try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): Swift.Equatable {
                    static func == (
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
