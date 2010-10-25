#import "InstructionsViewController.h"
#import "UpnpServer.h"


@interface InstructionsViewController ()
@property (nonatomic, retain) DirectoryWatcher *directoryWatcher;
@property (nonatomic, retain) NSMutableArray *documentUrls;
@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;
@end


@implementation InstructionsViewController

@synthesize directoryWatcher = directoryWatcher_;
@synthesize documentUrls = documentUrls_;
@synthesize docInteractionController = docInteractionController_;
@synthesize addFromiTunesView = addFromiTunesView_;
@synthesize tableView = tableView_;


#pragma mark -
#pragma mark InstructionsViewController

- (void)dealloc
{
    [directoryWatcher_ release];
    [documentUrls_ release];
    [docInteractionController_ release];
    [addFromiTunesView_ release];
    [tableView_ release];

    [super dealloc];
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (NSString *)formattedFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
    if (size == 0)
    {
		formattedStr = @"Empty";
    }
	else
    {
		if (size > 0 && size < 1024) 
        {
			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        }
        else 
        {
            if (size >= 1024 && size < pow(1024, 2)) 
            {
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            }
            else 
            {
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                {
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                }
                else 
                {
                    if (size >= pow(1024, 3)) 
                    {
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
                    }
                }
            }
        }
    }
	
	return formattedStr;
}


#pragma mark -
#pragma mark DirectoryWatcherDelegate

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentUrls removeAllObjects];	

    NSArray *files = [UpnpServer documentsDirectoryContents];
    if (files == nil || [files count] == 0)
    {
        //self.addFromiTunesView.hidden = NO;
        //self.tableView.hidden = YES;
    }
    else
    {        
        // Iterates through all files in the Documents directory
        for (NSString* file in [files objectEnumerator])
        {
            NSString *filePath = [[UpnpServer filePath] stringByAppendingPathComponent:file];
            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
            
            // Add the document URL to our list (ignore the "Inbox" folder)
            if (!(isDirectory && [file isEqualToString: @"Inbox"]))
            {
                [self.documentUrls addObject:fileUrl];
            }
        }
        
        [self.tableView reloadData];
        
        //self.addFromiTunesView.hidden = YES;
        //self.tableView.hidden = NO;
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.tableView.backgroundColor = [UIColor clearColor];
    
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-iPad.png"]];    
//    self.tableView.opaque = NO;

    
//    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-iPad.png"]];
//    self.view.backgroundColor = background;
//    [background release];
    
    //[self.tableView addSubview:self.imageView];
    //[self.view addSubview:self.tableView];
    
    //self.tableView.backgroundColor = [UIColor clearColor];

    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-iPad.png"]];
    
    // Start monitoring the document directory
    NSMutableArray *documentUrls = [[NSMutableArray alloc] init];
    self.documentUrls = documentUrls;
    [documentUrls release];
    self.directoryWatcher = [DirectoryWatcher watchFolderWithPath:[UpnpServer filePath] delegate:self];
    
    // Switch views based on if files in directory
    [self directoryDidChange:self.directoryWatcher];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Supports all orientations
    return YES;
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.documentUrls.count;    
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    NSURL *fileUrl = [self.documentUrls objectAtIndex:indexPath.row];
	[self setupDocumentControllerWithURL:fileUrl];
	
    // Layout the cell
    cell.textLabel.text = [[fileUrl path] lastPathComponent];
    NSInteger iconCount = [self.docInteractionController.icons count];
    if (iconCount > 0)
    {
        cell.imageView.image = [self.docInteractionController.icons objectAtIndex:iconCount - 1];
    }
    
    NSError *error;
    NSString *fileUrlString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileUrlString error:&error];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                 [self formattedFileSize:fileSize], self.docInteractionController.UTI];
    
    return cell;
}


#pragma mark -
#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}











@end