import SwiftUI

struct FilterCard: View {
    let icon: String
    let title: String
    let value: String
    let bodyNumber: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.semibold))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)

            BodyNumberBadge(number: bodyNumber)
        }
        .padding(16)
        .bodyEvaluationBackground(number: bodyNumber)
    }
}

struct BodyNumberBadge: View {
    let number: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("body")
                .font(.caption2)
            Text("#\(number)")
                .font(.caption.monospacedDigit().bold())
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.orange.opacity(0.12), in: Capsule())
    }
}

enum BodyEvaluationProbe {
    static func record(_ viewName: String) -> Int {
        let number = Int.random(in: 100...999)
        print("[body 계산] \(viewName) #\(number)")
        return number
    }
}

private struct BodyEvaluationBackgroundModifier: ViewModifier {
    let number: Int

    private var color: Color {
        Color(
            hue: Double(number % 360) / 360,
            saturation: 0.35,
            brightness: 0.96
        )
    }

    func body(content: Content) -> some View {
        content
            .background(color, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.8), lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.2), value: number)
    }
}

extension View {
    func bodyEvaluationBackground(number: Int) -> some View {
        modifier(BodyEvaluationBackgroundModifier(number: number))
    }
}
