//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import XCTest

class Tests_iOS: XCTestCase {
	let viewModel = ViewModel.shared
	
    override func setUpWithError() throws {
		viewModel.posts = try viewModel.posts(from: testJSONString.data(using: .utf8)!)
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
     	
    }
	
	func testFeedDecoding() {
		// set up the json decoder
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		
		// try to decode json from the aquired data
		let publicFeed = try? jsonDecoder.decode(Flickr.PublicFeed.self, from: testJSONString.data(using: .utf8)!)
		XCTAssertNotNil(publicFeed)
		let decodedPosts = publicFeed!.posts
		
		XCTAssertEqual(decodedPosts.count, 5)
		
		XCTAssertEqual(decodedPosts.first?.tags, "")
		XCTAssertEqual(decodedPosts.first?.media.keys.count, 3)
		XCTAssertEqual(decodedPosts.first?.author, "nobody@flickr.com (\"moniquemaynard685\")")
		XCTAssertEqual(decodedPosts.first?.title, "Pic a ventre roux /Red-bellied woodpecker")
		XCTAssertEqual(decodedPosts.first?.link.absoluteString, "https://www.flickr.com/photos/132471590@N04/51710334527/")
		XCTAssertEqual(decodedPosts.first?.publishedDate.formatted(date: .abbreviated, time: .omitted), "Nov 28, 2021")
		XCTAssertEqual(decodedPosts.first?.takenDate.formatted(date: .abbreviated, time: .omitted), "Nov 28, 2021")
		XCTAssertEqual(decodedPosts.first?.previewSize, CGSize(width: 240, height: 173))
		XCTAssertEqual(decodedPosts.first?.media[.squaredLarge]?.absoluteString, "https://live.staticflickr.com/65535/51710334527_c95af67147_q.jpg")
		XCTAssertEqual(decodedPosts.first?.media[.small]?.absoluteString, "https://live.staticflickr.com/65535/51710334527_c95af67147_m.jpg")
		XCTAssertEqual(decodedPosts.first?.media[.large]?.absoluteString, "https://live.staticflickr.com/65535/51710334527_c95af67147_b.jpg")

		XCTAssertEqual(decodedPosts[3].tags, "birdphotography birding backyardbirding wildlife yellowrump nature bird backyardbird birdwatching yellow warbler wings naturephotography")
		XCTAssertEqual(decodedPosts[3].media.keys.count, 3)
		XCTAssertEqual(decodedPosts[3].author, "nobody@flickr.com (\"ChrisF_2011\")")
		XCTAssertEqual(decodedPosts[3].title, "Yellow-rumped Warbler")
		XCTAssertEqual(decodedPosts[3].link.absoluteString, "https://www.flickr.com/photos/chrisf_2011/51710335532/")
		XCTAssertEqual(decodedPosts[3].publishedDate.formatted(date: .abbreviated, time: .omitted), "Nov 28, 2021")
		XCTAssertEqual(decodedPosts[3].takenDate.formatted(date: .abbreviated, time: .omitted), "Nov 25, 2021")
		XCTAssertEqual(decodedPosts[3].previewSize, CGSize(width: 240, height: 150))
		XCTAssertEqual(decodedPosts[3].media[.squaredLarge]?.absoluteString, "https://live.staticflickr.com/65535/51710335532_ba4918fbf1_q.jpg")
		XCTAssertEqual(decodedPosts[3].media[.small]?.absoluteString, "https://live.staticflickr.com/65535/51710335532_ba4918fbf1_m.jpg")
		XCTAssertEqual(decodedPosts[3].media[.large]?.absoluteString, "https://live.staticflickr.com/65535/51710335532_ba4918fbf1_b.jpg")
	}
	
	func testFeedEncoding() {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		let feed = Flickr.PublicFeed(posts: viewModel.posts)
		let data = try? encoder.encode(feed)
		XCTAssertNotNil(data)
		
		// set up the json decoder
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		
		// try to decode back from the encoded data
		let posts = try? viewModel.posts(from: data!)
		XCTAssertNotNil(posts)
		
		// both arrays must be eqaul
		XCTAssertEqual(posts, viewModel.posts)
	}
	
	func testSorting() {
		var sorted1 = ViewModel.sort(viewModel.posts, by: .publishingDate)
		var sorted2 = ViewModel.sort(sorted1, by: .creationData)
		sorted2 = ViewModel.sort(sorted2, by: .publishingDate)
		XCTAssertEqual(sorted1.first, sorted2.first)
		
		sorted1 = ViewModel.sort(viewModel.posts, by: .creationData)
		sorted2 = ViewModel.sort(sorted1, by: .publishingDate)
		sorted2 = ViewModel.sort(sorted2, by: .creationData)
		XCTAssertEqual(sorted1.first, sorted2.first)
	}
	
	func testCaching() {
		let url = URL(string: "https://live.staticflickr.com/65535/51710334527_c95af67147_m.jpg")!
		NetworkManager.shared.retrieveData(from: url) { _, _ in
			// nothing happens here
		}
		_ = XCTWaiter.wait(for: [XCTestExpectation(description: "Make sure the image downloaded and cached!")], timeout: 5.0)
		XCTAssertTrue(NetworkManager.shared.isCached(url))
	}
}


private let testJSONString = """
{\n\t\t\"title\": \"Uploads from everyone\",\n\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/\",\n\t\t\"description\": \"\",\n\t\t\"modified\": \"2021-11-28T19:19:23Z\",\n\t\t\"generator\": \"https:\\/\\/www.flickr.com\",\n\t\t\"items\": [\n\t   {\n\t\t\t\"title\": \"Pic a ventre roux \\/Red-bellied woodpecker\",\n\t\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/132471590@N04\\/51710334527\\/\",\n\t\t\t\"media\": {\"m\":\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334527_c95af67147_m.jpg\"},\n\t\t\t\"date_taken\": \"2021-11-28T10:16:44-08:00\",\n\t\t\t\"description\": \" <p><a href=\\\"https:\\/\\/www.flickr.com\\/people\\/132471590@N04\\/\\\">moniquemaynard685<\\/a> posted a photo:<\\/p> <p><a href=\\\"https:\\/\\/www.flickr.com\\/photos\\/132471590@N04\\/51710334527\\/\\\" title=\\\"Pic a ventre roux \\/Red-bellied woodpecker\\\"><img src=\\\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334527_c95af67147_m.jpg\\\" width=\\\"240\\\" height=\\\"173\\\" alt=\\\"Pic a ventre roux \\/Red-bellied woodpecker\\\" \\/><\\/a><\\/p> <p>Refuge faunique Marguerite D\'Youville<\\/p>\",\n\t\t\t\"published\": \"2021-11-28T19:19:23Z\",\n\t\t\t\"author\": \"nobody@flickr.com (\\\"moniquemaynard685\\\")\",\n\t\t\t\"author_id\": \"132471590@N04\",\n\t\t\t\"tags\": \"\"\n\t   },\n\t   {\n\t\t\t\"title\": \"Getting ready for Christmas Expo 2021\",\n\t\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/192012831@N07\\/51710334647\\/\",\n\t\t\t\"media\": {\"m\":\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334647_004167b8d3_m.jpg\"},\n\t\t\t\"date_taken\": \"2021-11-28T11:19:27-08:00\",\n\t\t\t\"description\": \" <p><a href=\\\"https:\\/\\/www.flickr.com\\/people\\/192012831@N07\\/\\\">LadyJess Przhevalsky<\\/a> posted a photo:<\\/p> <p><a href=\\\"https:\\/\\/www.flickr.com\\/photos\\/192012831@N07\\/51710334647\\/\\\" title=\\\"Getting ready for Christmas Expo 2021\\\"><img src=\\\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334647_004167b8d3_m.jpg\\\" width=\\\"240\\\" height=\\\"129\\\" alt=\\\"Getting ready for Christmas Expo 2021\\\" \\/><\\/a><\\/p> <p>Something very special! An OOAK coat for the Teegles will be on auction at the Expo, All proceeds to charity. Come support this auction! Your chance to own an original one of a kind high quality coat of BLACK BEAUTY!!!<\\/p>\",\n\t\t\t\"published\": \"2021-11-28T19:19:27Z\",\n\t\t\t\"author\": \"nobody@flickr.com (\\\"LadyJess Przhevalsky\\\")\",\n\t\t\t\"author_id\": \"192012831@N07\",\n\t\t\t\"tags\": \"\"\n\t   },\n\t   {\n\t\t\t\"title\": \"20211124_132053-01\",\n\t\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/194165872@N07\\/51710334722\\/\",\n\t\t\t\"media\": {\"m\":\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334722_04d7be313f_m.jpg\"},\n\t\t\t\"date_taken\": \"2021-11-24T13:20:53-08:00\",\n\t\t\t\"description\": \" <p><a href=\\\"https:\\/\\/www.flickr.com\\/people\\/194165872@N07\\/\\\">stefanopessina.photo<\\/a> posted a photo:<\\/p> <p><a href=\\\"https:\\/\\/www.flickr.com\\/photos\\/194165872@N07\\/51710334722\\/\\\" title=\\\"20211124_132053-01\\\"><img src=\\\"https:\\/\\/live.staticflickr.com\\/65535\\/51710334722_04d7be313f_m.jpg\\\" width=\\\"180\\\" height=\\\"240\\\" alt=\\\"20211124_132053-01\\\" \\/><\\/a><\\/p> \",\n\t\t\t\"published\": \"2021-11-28T19:19:29Z\",\n\t\t\t\"author\": \"nobody@flickr.com (\\\"stefanopessina.photo\\\")\",\n\t\t\t\"author_id\": \"194165872@N07\",\n\t\t\t\"tags\": \"\"\n\t   },\n\t   {\n\t\t\t\"title\": \"Yellow-rumped Warbler\",\n\t\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/chrisf_2011\\/51710335532\\/\",\n\t\t\t\"media\": {\"m\":\"https:\\/\\/live.staticflickr.com\\/65535\\/51710335532_ba4918fbf1_m.jpg\"},\n\t\t\t\"date_taken\": \"2021-11-25T13:08:55-08:00\",\n\t\t\t\"description\": \" <p><a href=\\\"https:\\/\\/www.flickr.com\\/people\\/chrisf_2011\\/\\\">ChrisF_2011<\\/a> posted a photo:<\\/p> <p><a href=\\\"https:\\/\\/www.flickr.com\\/photos\\/chrisf_2011\\/51710335532\\/\\\" title=\\\"Yellow-rumped Warbler\\\"><img src=\\\"https:\\/\\/live.staticflickr.com\\/65535\\/51710335532_ba4918fbf1_m.jpg\\\" width=\\\"240\\\" height=\\\"150\\\" alt=\\\"Yellow-rumped Warbler\\\" \\/><\\/a><\\/p> \",\n\t\t\t\"published\": \"2021-11-28T19:19:53Z\",\n\t\t\t\"author\": \"nobody@flickr.com (\\\"ChrisF_2011\\\")\",\n\t\t\t\"author_id\": \"70132747@N02\",\n\t\t\t\"tags\": \"birdphotography birding backyardbirding wildlife yellowrump nature bird backyardbird birdwatching yellow warbler wings naturephotography\"\n\t   },\n\t   {\n\t\t\t\"title\": \"Pintje November 2021\",\n\t\t\t\"link\": \"https:\\/\\/www.flickr.com\\/photos\\/156997526@N08\\/51711120356\\/\",\n\t\t\t\"media\": {\"m\":\"https:\\/\\/live.staticflickr.com\\/65535\\/51711120356_ed1829aaf5_m.jpg\"},\n\t\t\t\"date_taken\": \"2021-11-28T11:19:42-08:00\",\n\t\t\t\"description\": \" <p><a href=\\\"https:\\/\\/www.flickr.com\\/people\\/156997526@N08\\/\\\">Spoedski<\\/a> posted a photo:<\\/p> <p><a href=\\\"https:\\/\\/www.flickr.com\\/photos\\/156997526@N08\\/51711120356\\/\\\" title=\\\"Pintje November 2021\\\"><img src=\\\"https:\\/\\/live.staticflickr.com\\/65535\\/51711120356_ed1829aaf5_m.jpg\\\" width=\\\"180\\\" height=\\\"240\\\" alt=\\\"Pintje November 2021\\\" \\/><\\/a><\\/p> \",\n\t\t\t\"published\": \"2021-11-28T19:19:42Z\",\n\t\t\t\"author\": \"nobody@flickr.com (\\\"Spoedski\\\")\",\n\t\t\t\"author_id\": \"156997526@N08\",\n\t\t\t\"tags\": \"\"\n\t   }]\n}
"""
