import Foundation

/// 가짜 비즈니스 로직의 실행을 Xcode 콘솔에서 확인하기 위한 간단한 공용 로거입니다.
public enum Logger {
    public static func log(_ message: String, category: String) {
        print("[\(category)] \(message)")
    }
}
