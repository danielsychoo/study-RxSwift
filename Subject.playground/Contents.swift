import RxSwift

// MARK: - 사전작업

// dispose들을 담을 disposeBag
let disposeBag = DisposeBag()

// error
enum SubjectError: Error {
    case publishSubjectError
    case behaviorSubjectError
    case replaySubjectError
}


// MARK: - Subject

/*
 실무에서 Observable을 사용하게 될 때에는
 실시간으로 Observable에 값을 추가하고, Subscriber에게 방출하도록 하는 작업이 필요하다.
 
 따라서 Observable이면서 동시에 Observer인 것이 필요한데 이것이 `Subject`이다.
 
 `Subject`에는 총 세 가지 종류가 있다.
 - `PublishSubject`
    : 1. 구독된 순간 새로운 이벤트 수신을 알리고 싶을때 용이하다.
      2. 빈 상태로 시작하여 새로운 값이 발생했을 때 그 새로운 값만을 subscriber에 방출한다.
 - `BehaviorSubject`
    : 1. 마지막 next이벤트를 새로운 구독자에게 반복한다는 점의 차이만 있고,
            PublishSubject와 유사하다.
      2. 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber가 생겼을 때,
            그 subscriber에게 초기값 또는 최신값을 방출한다.
      3. subscribe 구문 밖에서도 value 값을 뽑아낼 수 있다. (그러나 잘 쓰지 않는다.)
 - `ReplaySubject`
    : 1. 버퍼를 두고 초기화하여, 버퍼 사이즈 만큼의 값들을 유지하면서
            새로운 subscriber가 생겼을 때 그 subscriber에게 방출한다.
      2. 이때 버퍼들을 메모리가 가지고 있기 때문에, 버퍼에 들어가는 데이터가 크면
            메모리에 큰 부하를 줄 수 있다는 점을 유념해야 한다.
 */


// MARK: - PublishSubject

// 흐름과 함께 확인
// 빈 상태로 시작하여 새로운 값이 발생했을 때 그 새로운 값만을 subscriber에 방출
print("---- PublishSubject ----")
let publishSubject = PublishSubject<String>() /// PublishSubject 생성
publishSubject.onNext("1️⃣") /// 1번째 event 방출 --> 구독자가 없으므로 이벤트 놓침

let publishSubscriber1 = publishSubject /// 구독자1 생성
    .subscribe( /// 구독 시작
        onNext: { print("구독자1: \($0)") }
    )

publishSubject.onNext("2️⃣") /// 2번째 event 방출 --> 구독자1이 수신
publishSubject.onNext("3️⃣") /// 3번째 event 방출 --> 구독자1이 수신

publishSubscriber1.dispose() /// 구독자1 dispose

let publishSubscriber2 = publishSubject /// 구독자2 생성
    .subscribe( /// 구독 시작
        onNext: { print("구독자2: \($0)") }
    )

publishSubject.onNext("4️⃣") /// 4번째 event 방출 --> 구독자 2가 수신
publishSubject.onCompleted() /// completed

publishSubject.onNext("5️⃣") /// 5번째 event --> completed 이후이므로 미수신

publishSubscriber2.dispose() /// 구독자2 dispose

let publishSubscriber3: () = publishSubject /// 구독자3 생성 --> completed 이후 생성
    .subscribe( /// 구독 시작
        onNext: { print("구독자3: \($0)") }
    )
    .disposed(by: disposeBag)

publishSubject.onNext("6️⃣") /// 6번째 event --> completed 이후이므로 구독 의미 없음


// MARK: - BehaviorSubject

// 흐름과 함께 확인
// 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber가 생겼을 때, 그 subscriber에게 초기값 또는 최신값을 방출
print("---- BehaviorSubject ----")
let behaviorSubject = BehaviorSubject<String>(value: "initialValue") /// 초기값과 함께 생성

let behaviorSubscriber1: () = behaviorSubject
    .subscribe { /// 구독자1 생성
        print("구독자1:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

behaviorSubject.onNext("1️⃣") /// 1번째 event 방출

let behaviorSubscriber2: () = behaviorSubject
    .subscribe { /// 구독자2 생성
        print("구독자2:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

if let valueBeforeError = try? behaviorSubject.value() {  /// subscribe 구문 밖에서도 value를 뽑아낼 수 있음
    print("valueBeforeError:", valueBeforeError)
}


behaviorSubject.onError(SubjectError.behaviorSubjectError) /// error 발생

let behaviorSubscriber3: () = behaviorSubject
    .subscribe { /// 구독자3 생성
        print("구독자3:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

if let valueAfterError = try? behaviorSubject.value() { /// error 이후에는 nil이므로 미출력
    print("valueAfterError:", valueAfterError)
}


// MARK: - ReplaySubject

// 흐름과 함께 확인
// 버퍼를 두고 초기화하여, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber가 생겼을 때 그 subscriber에게 방출
print("---- ReplaySubject ----")
let replaySubject = ReplaySubject<String>.create(bufferSize: 2) /// buffer 사이즈와 함께 생성

replaySubject.onNext("1️⃣")
replaySubject.onNext("2️⃣") /// 버퍼사이즈 2이므로 최신 두개 저장
replaySubject.onNext("3️⃣") /// 버퍼사이즈 2이므로 최신 두개 저장

let replaySubscriber1: () = replaySubject
    .subscribe { /// 구독자1 생성
        print("구독자1:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

let replaySubscriber2: () = replaySubject
    .subscribe { /// 구독자2 생성
        print("구독자2:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

replaySubject.onNext("4️⃣")

replaySubject.onError(SubjectError.replaySubjectError)
replaySubject.dispose()

let replaySubscriber3: () = replaySubject /// dispose 후의 구독이므로 RxSwift 에러 발생 (기존에러들과 다른 에러)
    .subscribe { /// 구독자3 생성
        print("구독자3:", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
