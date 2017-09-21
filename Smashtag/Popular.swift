//
//  Popular.swift
//  Smashtag
//
//  Created by Naili Concescu on 1439/1/1.
//  Copyright © 1439 Naili Concescu. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Popular: NSManagedObject {
	class func addOrUpdateMentions(from tweetInfo: Twitter.Tweet, for searchTerm: String, in context: NSManagedObjectContext) throws {
		let request: NSFetchRequest<Popular> = Popular.fetchRequest()
		request.predicate = NSPredicate(format: "term = %@ AND type = %@ AND mention = %@", searchTerm, "tweeter", tweetInfo.user.screenName)
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "\(#file).\(#function) -- database inconsistency")
				matches.first?.count += 1
			}
			else {
				let mention = Popular(context: context)
				mention.term = searchTerm
				mention.type = "tweeter"
				mention.mention = tweetInfo.user.screenName
				mention.count = 1
			}
		}
		catch {
			throw error
		}
		
		// Add hashtags
		if tweetInfo.hashtags.count > 0 {
			for tag in tweetInfo.hashtags {
				request.predicate = NSPredicate(format: "term = %@ AND type = %@ AND mention = %@", searchTerm, "hashtag", tag.keyword)
				do {
					let matches = try context.fetch(request)
					if matches.count > 0 {
						assert(matches.count == 1, "\(#file).\(#function) -- database inconsistency")
						matches.first?.count += 1
					}
					else {
						let mention = Popular(context: context)
						mention.term = searchTerm
						mention.type = "hashtag"
						mention.mention = tag.keyword
						mention.count = 1
					}
				}
				catch {
					throw error
				}
			}
		}
	}
}
