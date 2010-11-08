//
//  GitHubUser.h
//  GitHub
//
//  Created by Simon Maddox on 08/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GitHubPlan;
@class GitHubRepository;

@interface GitHubUser :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * private_gist_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSNumber * collaborators;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * owned_private_repo_count;
@property (nonatomic, retain) NSNumber * total_private_repo_count;
@property (nonatomic, retain) NSNumber * public_repo_count;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * public_gist_count;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * followers_count;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * blog;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSNumber * disk_usage;
@property (nonatomic, retain) NSString * gravatar_id;
@property (nonatomic, retain) GitHubPlan * plan;
@property (nonatomic, retain) NSSet* watchedRepositories;
@property (nonatomic, retain) NSSet* commits;
@property (nonatomic, retain) NSSet* collaboratorRepositores;
@property (nonatomic, retain) NSSet* authoredCommits;
@property (nonatomic, retain) NSSet* contributorRepositories;
@property (nonatomic, retain) NSSet* repositories;

@end


@interface GitHubUser (CoreDataGeneratedAccessors)
- (void)addWatchedRepositoriesObject:(GitHubRepository *)value;
- (void)removeWatchedRepositoriesObject:(GitHubRepository *)value;
- (void)addWatchedRepositories:(NSSet *)value;
- (void)removeWatchedRepositories:(NSSet *)value;

- (void)addCommitsObject:(NSManagedObject *)value;
- (void)removeCommitsObject:(NSManagedObject *)value;
- (void)addCommits:(NSSet *)value;
- (void)removeCommits:(NSSet *)value;

- (void)addCollaboratorRepositoresObject:(GitHubRepository *)value;
- (void)removeCollaboratorRepositoresObject:(GitHubRepository *)value;
- (void)addCollaboratorRepositores:(NSSet *)value;
- (void)removeCollaboratorRepositores:(NSSet *)value;

- (void)addAuthoredCommitsObject:(NSManagedObject *)value;
- (void)removeAuthoredCommitsObject:(NSManagedObject *)value;
- (void)addAuthoredCommits:(NSSet *)value;
- (void)removeAuthoredCommits:(NSSet *)value;

- (void)addContributorRepositoriesObject:(GitHubRepository *)value;
- (void)removeContributorRepositoriesObject:(GitHubRepository *)value;
- (void)addContributorRepositories:(NSSet *)value;
- (void)removeContributorRepositories:(NSSet *)value;

- (void)addRepositoriesObject:(GitHubRepository *)value;
- (void)removeRepositoriesObject:(GitHubRepository *)value;
- (void)addRepositories:(NSSet *)value;
- (void)removeRepositories:(NSSet *)value;

@end

