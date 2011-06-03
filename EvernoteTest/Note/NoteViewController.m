/*
 * EvernoteTest
 * NoteViewController.m
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

#import "NoteViewController.h"

#import "ImageListView.h"

@implementation NoteViewController

@synthesize guid, note;

#pragma mark - Instance method

- (void)updateContent {
	[textView setText:[self.note content]];
	
	NSArray *resources = [self.note resources];
	
	CGSize contentSize = [textView contentSize];
	float offset = contentSize.height;
	
	for (EDAMResource *resource in resources) {
		NSRange range = [[resource mime] rangeOfString:@"image/"];
		if (range.location == NSNotFound) {
		}
		else {
			UIImage *image = [UIImage imageWithData:[[resource data] body]];
			UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
			
			[textView addSubview:imageView];
			CGRect r = [imageView frame];
			
			if (r.size.width > self.view.frame.size.width) {
				r.size.height = r.size.height * self.view.frame.size.width / r.size.width;
				r.size.width = self.view.frame.size.width;
			}
			
			r.origin.y = offset;
			offset += r.size.height;
			[imageView setFrame:r];
			[imageView release];
		}
	}
	[textView setContentInset:UIEdgeInsetsMake(0, 0, offset - contentSize.height, 0)];
}

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
	self.note = [[ENManager sharedInstance] noteWithNoteGUID:guid];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateContent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
	[note release];
	[guid release];
    [super dealloc];
}


@end
