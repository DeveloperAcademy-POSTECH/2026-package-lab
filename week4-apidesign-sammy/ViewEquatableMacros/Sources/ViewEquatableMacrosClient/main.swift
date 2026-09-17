import ViewEquatableMacros

struct Handler {
    let send: () -> Void
}

@Equatable
struct Example {
    let title: String

    @SkipEquatable
    let handler: Handler
}

let first = Example(
    title: "제주도",
    handler: Handler(send: {})
)

let second = Example(
    title: "제주도",
    handler: Handler(send: {})
)

print(first == second)
