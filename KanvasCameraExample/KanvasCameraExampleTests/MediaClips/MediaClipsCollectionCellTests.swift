//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import AVFoundation
import UIKit
import FBSnapshotTestCase
@testable import KanvasCamera

final class MediaClipsCollectionCellTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newCell() -> MediaClipsCollectionCell {
        let cell = MediaClipsCollectionCell(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: MediaClipsCollectionCell.width, height: MediaClipsCollectionCell.minimumHeight)))
        return cell
    }

    func testMediaClip() {
        let cell = newCell()
        var mediaClip: MediaClip? = nil
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            mediaClip = MediaClip(representativeFrame: image, overlayText: "00:02")
        }
        guard let clip = mediaClip else {
            XCTFail("Image not found, media clip was not created")
            return
        }

        cell.bindTo(clip)
        FBSnapshotVerifyView(cell)
    }

    func testSelection() {
        let cell = newCell()
        cell.setSelected(true)
        FBSnapshotVerifyView(cell)
    }

}