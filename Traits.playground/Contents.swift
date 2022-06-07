import RxSwift


// MARK: - 사전작업

// dispose들을 담을 disposeBag
let disposeBag = DisposeBag()

// 각 error들
enum TraitsError: Error {
    case single
    case maybe
    case completable
}


// MARK: - Traits

/*
 `Traits`는 일반적인 Observable을 간소화해 조금 더 좁은 범위에서 사용할 수 있도록 되어있다.
 `Traits`를 사용할 수 있는 상황에서 `Observable`이 아닌 `Traits`를 사용하면 코드의 가독성을 높일 수 있다.
 
 `Traits`에는 `Single`, `Maybe`, `Completable`이 있으며
 이 중 `Single`과 `Maybe`는 api통신에 자주 사용된다.
 */


// MARK: - Single

/*
 Single은 하나의 이벤트만 방출되는 시퀀스에 사용하므로, `just`를 이용한다.
 
 Single을 subscribe하면, Observable과 차이점이 드러나는데 그 내용은 아래와 같다.
 |    Single   |       Observable       |
 ----------------------------------------
 |  onSuccess  |  onNext + onCompleted  |
 |  onFailure  |        onError         |
 |  onDisposed |       onDisposed       |
 */

// 기본적인 `Single`
print("---- Single ----")
Single<String>.just("🐒")
    .subscribe(
        onSuccess: { print($0) },
        onFailure: { print("error: \($0)") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)

// `Observable`에 `asSingle`을 사용한 `Single`
print("---- Single with asSingle ----")
Observable<String>.just("🐒")
    .asSingle()
    .subscribe(
        onSuccess: { print($0) },
        onFailure: { print("error: \($0)") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)

// create를 이용해 강제로 error를 만들어본 상황
print("---- Single with Error ----")
Observable<String>
    .create { observer -> Disposable in
        observer.onError(TraitsError.single)
        return Disposables.create()
    }
    .asSingle()
    .subscribe(
        onSuccess: { print($0) },
        onFailure: { print("error: \($0)") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)

// `Single`을 이용한 `JSONdecode`
// JSONdecode는 디코딩에 대한 `success` 또는 `failure` 만 존재하므로
// Observable을 이용해 불필요한 onNext를 사용하기보다 Single을 이용하는 것이 효율적이다.
struct SomeJSON: Decodable {
    let name: String
}

enum JSONError: Error {
    case decodingError
}

let json1 = """
    {"name": "choo"}
""" /// 협의된 올바른 형식

let json2 = """
    {"my_name": "choi"}
""" /// 올바르지 않은 형식

func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data)
        else {
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        
        observer(.success(json))
        return Disposables.create()
    }
}

print("---- Single with JSONdecode success ----")
decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
        
    }
    .disposed(by: disposeBag)

print("---- Single with JSONdecode failure ----")
decode(json: json2)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
        
    }
    .disposed(by: disposeBag)


// MARK: - Maybe

/*
 `Maybe`는 Single과 비슷하지만
 아무런 이벤트를 내보내지 않는 complete closure가 존재한다.
 
 |    Maybe    |   Single    |       Observable       |
 ------------------------------------------------------
 |         onSuccess         |  onNext + onCompleted  |
 |   onError   |  onFailure  |        onError         |
 |        onCompleted        |           (X)          |
 |                    onDisposed                      |
 */

// 기본적인 `Maybe`
print("---- Maybe ----")
Maybe<String>.just("🐒")
    .subscribe(
        onSuccess: { print($0) },
        onError: { print($0) },
        onCompleted: { print("completed") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)

// create를 이용해 강제로 error를 만들어본 상황
print("---- Maybe with Error ----")
Observable<String>
    .create { observer -> Disposable in
        observer.onError(TraitsError.maybe)
        return Disposables.create()
    }
    .asMaybe()
    .subscribe (
        onSuccess: { print($0) },
        onError: { print("error: \($0)") },
        onCompleted: { print("completed") },
        onDisposed: { print("disposed") }
    )
    .disposed(by: disposeBag)


// MARK: - Completable

/*
 `Completable`은 오직 Completed와 error만 존재한다.
 
 이때, `Completable`은
 `Single`, `Maybe`을 `Observable`과 함께 이용할 때 사용한 `.asSingle()`, `.asMaybe()`과 같은 개념이 없다.
 
 따라서 `Completable` 을 사용하고자 할 경우 `Completable.create` 로만 가능하다.
 
 |    Maybe    |   Single    |       Observable       |  Completable  |
 ----------------------------------------------------------------------
 |         onSuccess         |  onNext + onCompleted  |      (X)      |
 |   onError   |  onFailure  |        onError         |    onError    |
 |        onCompleted        |           (X)          |  onCompleted  |
 |                    onDisposed                      |   onDisposed  |
 */

// `Completable`로 success
print("---- Completable with Success ----")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
.subscribe(
    onCompleted: { print("completed") },
    onError: { print("error: \($0)") },
    onDisposed: { print("disposed") }
)
.disposed(by: disposeBag)

// `Completable`로 error
print("---- Completable with Error ----")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe(
    onCompleted: { print("completed") },
    onError: { print("error: \($0)") },
    onDisposed: { print("disposed") }
)
.disposed(by: disposeBag)
