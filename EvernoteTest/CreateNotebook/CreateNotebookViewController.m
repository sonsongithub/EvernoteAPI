/*
 * EvernoteTest
 * CreateNotebookViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/05/30
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

#import "CreateNotebookViewController.h"

#import "ENManager.h"

@implementation CreateNotebookViewController

#pragma mark - IBAction

- (void)created:(id)sender {
	NSString *title = [notebookNameField text];
	if ([title length] > 0) {
		[[ENManager sharedInstance] createNewNotebookWithTitle:title];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)cancelled:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Override

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[notebookNameField setText:@""];
	[self setTitle:NSLocalizedString(@"New notebook", nil)];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelled:)];
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(created:)];
	[self.navigationItem setLeftBarButtonItem:[cancelButton autorelease]];
	[self.navigationItem setRightBarButtonItem:[createButton autorelease]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[notebookNameField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
