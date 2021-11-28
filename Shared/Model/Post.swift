//
//  Flickr.Post.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import UIKit


// MARK: - Flickr.Post

extension Flickr {
	/// Flickr.Post structure describes a Flickr post JSON data that can be recieved from Flickr server.
	///
	/// Flickr.Post can be encoded and decoded from/to JSON string.
	struct Post: Codable, Identifiable, Equatable {
		/// Coding keys that correspond to Flickr API
		fileprivate enum CodingKeys: String, CodingKey {
			case media
			case takenDate = "date_taken"
			case publishedDate = "published"
			case author
			case tags
			case title
			case link
			case description
		}
		
		var id: Int {
			link.hashValue
		}
		
		/// Dictionary of URLs to the static images
		///
		/// Could be in different sizes. The dictionary keys pont to the size variations
		let media: [ImageVariant: URL]
		
		/// URL to the source post
		let link: URL
		
		/// Date when the image was taken
		let takenDate: Date
		
		/// Date when the image was published
		let publishedDate: Date
		
		/// Author's name
		let author: String?
		
		/// Tags of the image
		let tags: String
		
		/// Title of the image
		let title: String?
		
		/// The post description string that contains a preview URL and the image size
		private let description: String
		
		/// The image preview size.
		///
		/// Usually, it comes in the description string. But sometime Flickr server returns no preview size.
		/// It that case, the preview size is set to the default values of 240x180
		///
		/// - Note: Previously I thought about making a complex grid layoud which would require to have the grid image size before the image is downloaded.
		/// But later I changed my mind, so now this property is unused.
		let previewSize: CGSize
		
		/// A default post image size according to Flickr API
		static var defaultPreviewSize: CGSize {
			CGSize(width: 240, height: 180)
		}
		
		static func ==(lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}
	}
}

#if DEBUG
extension Flickr.Post {
	/// A test post with blank data for testing purposes only.
	static var testable: Self {
		Self.init(media: [.small: URL(string: "https://live.staticflickr.com/65535/51710825195_27169cc8db_m.jpg")!,
						  .large: URL(string: "https://live.staticflickr.com/65535/51710825195_27169cc8db_b.jpg")!],
				  link: URL(string: "https://www.flickr.com/photos/124592429@N08/51710825195/")!,
				  takenDate: .now,
				  publishedDate: .now,
				  author: "nobody@flickr.com",
				  tags: "random, nothing, empty, blank, test, mock, vague, undeterminate",
				  title: "Some test image",
				  description: "",
				  previewSize: CGSize(width: 240, height: 180))
	}
}
#endif


// MARK: - Flickr.Post.ImageVariant

extension Flickr.Post {
	/// This enum contains only the public image variations that can be accessed without the Flickr API key.
	enum ImageVariant: Int, Codable, Hashable {
		/// Coding keys that correspond to Flickr API
		fileprivate enum CodingKeys: String, CodingKey {
			case squared = "s"
			case squaredLarge = "q"
			case thumbnail = "t"
			case small = "m"
			case medium = "z"
			case large = "b"
		}
		
		case squared
		case squaredLarge
		case thumbnail
		case small
		case medium
		case large
	}
}


// MARK: - Codable Fix

/// Currently, the Dictionary's Codable conformance cannot produce correct results if a dict key is enum.
/// To bypass that bug (or some kind of a feature) it is neccessary to implement a custom Codable methods.
extension Flickr.Post {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// decode all properties as expected...
		link = try container.decode(URL.self, forKey: .link)
		takenDate = try container.decode(Date.self, forKey: .takenDate)
		publishedDate = try container.decode(Date.self, forKey: .publishedDate)
		author = try container.decodeIfPresent(String.self, forKey: .author)
		tags = try container.decode(String.self, forKey: .tags)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		description = try container.decode(String.self, forKey: .description)

		// ... but for the 'previews' property create a nested container
		let dictContainer = try container.nestedContainer(keyedBy: ImageVariant.CodingKeys.self, forKey: .media)
		
		// and manually decode dictionary's keys from their string representations
		var dictionary: [Self.ImageVariant: URL] = .init()
		for enumKey in dictContainer.allKeys {
			guard let anEnum = Self.ImageVariant(stringLiteral: enumKey.rawValue) else {
				let context = DecodingError.Context(codingPath: [], debugDescription: "Could not parse json key to an an enum object")
				throw DecodingError.dataCorrupted(context)
			}
			let value = try dictContainer.decode(URL.self, forKey: enumKey)
			dictionary[anEnum] = value
		}
		
		// make sure the dictionary contains all the neccessary image size URLs ..
		// .. according to Flickr API every post image has those URLs variants
		if !dictionary.keys.contains(.squaredLarge) {
			dictionary[.squaredLarge] = Self.stringURL(.squaredLarge, fromSmallImageURL: dictionary[.small]!)
		}
		if !dictionary.keys.contains(.large) {
			dictionary[.large] = Self.stringURL(.large, fromSmallImageURL: dictionary[.small]!)
		}

		media = dictionary
		
		// parse the description string to get the preview image size
		let width = Self.parsedInteger(of: .width, from: description) ?? Int(Self.defaultPreviewSize.width)
		let height = Self.parsedInteger(of: .height, from: description) ?? Int(Self.defaultPreviewSize.height)
		previewSize = CGSize(width: width, height: height)
	}
		
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		// convert the dict keys to string literals before encoding
		let convertedTuples = media.map{ ($0.key.stringLiteral, $0.value) }
		let convertedDict = Dictionary(uniqueKeysWithValues: convertedTuples)
		try container.encode(convertedDict, forKey: .media)
		
		// encode the rest of the properties as usual
		try container.encode(link, forKey: .link)
		try container.encode(takenDate, forKey: .takenDate)
		try container.encode(publishedDate, forKey: .publishedDate)
		try container.encodeIfPresent(author, forKey: .author)
		try container.encode(tags, forKey: .tags)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encode(description, forKey: .description)
	}
}

/// Helper methods for the above implementation
extension Flickr.Post.ImageVariant {
	init?(stringLiteral: String) {
		switch stringLiteral {
		case CodingKeys.squared.rawValue:
			self = .squared
		case CodingKeys.squaredLarge.rawValue:
			self = .squaredLarge
		case CodingKeys.thumbnail.rawValue:
			self = .thumbnail
		case CodingKeys.small.rawValue:
			self = .small
		case CodingKeys.medium.rawValue:
			self = .medium
		case CodingKeys.large.rawValue:
			self = .large
		default:
			return nil
		}
	}
	
	fileprivate var stringLiteral: String {
		switch self {
		case .squared:
			return CodingKeys.squared.rawValue
		case .squaredLarge:
			return CodingKeys.squaredLarge.rawValue
		case .thumbnail:
			return CodingKeys.thumbnail.rawValue
		case .small:
			return CodingKeys.small.rawValue
		case .medium:
			return CodingKeys.medium.rawValue
		case .large:
			return CodingKeys.large.rawValue
		}
	}
}


// MARK: - Flickr Post Description Parsing
extension Flickr.Post {
	enum StringLiteralNumber: String {
		case width = "width=\""
		case height = "height=\""
	}
	
	/// Gets an image size integers from a Flickr post description string.
	///
	/// This method iterates through each character after the substring, until it reaches the closest " character.
	/// That will indicate that the size property was successfully parsed.
	/// - Parameters:
	///   - stringLiteralSize: an image width or height subssting
	///   - description: a Flickr post description string
	/// - Returns: An integer representation of the given string literal number or *nil* if there's now image sized specified in the description
	static fileprivate func parsedInteger(of stringLiteralNumber: StringLiteralNumber, from description: String) -> Int? {
		var intString = ""
		var isDone = false
		
		// remove all the back-slash character to make the parsing a bit convinient
		let fixedDescription = description.replacingOccurrences(of: "\\", with: "")
		
		// get the range of the substring
		guard var processedRange = fixedDescription.range(of: stringLiteralNumber.rawValue) else {
			fatalError("The description string doesn't contain the following substring: \(stringLiteralNumber.rawValue)")
		}

		while(!isDone) {
			// get the next character index after the processed character range
			let nextIndex = fixedDescription.index(after: processedRange.upperBound)
			
			// get the character from that character index
			let char = fixedDescription[processedRange.upperBound ..< nextIndex]
			
			// check whether the algorithm is finished parsing
			if char == "\"" {
				isDone = true
				break
			}
			
			// append the parsed character..
			intString += char
			// .. and increase the processed range by the processed index
			processedRange = Range<String.Index>(uncheckedBounds: (lower: processedRange.lowerBound, upper: nextIndex))
		}
		
		return Int(intString)
	}
	
	/// Generates a valid URL to the Flickr storage of static images for every Flickr post.
	///
	/// Some of those URLs are required by UI components but by default Flickr server returns just a small image variant URL.
	/// So, this method can produce URLs for any image variant just by parsing the initial small variant image URL.
	/// - Parameters:
	///   - sizeVariant: a image size variant to generate the URL for.
	///   - sourceURL: a source small image variant URL to work with.
	/// - Returns: a valid URL to the static image of given size variant.
	static fileprivate func stringURL(_ sizeVariant: ImageVariant, fromSmallImageURL sourceURL: URL) -> URL {
		guard sizeVariant != .small else { return sourceURL }
		
		var sourceString = sourceURL.absoluteString
		assert(sourceString.contains("_\(ImageVariant.small.stringLiteral)"), "Flickr Post small image URL must contain _\(ImageVariant.small.stringLiteral) suffix")
		
		let extRange = sourceString.range(of: ".jpg")!
		let startRange = sourceString.index(extRange.lowerBound, offsetBy: -2)
		
		if sizeVariant == .medium {
			// medium image size URL has no suffix at all
			sourceString.removeSubrange(startRange ..< extRange.lowerBound)
		} else {
			sourceString.replaceSubrange(startRange ..< extRange.lowerBound, with: "_\(sizeVariant.stringLiteral)")
		}
		
		return URL(string: sourceString)!
	}
}
