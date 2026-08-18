# 1. 키워드를 선정하게 된 이유와 배경

Static Framework와 Dynamic Framework를 공부하며, 이해가 가지 않았던 단어들과 원리를 이해한다.

Binary File, Static Library, Dynamic Library, Mach-O Type, Static Linking, Dynamic Linking, Embed, Resource, Executable, Bundle.

# 2. 핵심내용

Static Framework와 Static Library의 차이를 설명할 수 있다.
Static Framework와 Dynamic Framework의 차이를 설명할 수 있다.
Embed를 여부를 결정할 수 있다.

# 3. 결론 및 아직 열려있는 질문 이 명시되어 있어야 한다

Static Library와 Dynamic Library의 주요 차이는 링크를 링크 타임(컴파일이 끝난 뒤에 ld가 함)에 할 것이냐, 앱 실행 시점(앱 실행 시 dyld가 처리)에 할 것이냐 이다.

링크 타임에 링크되는 Static Library는 앱 실행(launch) 시간을 줄여주는 대신, 실행 파일의 크기는 커진다. 대신, 앱 전체 용량은 Static이 더 작을 수 있다. 왜냐하면 실제로 참조된 심볼만 가져오기 때문이다. Dynamic Library는 앱 실행(launch) 시간이 늘어나게 된다. 왜냐하면 앱을 실행할 때, .dylib를 메모리에 로드하고 이를 dyld로 매핑해야 하기 때문이다.

Mach-O Type을 수정하여 Dynamic Framework를 쉽게 Static Framework로 바꿀 수 있다. 이는 둘의 차이는 링크 타이밍에 의해 결정된다는 의미이다. Dynamic이 Embed를 해야 하는 이유는, 앱 실행 시점에 링크되므로 실제 바이너리가 실행 파일 밖에 존재해야 하기 때문이다. 그래서 `.framework` 전체가 앱 번들의 `Frameworks/` 디렉터리로 복사된다(= Embed). 이게 앱 용량이 커지는 이유다.

### 확인해볼 사항, 직접 resource 파일을 사용하는 Static Framework를 만들어 보기

Embed를 Static에서는 하지 않는 게 맞다고 하는데, 이는 반은 맞는 얘기이다. Bundle에 리소스 파일이 있는 경우, Static Linking은 오로지 코드만 링킹하기 때문에 리소스 파일들은 실행 파일에 직접 포함되지 않는다. (자세한 내용은 안 다룰 것) 리소스를 살리려면 `.framework` 디렉터리 자체를 앱 번들에 넣어야 한다.

문제 상황: Static Framework에 리소스 파일이 있는 경우 Do Not Embed를 하면 안 된다. Embed & Sign을 하면 앱 용량이 늘어난다. (실행 파일에 이미 들어간 코드가 프레임워크 바이너리로 중복 포함됨)

수동 해결: 직접 만든 Static Framework는 Embed & Sign 선택 + 리소스 접근 코드 수정. (`Bundle(for:)`가 앱 main bundle을 반환하므로 프레임워크 번들을 직접 찾아야 함)

자동 해결: SPM에서 resource를 입력하면, 리소스 번들을 자동으로 생성 & 복사하고 `Bundle.module`이 링크 타입과 무관하게 올바른 번들을 찾아준다. Embed 설정을 건드릴 일이 없다.

추가) Xcode 15부터 나온 Mergeable Libraries도 참고할 만하다. 개발 중엔 dynamic으로 두어 증분 빌드 이득을 챙기고, 릴리즈 빌드에서 링커가 static처럼 병합해주는 방식이다.

- Framework를 배포하는 방법은?
- Framework를 이용한 모듈화 방법은?