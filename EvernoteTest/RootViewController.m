/*
 * EvernoteTest
 * RootViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/05/29
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi YOSHIDA" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RootViewController.h"

#import "ENManager.h"

#import "NotebookViewController.h"

#import "CreateNotebookViewController.h"

@implementation RootViewController

@synthesize notebooks;

#pragma mark - IBAction

- (void)created:(id)sender {
	CreateNotebookViewController *con = [[CreateNotebookViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
	[con release];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[nav setModalPresentationStyle:UIModalPresentationFormSheet];
	}
	
	[self presentModalViewController:nav animated:YES];
	[nav release];
}

- (void)reload:(id)sender {
	self.notebooks = [NSArray arrayWithArray:[[ENManager sharedInstance] notebooks]];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.notebooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	id obj = [self.notebooks objectAtIndex:indexPath.row];
	
	if ([obj isKindOfClass:[EDAMNotebook class]]) {
		[cell.textLabel setText:[obj name]];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id obj = [self.notebooks objectAtIndex:indexPath.row];
	if ([obj isKindOfClass:[EDAMNotebook class]]) {
		NSLog(@"%@", [obj guid]);
		NotebookViewController *con = [[NotebookViewController alloc] initWithStyle:UITableViewStylePlain];
		[con setTitle:[obj name]];
		[con setGuid:[obj guid]];
		[self.navigationController pushViewController:con animated:YES];
	}
}

#pragma mark - Override

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Notebook", nil)];
	
	self.notebooks = [NSArray arrayWithArray:[[ENManager sharedInstance] notebooks]];
	
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
	[self.navigationItem setRightBarButtonItem:[reloadButton autorelease]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Notebook", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(created:)];
	[self.navigationController setToolbarHidden:NO animated:NO];
	[self.navigationController.toolbar setItems:[NSArray arrayWithObject:[createButton autorelease]] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
