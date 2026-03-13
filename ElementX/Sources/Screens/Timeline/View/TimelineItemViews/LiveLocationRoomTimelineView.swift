//
// Copyright 2026 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct LiveLocationRoomTimelineView: View {
    @Environment(\.timelineContext) private var context: TimelineViewModel.Context!
    let timelineItem: LiveLocationRoomTimelineItem

    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            mainContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.commonSharedLocation)
                .onTapGesture {
                    guard context.viewState.mapTilerConfiguration.isEnabled else { return }
                    context.send(viewAction: .mediaTapped(itemID: timelineItem.id))
                }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if let geoURI = timelineItem.content.lastLocation?.geoURI {
            MapLibreStaticMapView(geoURI: geoURI,
                                  mapURLBuilder: context.viewState.mapTilerConfiguration,
                                  mapSize: .init(width: mapAspectRatio * mapMaxHeight, height: mapMaxHeight)) {
                LocationMarkerView(userProfile: .init(sender: timelineItem.sender),
                                   mediaProvider: context.mediaProvider)
            }
            .frame(maxHeight: mapMaxHeight)
            .aspectRatio(mapAspectRatio, contentMode: .fit)
            .clipped()
        } else {
            // The live location is likely loading
            FormattedBodyText(text: timelineItem.body, additionalWhitespacesCount: timelineItem.additionalWhitespaces())
        }
    }

    // MARK: - Private

    private let mapAspectRatio: Double = 3 / 2
    private let mapMaxHeight: Double = 300
}

private extension MapLibreStaticMapView {
    init(geoURI: GeoURI, mapURLBuilder: MapTilerURLBuilderProtocol, mapSize: CGSize, @ViewBuilder pinAnnotationView: () -> PinAnnotation) {
        self.init(coordinates: .init(latitude: geoURI.latitude, longitude: geoURI.longitude),
                  zoomLevel: 15,
                  attributionPlacement: .bottomLeft,
                  mapURLBuilder: mapURLBuilder,
                  mapSize: mapSize,
                  pinAnnotationView: pinAnnotationView)
    }
}

struct LiveLocationRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock

    static var previews: some View {
        ScrollView {
            VStack(spacing: 8) {
                states
            }
        }
        .environmentObject(viewModel.context)
        .environment(\.timelineContext, viewModel.context)
        .previewDisplayName("Bubbles")
    }

    @ViewBuilder
    static var states: some View {
        // No location yet (beacon not yet received)
        LiveLocationRoomTimelineView(timelineItem: .init(id: .randomEvent,
                                                         timestamp: .mock,
                                                         isOutgoing: false,
                                                         isEditable: false,
                                                         canBeRepliedTo: true,
                                                         sender: .init(id: "@bob:matrix.org", displayName: "Bob"),
                                                         content: .init(isLive: true,
                                                                        timeoutDate: .mock,
                                                                        lastLocation: nil)))

        // With a known location
        LiveLocationRoomTimelineView(timelineItem: .init(id: .randomEvent,
                                                         timestamp: .mock,
                                                         isOutgoing: false,
                                                         isEditable: false,
                                                         canBeRepliedTo: true,
                                                         sender: .init(id: "@bob:matrix.org", displayName: "Bob", avatarURL: .mockMXCUserAvatar),
                                                         content: .init(isLive: true,
                                                                        timeoutDate: .mock,
                                                                        lastLocation: .init(timestamp: .mock,
                                                                                            geoURI: .init(latitude: 41.902782, longitude: 12.496366)))))
    }
}
