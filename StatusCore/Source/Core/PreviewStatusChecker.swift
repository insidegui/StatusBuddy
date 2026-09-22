#if DEBUG
import Foundation

public actor PreviewStatusChecker: StatusChecker {

    let responses: [StatusResponse]
    private var currentIndex: Int = 0

    public init(responses: [StatusResponse]) {
        self.responses = responses
    }

    public func check() async throws -> StatusResponse {
        let response = responses[currentIndex]
        currentIndex += 1
        if currentIndex > responses.count - 1 {
            currentIndex = 0
        }

        return response
    }

}
#endif
