# 1. LocalizationGuard 만들게 된 이유

챌린지 4에서 앱에 **로컬라이제이션**을 적용했습니다. **String Catalog에 문구를 모두 등록**하고 빌드를 했는데요!
일부 문구는 한국어 그대로 남아 있었습니다.

String Catalog에 문구를 빠뜨린 것도 아니고, 뭐가 문제지? 하고 찾아보았는데!

직접 만든 컴포넌트가 일반 `String`을 받는 경우였습니다.

```swift
struct SettingsRow: View {
    let title: String
}
```

이 컴포넌트에 아래처럼 문자열을 넘기면,

```swift
SettingsRow(title: "알림")
```

String Catalog에 `"알림"`이 있더라도 SwiftUI가 자동으로 번역하지 않을 수 있습니다.

<br>

이런 문자열을 찾으려면 프로젝트의 Swift 파일을 하나씩 열어 직접 확인해야 합니다🤬

```swift
title: "설정"
label: "자동 밝기"
return "알림"
errorMessage = "설정을 저장하지 못했습니다."
```

프로젝트가 커질수록 놓치는 문구는 많아지고, 번역이 제대로 적용됐는지 확인하는 데도 시간이 더 듭니다.

<br>

그래서 이런 질문에서 시작했습니다.

> Swift 코드와 String Catalog를 자동으로 비교해서, 번역이 빠진 문자열을 빌드할 때 알려줄 수 없을까?

처음에는 누락을 발견하면 에러로 보여 주는 방식을 생각했습니다.
그런데 모든 사용자 노출 문자열이 반드시 번역 대상인 것은 아니었습니다. 브랜드명, 약어, 디버그용 문구처럼 의도적으로 번역하지 않는 문자열도 있을 수 있습니다.

그래서 빌드를 막는 에러보다, 개발자가 확인하고 판단할 수 있는 **경고**가 더 적절하다고 생각했습니다.

**경고로 출력하면 두 가지 장점**이 있습니다.

1. 빌드는 계속 진행할 수 있습니다.
2. Xcode에서 경고를 클릭하면 해당 문자열이 작성된 코드 줄로 바로 이동할 수 있습니다.

LocalizationGuard는 파일 경로, 줄 번호, 열 번호를 포함한 Xcode 경고 형식으로 결과를 출력합니다. 그래서 Issue navigator에서 경고를 선택하면 문제가 발견된 코드 위치를 바로 확인할 수 있습니다.

---

# 2. LocalizationGuard 만들어보려는데

LocalizationGuard는 Swift 코드와 String Catalog를 비교해서 로컬라이제이션 문제를 찾아주는 Swift 패키지입니다.
패키지는 크게 두 부분으로 구성되어 있습니다.

```
LocalizationGuard
├── CLI
└── Build Tool Plugin
```

CLI는 실제 검사를 담당하고, 플러그인은 Xcode 빌드 과정에서 CLI를 자동으로 실행합니다.

<br>

```
앱 빌드 시작
→ Xcode가 Plugin 실행
→ Plugin이 CLI 실행
→ CLI가 Swift 파일과 String Catalog 검사
→ CLI가 warning 또는 note 출력
→ Xcode가 결과 표시
```

---

## 2-1. CLI란 무엇인가

CLI는 Command Line Interface의 줄임말입니다.
터미널에서 명령어로 실행하는 프로그램을 뜻합니다.

LocalizationGuard의 CLI 이름은 `LocalizationGuardCLI`입니다.

<br>

CLI는 프로젝트 경로를 받은 뒤 다음 작업을 수행합니다.

1. 프로젝트 안의 Swift 파일을 찾습니다.
2. 프로젝트 안의 `.xcstrings` 파일을 찾습니다.
3. Swift 코드에서 사용자에게 보일 수 있는 문자열을 찾습니다.
4. String Catalog에 해당 키와 번역이 있는지 비교합니다.
5. Xcode가 이해할 수 있는 경고 형식으로 결과를 출력합니다.

CLI는 LocalizationGuard의 실제 검사 엔진인 거조!!!!!!!!!!

---

## 2-2. 플러그인이란 무엇인가

플러그인은 Xcode의 빌드 과정에 기능을 연결하는 도구입니다.
`LocalizationGuardPlugin`은 “앱을 빌드할 때 LocalizationGuardCLI도 실행해 달라”고 Xcode에 전달하는 역할을 합니다.

<br>

`Run Script Phase`로도 CLI를 빌드 과정에서 실행할 수 있습니다. 다만 Run Script Phase는 프로젝트마다 실행할 스크립트를 직접 설정해야 합니다.

LocalizationGuard는 여러 프로젝트에서 같은 방식으로 설치하고 사용할 수 있도록 Build Tool Plugin을 사용했습니다. 플러그인을 앱 타깃에 연결하면, 평소처럼 `⌘B`나 `⌘R`을 누를 때 자동으로 검사가 실행됩니다.

```
⌘B 또는 ⌘R
→ LocalizationGuardPlugin 실행
→ LocalizationGuardCLI 실행
→ 검사 결과가 Xcode 경고로 표시
```

플러그인은 검사를 직접 하지 않습니다. 검사 로직은 CLI에 두고, 플러그인은 Xcode와 CLI를 연결하는 역할만 맡았습니다.

그래서 CLI는 터미널에서도 실행할 수 있고, Xcode에서는 플러그인을 통해 자동 실행할 수 있습니다.

---

## 2-3. 왜 import 없이 사용할 수 있는가

일반적인 라이브러리는 앱 코드에서 기능을 호출하므로 `import`가 필요합니다.

```swift
import Foundation
import SwiftUI
```

하지만 LocalizationGuard는 앱이 실행되는 동안 동작하는 라이브러리가 아닙니다.

앱이 빌드되는 동안만 실행됩니다.

```
앱 실행 전
→ 빌드 단계에서 LocalizationGuard 검사
→ 결과를 Xcode에 전달
→ 앱 실행
```

그래서 앱 코드에 아래처럼 작성할 필요가 없습니다.

```swift
import LocalizationGuard
```

LocalizationGuard는 앱 화면이나 앱 실행 로직에 포함되지 않고, 개발 과정의 빌드 단계에서만 동작합니다.

---

# 3. LocalizationGuard 자세히 보자

LocalizationGuard는 역할별로 파일을 나눴습니다.

<img width="448" height="694" alt="image" src="https://github.com/user-attachments/assets/1d75fc45-1b64-4962-8c52-97bdd8d59f98" />


---

## 3-1. Package.swift

`Package.swift`은 Swift 패키지의 시작점입니다.

이 파일에서 패키지가 제공하는 결과물을 정의합니다.

```swift
.executable(
    name: "LocalizationGuardCLI",
    targets: ["LocalizationGuardCLI"]
)

.plugin(
    name: "LocalizationGuardPlugin",
    targets: ["LocalizationGuardPlugin"]
)
```

첫 번째는 실제 검사기인 CLI입니다.

두 번째는 Xcode 빌드 과정에서 CLI를 실행하는 플러그인입니다.

---

## 3-2. main.swift

`main.swift`은 CLI의 시작점입니다.

터미널이나 플러그인에서 프로젝트 경로를 전달받고, 설정을 읽은 뒤 검사를 시작합니다.

```
프로젝트 경로 받기
→ 설정 읽기
→ 프로젝트 스캔
→ 경고 출력
```

---

## 3-3. Settings.swift

`Settings.swift`은 `.localizationguard.json` 설정 파일을 읽습니다.

`sourceLanguages`는 Swift 코드에서 원문 문자열로 탐지할 언어입니다.
`requiredLanguages`는 String Catalog에 번역이 준비되어 있어야 하는 언어입니다.

<br>

예를 들어 한국어를 원문으로 쓰고, 영어와 일본어 번역도 제공해야 하는 앱이라면 아래처럼 설정할 수 있습니다.

```json
{
  "sourceLanguages": ["ko"],
  "requiredLanguages": ["ko", "en", "ja"]
}
```

이 경우 LocalizationGuard는 한국어 문자열을 찾아 String Catalog에 등록됐는지 검사합니다. 그리고 각 항목에 영어와 일본어 번역이 있는지도 확인합니다.


`requiredLanguages`는 카탈로그 어디에도 아직 없는 언어도 검사 대상으로 만들 때 필요합니다.
예를 들어 현재 카탈로그에 한국어와 영어만 있다면, 일본어가 빠졌다는 사실은 자동으로 알 수 없습니다.

```json
{
  "requiredLanguages": ["ko", "en", "ja"]
}
```

처럼 일본어를 직접 지정하면, 일본어 번역이 없는 항목에 `Missing language` 경고가 표시됩니다.

---

## 3-4. ProjectScanner.swift

`ProjectScanner.swift`은 Swift 파일을 순회하며 문자열을 찾습니다.

현재는 Unicode 범위를 이용해 일반 문자열 리터럴을 넓게 탐지합니다. 이 방식은 SwiftUI의 자동 추출 API와 일반 `String` 경로를 구분하지 못합니다.

> [!WARNING]
> 일반 문자열 탐지 기능은 컴파일러가 String Catalog에 자동 추출하는 `Text`, `Button`, `String(localized:)` 등의 API까지 검사해 오탐이 발생할 수 있습니다. 자동 추출되지 않는 실제 UI 문자열만 찾을 수 있도록 현재 방식의 개선 방향을 검토하고 있습니다.

---

## 3-5. CatalogScanner.swift

`CatalogScanner.swift`은 `.xcstrings` 파일 내부를 읽습니다.
단순히 키가 있는지만 확인하는 것이 아니라, 언어별 번역 상태도 확인합니다.

<br>

예를 들어 한국어 원문과 영어 번역은 있지만 일본어 번역이 없는 경우입니다.
이 경우 `Missing language` 경고를 출력합니다.

---

## 3-6. Diagnostics.swift

`Diagnostics.swift`은 검사 결과를 Xcode 경고 형식으로 만듭니다.

예를 들어 아래처럼 출력합니다.

```
SettingsView.swift:24:18: warning:
Missing translation: String '通知' is missing from the String Catalog.
```

Xcode는 이 형식을 일반 컴파일러 경고처럼 읽습니다.
그래서 Issue navigator에서 경고를 클릭하면 해당 파일의 24번째 줄, 18번째 열로 바로 이동할 수 있습니다.

---

## 3-7. Plugin.swift

`Plugin.swift`은 Xcode가 CLI를 실행하도록 연결합니다.

```
Plugin
→ CLI야, 이 프로젝트를 검사해줘
CLI
→ Swift 파일과 String Catalog를 비교할게
```

플러그인 자체는 문자열을 검사하지 않고, CLI에 현재 프로젝트 경로를 전달합니다.
역할을 분리했기 때문에, 검사 로직은 CLI에 모으고 Xcode 연동은 플러그인에만 둘 수 있었습니다.

---

# 4. 현재 LocalizationGuard가 주는 경고 유형

현재는 네 종류의 warning과 하나의 summary note를 제공합니다.

> [!WARNING]
> `Missing translation`과 `Unknown localization key`는 컴파일러의 String Catalog 자동 추출 대상과 겹쳐 오탐이 발생할 수 있습니다. 자동 추출 대상과 실제로 누락될 수 있는 일반 `String` 경로를 구분하는 방향을 검토하고 있습니다.

## 4-1. Missing translation

코드에 사용자에게 보이는 한국어 문자열이 있지만, String Catalog에 없는 경우입니다.

<img width="1600" height="196" alt="image" src="https://github.com/user-attachments/assets/34926a76-430b-4786-a64d-5e81743637be" />

String Catalog에 해당 키를 추가하면 해결할 수 있습니다.

`Text(verbatim:)`은 번역하지 않는 문자열임을 명시하는 API이므로, 별도의 disable 주석까지 요구하지 않도록 개선할 예정입니다.

---

## 4-2. Unknown localization key

코드에서 명시적으로 사용한 로컬라이제이션 키가 String Catalog에 없는 경우입니다.

다만 `String(localized:)`처럼 컴파일러가 자동 추출하는 키는 일반적인 사용 흐름에서 String Catalog에 추가됩니다. 플러그인이 컴파일러의 자동 추출보다 먼저 실행되는 첫 빌드에는 일시적인 경고가 나올 수 있어, 이 진단도 재검토하고 있습니다.

<img width="1046" height="88" alt="image" src="https://github.com/user-attachments/assets/3dacf2c1-18be-4aa2-8f7f-60ee92a6363c" />

<img width="1782" height="378" alt="image" src="https://github.com/user-attachments/assets/425efe19-a579-4364-96e7-ed232b1abd7b" />

1. 실제 앱에서는 String Catalog에 같은 키를 추가하면 됩니다.

<img width="816" height="354" alt="image" src="https://github.com/user-attachments/assets/0c962bd7-2f64-4cd4-a180-64bcfa912aef" />


2. 코드의 키가 오타라면, Catalog에 이미 있는 올바른 키로 수정하면 됩니다!

```swift
String(localized: "코드 키 오타 수정")
```

---

## 4-3. Missing language

키는 존재하지만 특정 언어의 번역만 빠진 경우입니다.

<img width="1242" height="176" alt="image" src="https://github.com/user-attachments/assets/00d823a3-7817-4f38-b6b0-bbe556850fd6" />

<img width="1760" height="1194" alt="image" src="https://github.com/user-attachments/assets/d9ad1974-6ad0-4122-88e8-8c76c480ed0a" />


이 경고는 Swift 코드가 아니라 String Catalog 파일 위치로 연결됩니다. 현재는 정확히 비어 있는 언어 칸이 아니라 Catalog 파일 위치로 연결되며, 누락 항목을 바로 선택하는 기능은 개선이 필요합니다.

String Catalog 에디터에서도 언어별 번역 진행률을 확인할 수 있습니다. 이 진단은 `requiredLanguages`로 Catalog 전체에 아직 없는 언어까지 검사할 수 있다는 점을 제공하지만, 기존 에디터 기능과의 차별점은 더 검토하고 있습니다.

---

## 4-4. Localization summary

검사가 끝나면 전체 결과도 알려줍니다. 특정 코드의 문제를 알리는 경고가 아니라, 검사가 정상적으로 끝났는지와 전체 발견 개수를 알려주는 요약입니다.

이것까지 warning으로 출력하면 실제로 확인해야 할 번역 누락 경고와 섞여서 Issue navigator가 복잡해 보일 수 있자나요????

그래서 `Localization summary`는 `warning`이 아닌 `note`로 출력합니다.

<img width="2918" height="2024" alt="image" src="https://github.com/user-attachments/assets/b4e18ad5-f614-4bc7-acf1-86218af194c4" />


`note`는 Xcode의 Build log 또는 Report navigator에서 확인할 수 있습니다.

---

# 5. LocalizationGuard 사용 방법

Xcode에서 아래 주소로 패키지를 추가합니다.

```
https://github.com/dudwntjs/LocalizationGuard.git
```

<img width="2918" height="2024" alt="image" src="https://github.com/user-attachments/assets/c04ad4c2-e045-47e8-b222-5b147e6d976f" />


그다음 앱 타깃에 `LocalizationGuardPlugin`을 추가합니다.

<br>

아래 위치에서 연결됐는지 확인할 수 있습니다.

`Build Phases` → `Run Build Tool Plug-ins` → `LocalizationGuardPlugin`

<img width="2918" height="2024" alt="image" src="https://github.com/user-attachments/assets/31a9ee3f-8d76-4920-b870-263f7cb0722b" />

처음 연결했을 때 Xcode에서 신뢰 확인이 뜨면 `Trust & Enable`을 선택합니다.

<img width="2918" height="2024" alt="image" src="https://github.com/user-attachments/assets/2b0ba199-a0e6-4b45-b6d4-3fdab4a959ea" />


그 이후에는 평소처럼 빌드하면 됩니다.

빌드 과정에서 LocalizationGuard가 자동 실행되고, 결과가 Xcode 경고로 표시됩니다.


https://github.com/user-attachments/assets/63c37d34-9ada-46bf-85b0-354c4280ef6e


|    한국어(원문)   |    영어   |   일본어   |    Xcode    |
| :-------------: | :----------: | :----------: |:----------: |
| <img src = "https://github.com/user-attachments/assets/ca409584-cd5b-4e1f-8f89-eacbd310a872" width ="250"> | <img src = "https://github.com/user-attachments/assets/b1cf9007-ad40-493e-ab98-3689548ede5b" width ="250"> | <img src = "https://github.com/user-attachments/assets/4a044f5d-18b1-4669-b783-07b3433a1d22" width ="250"> | <img src = "https://github.com/user-attachments/assets/b9a417ce-7b84-4a7c-941e-db23d312b64b" width ="700"> |
|경고를 다 지우면~| <img src = "https://github.com/user-attachments/assets/ada24880-428c-417f-bfc4-453601a89e2f" width ="250"> | <img src = "https://github.com/user-attachments/assets/cd221718-4153-41ee-90ba-3ca1a3c6b2fe" width ="250"> | <img src = "https://github.com/user-attachments/assets/9aef61c0-3638-40ab-a5e8-cfeb36063b6f" width ="700"> |


---

# 6. LocalizationGuard 한계와 앞으로의 방향

## 6-1. 한계점 1: 현재 경고는 오탐이 될 수 있음

> [!WARNING]
> 현재 일반 문자열 탐지는 Swift 컴파일러가 String Catalog에 자동 추출하는 API와 겹칠 수 있습니다. 플러그인이 컴파일러의 자동 추출보다 먼저 실행되면, 첫 빌드에서만 일시적인 경고가 나올 수도 있습니다.

현재 방식은 문자열 리터럴을 정규식과 Unicode 범위로 넓게 찾습니다. 그래서 실제 UI 문구뿐 아니라 디버그 문구·식별자처럼 번역 대상이 아닌 문자열을 포함하거나, 반대로 주석·여러 줄 문자열·원시 문자열을 정확히 처리하지 못할 수 있습니다.

## 6-2. 한계점 2: 영어 원문은 지원하지 않음

현재 일반 문자열 탐지는 한국어(`ko`)와 일본어(`ja`)의 Unicode 범위를 사용합니다.

영어는 코드 안의 식별자, URL, 디버그 로그에도 매우 자주 사용되기 때문에, 단순히 영어 문자열 전체를 검사하면 불필요한 경고가 너무 많이 나올 수 있습니다.

```swift
let title = "Settings"
let identifier = "settings_screen"
print("Debug mode")
```

이 값들이 모두 사용자에게 보이는 문구는 아니므로, 현재 방식으로는 영어 원문을 정확하게 지원하기 어렵습니다.

## 6-3. 앞으로의 방향

다음에는 원문 언어의 Unicode 범위에 의존하지 않고, 코드의 문자열 리터럴을 더 정확하게 분석하는 방법에 도전해 보고 싶습니다.

코드리뷰에서 제안해 주신 방향을 기준으로 아래 방법을 조사할 예정입니다.

- `xcstringstool extract --all-potential-swift-keys`로 Xcode의 문자열 추출 결과 활용하기
- SwiftSyntax로 Swift 문법을 분석해 주석·여러 줄 문자열·원시 문자열을 정확하게 구분하기
- 컴파일러가 자동 추출하는 문자열과 실제로 놓칠 수 있는 일반 `String` 경로를 분리하기
- 궁극적으로 문자열이 실제 UI까지 전달되는지를 판단할 수 있는 방법 고민하기

이 실험은 현재 패키지에 급하게 덧붙이기보다, 새 패키지나 별도 브랜치에서 처음부터 구조를 다시 잡아 보려고 합니다.

영어 원문 지원과 더 정확한 문자열 탐지에 관심이 있다면, 같이 개발해 봐요!

---

# 7. 마무리

LocalizationGuard는 번역을 자동으로 작성해 주는 도구는 아닙니다.
대신 번역이 필요할 수 있는 위치를 빌드 시점에 알려주는 도구입니다.

<br>

프로젝트가 커질수록 번역 누락은 찾기 어려워집니다.

LocalizationGuard는 누락 가능성이 있는 위치를 코드가 작성된 자리에서 바로 확인할 수 있게 만드는 것이 목표입니다.

[LocalizationGuard 레포](https://github.com/dudwntjs/LocalizationGuard)

오픈소스로 공개해 두었기 때문에, 더 좋은 탐지 방식이나 지원 언어, 사용 경험에 대한 의견이 있다면 같이 개발해요!!!!!
많은 관심 부탁드리고, 마음에 드셨다면 GitHub Star도 부탁드립니다🤩 헤헤

감사합니다.
