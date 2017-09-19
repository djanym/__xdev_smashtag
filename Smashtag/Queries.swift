//
//  Queries.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/19.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import Foundation

struct Queries {
	private static let defaults = UserDefaults.standard
	private static let limit = 20
	
	static var terms: [String] {
		get {
			if let data = defaults.object(forKey: "searchTerms") as? [String] {
				return data
			}
			else { return [String]() }
		}
		set {
			defaults.set(newValue, forKey: "searchTerms")
		}
	}
	
	static func add(search: String?){
		guard let term = search else { return }
		guard !term.isEmpty else { return }
		
		var newArray = terms.filter({ term.caseInsensitiveCompare($0) != .orderedSame })
		newArray.insert( term, at: 0)
		
		while newArray.count > limit {
			newArray.removeLast()
		}
		terms = newArray
	}
	
	static func remove(term: String){
		terms = terms.filter({ term.caseInsensitiveCompare($0) != .orderedSame })
	}
	
	/*
	static func add(_ term: String) {
		var newArray = searches.filter {term.caseInsensitiveCompare($0) != .orderedSame}
		newArray.insert(term, at: 0)
		while newArray.count > limit {
			newArray.removeLast()
		}
		defaults.set(newArray, forKey:key)
	}
	
	static func removeAtIndex(_ index: Int) {
		var currentSearches = (defaults.object(forKey: key) as? [String]) ?? []
		currentSearches.remove(at: index)
		defaults.set(currentSearches, forKey:key)
	}
*/
}
