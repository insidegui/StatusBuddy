#if DEBUG
import Foundation
import Combine

public final class PreviewStatusChecker: StatusChecker {

    let responses: [StatusResponse]
    private var currentIndex: Int = 0

    public init(responses: [StatusResponse]) {
        self.responses = responses
    }

    public func check() -> StatusResponsePublisher {
        let response = responses[currentIndex]
        currentIndex += 1
        if currentIndex > responses.count - 1 {
            currentIndex = 0
        }

        let future = Future<StatusResponse, Error>.init { resolve in
            resolve(.success(response))
        }

        return future.eraseToAnyPublisher()
    }

}
#endif
