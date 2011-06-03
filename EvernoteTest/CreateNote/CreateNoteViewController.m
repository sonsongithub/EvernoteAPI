/*
 * EvernoteTest
 * CreateNoteViewController.m
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

#import "CreateNoteViewController.h"
#import "ImageListView.h"
#import "QuartzHelpLibrary.h"

@implementation CreateNoteViewController

@synthesize notebookGUID;

#pragma mark - Instance method

- (void)sendOnlyText {
	NSString *title = [titleField text];
	NSString *body = [bodyView text];
	
	if ([title length] == 0) {
		title = @"Untitled";
	}
	
	NSMutableString *contentString = [NSMutableString string];
	[contentString setString:	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[contentString appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">"];
	[contentString appendString:@"<en-note>"];
	[contentString appendString:body];
	[contentString appendString:@"</en-note>"];
	
	if ([body length]) {
		[[ENManager sharedInstance] createNote2Notebook:notebookGUID title:title content:contentString];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)sendTextAndImage {
	NSString *title = [titleField text];
	NSString *body = [bodyView text];
	
	if ([title length] == 0) {
		title = @"Untitled";
	}
	
	NSMutableString *contentString = [NSMutableString string];
	[contentString setString:	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[contentString appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">"];
	[contentString appendString:@"<en-note>"];
	if ([body length]) {
		[contentString appendString:body];
		@try {
			NSMutableArray *resources = [NSMutableArray array];
			for (ImageListView *v in imageViews) {
				UIImage *i = [v.contentView image];
				NSData *imgBinary = UIImageJPEGRepresentation(i, 1);
				
				EDAMData *data = [[EDAMData alloc] initWithBodyHash:[imgBinary md5Hash] size:[imgBinary length] body:imgBinary];
				EDAMResource *resource = [[EDAMResource alloc] init];
				[resource setData:data];
				[resource setNoteGuid:notebookGUID];
				[resource setMime:@"image/jpg"];
				[contentString appendFormat:@"<en-media type=\"image/png\" hash=\"%@\"/><br/>", [imgBinary md5HexHash]];
				
				[resources addObject:resource];
			}
			[contentString appendString:@"</en-note>"];
			[[ENManager sharedInstance] createNote2Notebook:notebookGUID title:title content:contentString resources:resources];
		}
		@catch (NSException *exception) {
			NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
		}
		@finally {
		}
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)updateHeader {
	float offset = TITLE_INPUT_FIELD_HEIGHT;
	[UIView beginAnimations:@"" context:nil];
	[bodyView addSubview:titleHeaderView];
	[bodyView setAutoresizesSubviews:YES];
	CGRect r = [titleHeaderView frame];
	r.size.width = bodyView.frame.size.width;
	r.origin.y = -r.size.height - [imageViews count] * [ImageListView height];
	[titleHeaderView setFrame:r];
	
	for (UIView *view in imageViews) {
		float y = ([imageViews count] - [imageViews indexOfObject:view]) * [ImageListView height];
		CGRect r = view.frame;
		r.size.width = bodyView.frame.size.width;
		r.origin.y = -y;
		[view setFrame:r];
		offset += [ImageListView height];
		[bodyView addSubview:view];
	}
	
	UIEdgeInsets insets = [bodyView contentInset];
	insets.top = offset;
	[bodyView setContentInset:insets];
	[UIView commitAnimations];
}

- (void)addImageToArrayWithInfo:(NSDictionary*)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	float s = DEFAULT_IMAGE_LIST_WIDTH / image.size.width;
	CGImageRef resizedCGImage =[image createCGImageRotatedWithResizing:s];
	
	UINib* nib = nil;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		nib = [UINib nibWithNibName:@"ImageListView_iPad" bundle:nil];
	else
		nib = [UINib nibWithNibName:@"ImageListView" bundle:nil];
	
	NSArray* array = [nib instantiateWithOwner:nil options:nil];
	ImageListView *v = [array objectAtIndex:0];
	[v.contentView setImage:[UIImage imageWithCGImage:resizedCGImage]];
	[v setDelegate:self];
	[imageViews addObject:v];
	[self updateHeader];
}

#pragma mark - IBAction

- (void)created:(id)sender {
	
	if ([imageViews count]) {
		[self sendTextAndImage];
	}
	else {
		[self sendOnlyText];
	}
}

- (void)didDeleteImageListView:(ImageListView*)sender {
	[imageViews removeObject:sender];
	[sender removeFromSuperview];
	[self updateHeader];
}

- (void)addImage:(id)sender {
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	[controller setDelegate:self];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[controller setSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)cancelled:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Keyboard

- (void)UIKeyboardWillShowNotification:(NSNotification*)notification {
	DNSLogMethod
	CGRect start = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	start = [[[UIApplication sharedApplication] keyWindow] convertRect:start toView:self.view];
	end = [[[UIApplication sharedApplication] keyWindow] convertRect:end toView:self.view];
	
	CGRect r = bodyView.frame;
	r.size.height = end.origin.y;
	[bodyView setFrame:r];
}

- (void)UIKeyboardWillHideNotification:(NSNotification*)notification {
	DNSLogMethod
	CGRect start = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	start = [[[UIApplication sharedApplication] keyWindow] convertRect:start toView:self.view];
	end = [[[UIApplication sharedApplication] keyWindow] convertRect:end toView:self.view];
	
	CGRect r = bodyView.frame;
	r.size.height = end.origin.y;
	[bodyView setFrame:r];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self addImageToArrayWithInfo:info];
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Override

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[bodyView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:NSLocalizedString(@"New note", nil)];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelled:)];
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(created:)];
	[self.navigationItem setLeftBarButtonItem:[cancelButton autorelease]];
	[self.navigationItem setRightBarButtonItem:[createButton autorelease]];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImage:)];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
	[self.navigationController.toolbar setItems:[NSArray arrayWithObject:[createButton autorelease]] animated:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		imageViews = [[NSMutableArray array] retain];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		imageViews = [[NSMutableArray array] retain];
	}
	return self;
}

- (void)viewDidLoad {
	DNSLogMethod
    [super viewDidLoad];
	
	[self updateHeader];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[imageViews release];
	[notebookGUID release];
    [super dealloc];
}

@end
