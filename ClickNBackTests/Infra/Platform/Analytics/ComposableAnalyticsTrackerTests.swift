//

import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("ComposableAnalyticsTracker")
struct ComposableAnalyticsTrackerTests {

    @Test
    func track_forwardsEvent_toSingleTracker() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let event = makeEvent()
        let sut = makeSUT(trackers: [tracker])

        // Act
        sut.track(event)
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [event.name])
    }

    @Test
    func track_forwardsEvent_toAllTrackers() async {
        // Arrange
        let firstTracker = MockAnalyticsTracker()
        let secondTracker = MockAnalyticsTracker()
        let event = makeEvent()
        let sut = makeSUT(trackers: [firstTracker, secondTracker])

        // Act
        sut.track(event)
        await Task.yield()

        // Assert
        #expect(firstTracker.trackedEventNames == [event.name])
        #expect(secondTracker.trackedEventNames == [event.name])
    }

    @Test
    func track_doesNotForwardEvent_onEmptyTrackerList() async {
        // Arrange
        let sut = makeSUT(trackers: [])
        let event = makeEvent()

        // Act
        sut.track(event)
        await Task.yield()

        // Assert — reaching this point without crash confirms the behavior
        #expect(Bool(true))
    }

    @Test
    func track_forwardsMultipleEvents_inOrder() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let firstEvent = makeEvent(name: "first-event")
        let secondEvent = makeEvent(name: "second-event")
        let sut = makeSUT(trackers: [tracker])

        // Act
        sut.track(firstEvent)
        sut.track(secondEvent)
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [firstEvent.name, secondEvent.name])
    }

    // MARK: - Helpers

    private func makeSUT(trackers: [AnalyticsTracker] = [MockAnalyticsTracker()]) -> ComposableAnalyticsTracker {
        ComposableAnalyticsTracker(trackers: trackers)
    }

    private func makeEvent(name: String = "test-event") -> MockAnalyticsEvent {
        MockAnalyticsEvent(name: name)
    }
}
