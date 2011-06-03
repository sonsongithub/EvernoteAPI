/*
 * EvernoteTest
 * NotebookViewController.m
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

#import "NotebookViewController.h"

#import "NoteViewController.h"
#import "NoteViewController_iPad.h"
#import "CreateNoteViewController.h"
#import "CreateNoteViewController_iPad.h"

@implementation NotebookViewController

@synthesize guid, notelist;

#pragma mark - IBAction

- (void)created:(id)sender {
	Class aClass = nil;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		aClass = [CreateNoteViewController_iPad class];
	else
		aClass = [CreateNoteViewController class];
	
	id con = [[aClass alloc] initWithNibName:nil bundle:nil];
	[con setNotebookGUID:guid];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
	[con release];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[nav setModalPresentationStyle:UIModalPresentationFormSheet];
	}
	
	[self presentModalViewController:nav animated:YES];
	[nav release];
}

- (void)reload:(id)sender {
	self.notelist = [[ENManager sharedInstance] notesWithNotebookGUID:guid];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.notelist notes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	id obj = [[self.notelist notes] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[obj title]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Class nextViewControllerClass = nil;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		nextViewControllerClass = [NoteViewController_iPad class];
	}
	else {
		nextViewControllerClass = [NoteViewController class];
	}
	
	id con = [[nextViewControllerClass alloc] initWithNibName:nil bundle:nil];
	id obj = [[self.notelist notes] objectAtIndex:indexPath.row];
	[con setGuid:[obj guid]];
	[con setTitle:[obj title]];
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

/*
 
// currently not supported to remove notes with API....?

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		EDAMNote *noteToBeRemoved = [[self.notelist notes] objectAtIndex:indexPath.row];
		int r = [[ENManager sharedInstance] removeNote:noteToBeRemoved];
		DNSLog(@"%d", r);
		self.notelist = [[ENManager sharedInstance] notesWithNotebookGUID:guid];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
	}
}
 
 */

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
	self.notelist = [[ENManager sharedInstance] notesWithNotebookGUID:guid];
	
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
	[self.navigationItem setRightBarButtonItem:[reloadButton autorelease]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Note", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(created:)];
	[self.navigationController.toolbar setItems:[NSArray arrayWithObject:[createButton autorelease]] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
	[guid release];
	[notelist release];
    [super dealloc];
}

@end
