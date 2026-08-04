import Foundation

/// Core의 공개 API이므로 모듈 경계를 넘어 전달할 수 있는 값 타입입니다.
public struct SharedModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let detail: String

    public init(id: UUID = UUID(), title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}
