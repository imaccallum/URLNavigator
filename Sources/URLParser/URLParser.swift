//
//  URLParser.swift
//  Pods-URLNavigatorExample
//
//  Created by Ian MacCallum on 12/3/17.
//

import Foundation
import URLNavigator

/*
	let parser = URLParser<DeepLink>()

	parser.register("myapp://login") { (pattern, values, context) -> DeepLink? in
		return .login
	}

	parser.register("myapp://chat/<uuid:chatId>") { (pattern, values, context) -> DeepLink? in
		guard let chatId = values["chatId"] as? UUID else { return nil }
		return .chat(id: chatId.uuidString)
	}

	let deepLink = parser.parse("myapp://login")
*/

open class URLParser<T> {
	
	public typealias MatchHandler = (_ pattern: URLPattern, _ values: [String: Any], _ context: Any?) -> T?
	
	private let matcher = URLMatcher()
	private var handlers: [URLPattern: MatchHandler] = [:]
	
	public init() {
	
	}
	
	open func register(_ pattern: URLPattern, handler: @escaping MatchHandler) {
		handlers[pattern] = handler
	}
	
	// Parses the given url to return the generic type
	open func parse(_ url: URLConvertible, with context: Any? = nil) -> T? {		
		guard let path = url.urlValue?.path else { return nil }
		let urlPatterns = Array(handlers.keys)
		guard let match = matcher.match(path, from: urlPatterns) else { return nil }
		guard let handler = handlers[match.pattern] else { return nil }
		return handler(match.pattern, match.values, context)
	}
}
