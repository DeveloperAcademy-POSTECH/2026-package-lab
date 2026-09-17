// 사용자가 보게 될 API 선언

@attached(extension, conformances: Equatable, names: named(==))
public macro Equatable() = #externalMacro(
    module: "ViewEquatableMacrosMacros",
    type: "EquatableMacro"
)

@attached(peer, names: arbitrary)
public macro SkipEquatable() = #externalMacro(
    module: "ViewEquatableMacrosMacros",
    type: "SkipEquatableMacro"
)
