// 단일 타깃의 증분 빌드를 실습할 때 이 파일을 수정합니다.
// 별도 폴더에 있지만 이 타입은 MonolithicApp 모듈 전체에서 접근할 수 있습니다.
struct MonolithicDetectService {
    func detect(run: Int) -> [MonolithicSharedModel] {
        MonolithicLogger.log("Ran fake model inference \(run)", category: "Detect")
        return [
            MonolithicSharedModel(
                title: "Skateboard",
                detail: "Confidence \(90 + run % 9)%"
            ),
            MonolithicSharedModel(
                title: "Person",
                detail: "Confidence \(85 + run % 10)%"
            )
        ]
    }
}
