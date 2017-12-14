import Foundation

import Nimble
import Quick

import URLParser

final class URLParserSpec: QuickSpec {
	
	enum DeepLink {
		case login
	}
	
	
	
	let deepLink = parser.parse("myapp://login")

	
	
	
  override func spec() {
	var parser: URLParser<DeepLink>!
	
    beforeEach {
		parser = URLParser<DeepLink>()
		
		parser.register("myapp://login") { (pattern, values, context) -> DeepLink? in
			return .login
		}
		
		parser.register("myapp://chat/<uuid:chatId>") { (pattern, values, context) -> DeepLink? in
			guard let chatId = values["chatId"] as? UUID else { return nil }
			return .chat(id: chatId.uuidString)
		}

    }

    it("returns nil when there's no candidates") {
      let result = matcher.match("myapp://user/1", from: [])
      expect(result).to(beNil())
    }

    it("returns nil for unmatching scheme") {
      let result = matcher.match("myapp://user/1", from: ["yourapp://user/<id>"])
      expect(result).to(beNil())
    }

    it("returns nil for totally unmatching url") {
      let result = matcher.match("myapp://user/1", from: ["myapp://comment/<id>"])
      expect(result).to(beNil())
    }

    it("returns nil for partially unmatching url") {
      let result = matcher.match("myapp://user/1", from: ["myapp://user/<id>/hello"])
      expect(result).to(beNil())
    }

    it("returns nil for an unmatching value type") {
      let result = matcher.match("myapp://user/devxoul", from: ["myapp://user/<int:id>"])
      expect(result).to(beNil())
    }

    it("returns a result for totally matching url") {
      let candidates = ["myapp://hello"]
      let result = matcher.match("myapp://hello", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://hello"
      expect(result?.values.count) == 0
    }

    it("returns a result with an url value for matching url") {
      let candidates = ["myapp://user/<id>/hello", "myapp://user/<id>"]
      let result = matcher.match("myapp://user/1", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? String) == "1"
    }

    it("returns a result with an string-type url value for matching url") {
      let candidates = ["myapp://user/<string:id>"]
      let result = matcher.match("myapp://user/123", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<string:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? String) == "123"
    }

    it("returns a result with an int-type url value for matching url") {
      let candidates = ["myapp://user/<int:id>"]
      let result = matcher.match("myapp://user/123", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<int:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? Int) == 123
    }

    it("returns a result with a float-type url value for matching url") {
      let candidates = ["myapp://user/<float:id>"]
      let result = matcher.match("myapp://user/123.456", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<float:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? Float) == 123.456
    }

    it("returns a result with an uuid-type url value for matching url") {
      let candidates = ["myapp://user/<uuid:id>"]
      let uuidString = "621425B8-42D1-4AB4-9A58-1E69D708A84B"
      let result = matcher.match("myapp://user/\(uuidString)" ,from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<uuid:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? UUID) == UUID(uuidString: uuidString)
    }

    it("returns a result with a custom-type url value for matching url") {
      matcher.valueConverters["greeting"] = { pathComponents, index in
        return "Hello, \(pathComponents[index])!"
      }
      let candidates = ["myapp://hello/<greeting:name>"]
      let result = matcher.match("myapp://hello/devxoul" ,from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://hello/<greeting:name>"
      expect(result?.values.count) == 1
      expect(result?.values["name"] as? String) == "Hello, devxoul!"
    }

    it("returns a result with multiple url values for matching url") {
      let candidates = ["myapp://user/<id>", "myapp://user/<id>/<object>"]
      let result = matcher.match("myapp://user/1/posts", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<id>/<object>"
      expect(result?.values.count) == 2
      expect(result?.values["id"] as? String) == "1"
      expect(result?.values["object"] as? String) == "posts"
    }

    it("returns a result with ignoring a query string") {
      let candidates = ["myapp://alert"]
      let result = matcher.match("myapp://alert?title=hello&message=world", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://alert"
      expect(result?.values.count) == 0
    }

    it("returns a result with a path-type url value") {
      let candidates = ["https://<path:url>"]
      let result = matcher.match("https://google.com/search?q=URLNavigator", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "https://<path:url>"
      expect(result?.values["url"] as? String) == "google.com/search"
    }

    it("returns a result with a path url value ending with trailing slash") {
      let candidates = ["https://<path:url>"]
      let result = matcher.match("https://google.com/search/?q=URLNavigator", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "https://<path:url>"
      expect(result?.values["url"] as? String) == "google.com/search"
    }
  }
}
