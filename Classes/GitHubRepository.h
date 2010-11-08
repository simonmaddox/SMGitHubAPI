//
//  GitHubRepository.h
//  GitHub
//
//  Created by Simon Maddox on 08/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GitHubBranch;
@class GitHubUser;

@interface GitHubRepository :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * fork;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * open_issues;
@property (nonatomic, retain) NSNumber * has_downloads;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * forks;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * homepage;
@property (nonatomic, retain) NSNumber * watchers;
@property (nonatomic, retain) NSNumber * has_wiki;
@property (nonatomic, retain) NSNumber * has_issues;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * description_noClash;
@property (nonatomic, retain) NSString * pushed_at;
@property (nonatomic, retain) NSSet* watcherUsers;
@property (nonatomic, retain) GitHubUser * ownerUser;
@property (nonatomic, retain) NSSet* network;
@property (nonatomic, retain) NSSet* branches;
@property (nonatomic, retain) NSSet* contributorUsers;
@property (nonatomic, retain) NSSet* collaboratorUsers;

@end


@interface GitHubRepository (CoreDataGeneratedAccessors)
- (void)addWatcherUsersObject:(GitHubUser *)value;
- (void)removeWatcherUsersObject:(GitHubUser *)value;
- (void)addWatcherUsers:(NSSet *)value;
- (void)removeWatcherUsers:(NSSet *)value;

- (void)addNetworkObject:(GitHubRepository *)value;
- (void)removeNetworkObject:(GitHubRepository *)value;
- (void)addNetwork:(NSSet *)value;
- (void)removeNetwork:(NSSet *)value;

- (void)addBranchesObject:(GitHubBranch *)value;
- (void)removeBranchesObject:(GitHubBranch *)value;
- (void)addBranches:(NSSet *)value;
- (void)removeBranches:(NSSet *)value;

- (void)addContributorUsersObject:(GitHubUser *)value;
- (void)removeContributorUsersObject:(GitHubUser *)value;
- (void)addContributorUsers:(NSSet *)value;
- (void)removeContributorUsers:(NSSet *)value;

- (void)addCollaboratorUsersObject:(GitHubUser *)value;
- (void)removeCollaboratorUsersObject:(GitHubUser *)value;
- (void)addCollaboratorUsers:(NSSet *)value;
- (void)removeCollaboratorUsers:(NSSet *)value;

@end

