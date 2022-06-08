import RxSwift


// MARK: - 사전작업

// dispose들을 담을 disposeBag
let disposeBag = DisposeBag()

// error
enum Foul: Error {
    case falseStart
}


// MARK: - Basic

// toArray
// 방출된 이벤트들을 하나의 array로 만듬
print("---- toArray ----")
Observable.of(1, 2, 3)
    .toArray()
    .subscribe(
        onSuccess: { print($0) },
        onFailure: { print("error: \($0)") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)

// map
// 일반적인 매핑
print("---- map ----")
Observable.of(1, 2, 3)
    .map { Int -> String in
        return String(Int)
    }
    .subscribe(onNext: {
        print($0, type(of: $0))
    })
    .disposed(by: disposeBag)


// MARK: - FlatMap

// flatMap
// Observable<Observable<String>> 로 Observable이 중첩되어있을 때 내부 값 꺼내기
print("---- flatMap ----")
protocol Player {
    var score: BehaviorSubject<Int> { get }
}

struct ArcheryPlayer: Player {
    var score: BehaviorSubject<Int>
}

let koreaTeam = ArcheryPlayer(score: BehaviorSubject<Int>(value: 10))
let chinaTeam = ArcheryPlayer(score: BehaviorSubject<Int>(value: 8))

let olympic = PublishSubject<Player>()

olympic
    .flatMap { Player in
        Player.score /// 점수 꺼냄
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

olympic.onNext(koreaTeam)
koreaTeam.score.onNext(10)

olympic.onNext(chinaTeam)

koreaTeam.score.onNext(10)
chinaTeam.score.onNext(9)
koreaTeam.score.onNext(10)


// flatMapLatest
// flatMap과 같으나 가장 최신의 Observable만 뱉음 (위와 비교)
print("---- flatMap ----")
struct JumpPlayer: Player {
    var score: BehaviorSubject<Int>
}

let daejeonTeam = JumpPlayer(score: BehaviorSubject<Int>(value: 5))
let sejongTeam = JumpPlayer(score: BehaviorSubject<Int>(value: 4))

let jumpGame = PublishSubject<Player>()

jumpGame
    .flatMapLatest { Player in
        Player.score
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

jumpGame.onNext(daejeonTeam)
daejeonTeam.score.onNext(7)

jumpGame.onNext(sejongTeam) /// game입장에서 최신의 Observable인 sejongTeam 등장

daejeonTeam.score.onNext(9) /// 기존 daejeonTeam의 시퀀스이므로 무시
sejongTeam.score.onNext(8)
daejeonTeam.score.onNext(10) /// 기존 daejsonTemp의 시퀀스이므로 무시


// MARK: - Materialize / Dematerialize

// materialize and dematerialize
// Observable을 Observable의 이벤트로 변환해야 할 때
print("---- materialize and dematerialize ----")
struct Runner: Player {
    var score: BehaviorSubject<Int>
}

let choo = Runner(score: BehaviorSubject<Int>(value: 0))
let yuna = Runner(score: BehaviorSubject<Int>(value: 1))

let runGame = BehaviorSubject<Player>(value: choo)

runGame
    .flatMapLatest { Player in
        Player.score.materialize() /// materialize로 인해 error이후의 이벤트도 방출
    }
    .filter {
        guard let error = $0.error else {
            return true
        }
        
        print("error: \(error)")
        return false
    }
    .dematerialize() /// dematerialize를 하지 않으면 value가 아닌 event로 찍힘
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

choo.score.onNext(1)
choo.score.onError(Foul.falseStart)
choo.score.onNext(2) /// 새로운 Observable인 yuna가 들어왔으므로 출력 안됨

runGame.onNext(yuna)


// MARK: - Operator 복합적 예시

// 예시: 전화번호 11자리
print("---- Example : 전화번호 11자리 ----")
let input = PublishSubject<Int?>()
let list: [Int] = []

input
    .flatMap {                                      /// 1. input 내부의 Int값 꺼냄
        $0 == nil                                   /// 2. nil 확인
            ? Observable.empty()                    ///  2-1. nil이면 empty
            : Observable.just($0)                   ///  2-2. nil이 아니면 그 값 방출
    }
    .map { $0! }                                    /// 3. optional이므로 unwrapping
    .skip(while: { $0 != 0 })                       /// 4. 첫 숫자가 0일 때 까지 skip
    .take(11)                                       /// 5. 11자리 가져옴 (000 0000 0000) 11자
    .toArray()                                      /// 6. 11자를 하나의 Array로
    .asObservable()                                 /// 7. toArray는 Single을 방출하므로 다시 Observable로
    .map {
        $0.map { String($0) }                       /// 8. Array 내부의 11자를 String으로 변환
    }
    .map { numbers in
        var numberList = numbers
        numberList.insert("-", at: 3)               /// 9. 3번째에 "-" -> (000 - 00000000)
        numberList.insert("-", at: 8)               /// 10. 8번째에 "-" -> (000 - 0000 - 0000)
        
        let number = numberList.reduce("", +)       /// 11. Array내부 순회하며 ""에 합침
        return number                               /// 12. 해당 값 반환
    }
    .subscribe(onNext: {
        print($0)                                   /// 13. 결과
    })
    .disposed(by: disposeBag)

input.onNext(10) /// 0이 아니므로 `skip`
input.onNext(0)
input.onNext(nil) /// `nil`이므로 `Observable.empty()`
input.onNext(1)
input.onNext(0)
input.onNext(1)
input.onNext(2)
input.onNext(nil) /// `nil`이므로 `Observable.empty()`
input.onNext(3)
input.onNext(4)
input.onNext(5)
input.onNext(6)
input.onNext(7)
input.onNext(8)
input.onNext(9)  /// 12번째이므로 `take(11)`에 미치지 못함
