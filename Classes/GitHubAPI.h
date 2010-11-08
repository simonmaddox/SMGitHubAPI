//
//  GitHubAPI.h
//  GitHub
//
//  Created by Simon Maddox on 07/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GitHubUser, GitHubPlan, GitHubRepository, GitHubBranch, GitHubCommit;

@interface GitHubAPI : NSObject {	
	@private
	
	BOOL httpRequestComplete;
	NSDictionary *lastFetch;
	NSError *lastError;
	
	// CoreData
	NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) GitHubUser *me;

#pragma mark -
#pragma mark Authentication

- (BOOL) authenticateWithUsername:(NSString *)gitHubUsername password:(NSString *)gitHubPassword;

#pragma mark -
#pragma mark User

- (void) addRepositoriesToUser:(GitHubUser *) user;
- (GitHubUser *) userForUsername:(NSString *)gitHubUsername;

#pragma mark -
#pragma mark Repository

- (void) addAllDataToRepository:(GitHubRepository *) repo;

- (void) addExtraUsersToRepository:(GitHubRepository *) repo;

- (void) addCollaboratorsToRepository:(GitHubRepository *) repo;
- (void) addWatchersToRepository:(GitHubRepository *)repo;
- (void) addContributorsToRepository:(GitHubRepository *) repo;

- (void) addNetworkToRepository:(GitHubRepository *) repo;
- (void) addBranchesToRepository:(GitHubRepository *)repo;

- (void) addCommitsForBranch:(GitHubBranch *) branch;

@end
