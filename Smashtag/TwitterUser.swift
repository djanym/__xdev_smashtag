//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/27.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TwitterUser: NSManagedObject {
	
	class func findOrCreateTwitterUser(matching twitterInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUser {
		let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
		request.predicate = NSPredicate(format: "handle = %@", twitterInfo.screenName)
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "\(#file).\(#function) -- database inconsistency")
				return matches[0]
			}
		}
		catch {
			throw error
		}
		
		let user = TwitterUser(context: context)
		user.name = twitterInfo.name
		user.handle = twitterInfo.screenName
		
		return user
	}
	
}
