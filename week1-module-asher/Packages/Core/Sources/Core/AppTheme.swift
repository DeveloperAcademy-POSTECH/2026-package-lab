import SwiftUI

/// 모든 기능 패키지가 Core를 사용한다는 것을 보여 주는 공용 디자인 토큰입니다.
public enum AppTheme {
    public static let accent = Color.indigo
    public static let background = Color.indigo.opacity(0.08)
    public static let card = Color(uiColor: .secondarySystemBackground)
}
