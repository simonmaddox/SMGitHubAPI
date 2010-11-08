//
//  GitHubViewController.m
//  GitHub
//
//  Created by Simon Maddox on 07/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import "GitHubViewController.h"
#import "GitHubAPI.h"

#import "GitHubUser.h"
#import "GitHubRepository.h"

@implementation GitHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	GitHubAPI *gitHub = [[GitHubAPI alloc] init];
	BOOL loggedIn = [gitHub authenticateWithUsername:@"simonmaddox" password:@"MYPASS"];
	
	if (loggedIn){
		NSLog(@"Logged in as %@", [[gitHub me] name]);
	} else {
		NSLog(@"Failed to Login");
		return;
	}
	
	[gitHub addRepositoriesToUser:[gitHub me]];
	
	for (GitHubRepository *repo in [[gitHub me] repositories]){
		[gitHub addAllDataToRepository:repo];
		NSLog(@"%@", repo);
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
