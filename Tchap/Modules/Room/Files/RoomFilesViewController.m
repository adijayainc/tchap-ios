/*
 Copyright 2016 OpenMarket Ltd
 Copyright 2017 Vector Creations Ltd
 Copyright 2018 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RoomFilesViewController.h"

#import "FilesSearchTableViewCell.h"

#import "GeneratedInterface-Swift.h"

#import "AttachmentsViewController.h"

@interface RoomFilesViewController () <Stylable>
{
    /**
     Observe kRiotDesignValuesDidChangeThemeNotification to handle user interface theme change.
     */
    id kRiotDesignValuesDidChangeThemeNotificationObserver;
}

@property (nonatomic, strong) id<Style> currentStyle;

@end

@implementation RoomFilesViewController

#pragma mark -

+ (instancetype)instantiate
{
    RoomFilesViewController *roomFilesViewController = [RoomFilesViewController roomViewController];
    roomFilesViewController.currentStyle = Variant2Style.shared;
    return roomFilesViewController;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.autoJoinInvitedRoom = NO;
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.autoJoinInvitedRoom = NO;
    }
    
    return self;
}

#pragma mark -

- (void)finalizeInit
{
    [super finalizeInit];
    
    // Setup `MXKViewControllerHandling` properties
    self.enableBarTintColorStatusChange = NO;
    self.rageShakeManager = [RageShakeManager sharedManager];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do not show toolbar
    [self setRoomInputToolbarViewClass:nil];
    
    // set the default extra
    [self setRoomActivitiesViewClass:nil];
    
    // Custom the attachmnet viewer
    [self setAttachmentsViewerClass:AttachmentsViewController.class];
    
    // Register first customized cell view classes used to render bubbles
    [self.bubblesTableView registerClass:FilesSearchTableViewCell.class forCellReuseIdentifier:FilesSearchTableViewCell.defaultReuseIdentifier];
    
    self.bubblesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    // Hide line separators of empty cells
    self.bubblesTableView.tableFooterView = [[UIView alloc] init];
    
    [self setNavBarButtons];
    
    // Update the inputToolBar height (This will trigger a layout refresh)
    [UIView setAnimationsEnabled:NO];
    [self roomInputToolbarView:self.inputToolbarView heightDidChanged:0 completion:nil];
    [UIView setAnimationsEnabled:YES];
    
    // Observe user interface theme change.
    kRiotDesignValuesDidChangeThemeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kRiotDesignValuesDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        [self userInterfaceThemeDidChange];
        
    }];
    [self userInterfaceThemeDidChange];
}

- (void)userInterfaceThemeDidChange
{
    [self updateWithStyle:self.currentStyle];
}

- (void)updateWithStyle:(id<Style>)style
{
    self.currentStyle = style;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    if (navigationBar)
    {
        [style applyStyleOnNavigationBar:navigationBar];
    }
    
    //TODO Design the activvity indicator for Tchap
    self.activityIndicator.backgroundColor = kRiotOverlayColor;
    
    self.bubblesTableView.backgroundColor = style.backgroundColor;
    self.view.backgroundColor = self.bubblesTableView.backgroundColor;
    
    if (self.bubblesTableView.dataSource)
    {
        [self.bubblesTableView reloadData];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.currentStyle.statusBarStyle;
}

- (void)destroy
{
    [super destroy];
    
    if (kRiotDesignValuesDidChangeThemeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kRiotDesignValuesDidChangeThemeNotificationObserver];
        kRiotDesignValuesDidChangeThemeNotificationObserver = nil;
    }
}

- (void)updateViewControllerAppearanceOnRoomDataSourceState
{
    [super updateViewControllerAppearanceOnRoomDataSourceState];
    
    // Override the default title
    self.navigationItem.title = NSLocalizedStringFromTable(@"room_member_details_files", @"Tchap", nil);
}

// This method is called when the viewcontroller is added or removed from a container view controller.
- (void)didMoveToParentViewController:(nullable UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    [self setNavBarButtons];
}

- (void)setNavBarButtons
{
    // Check whether the view controller is currently displayed inside a segmented view controller or not.
    UIViewController* topViewController = ((self.parentViewController) ? self.parentViewController : self);
    topViewController.navigationItem.rightBarButtonItem = nil;
    topViewController.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - MXKDataSourceDelegate

- (Class<MXKCellRendering>)cellViewClassForCellData:(MXKCellData*)cellData
{
    Class cellViewClass = nil;
    
    // Sanity check
    if ([cellData conformsToProtocol:@protocol(MXKRoomBubbleCellDataStoring)])
    {
        id<MXKRoomBubbleCellDataStoring> bubbleData = (id<MXKRoomBubbleCellDataStoring>)cellData;
        
        // Select the suitable table view cell class
        if (bubbleData.attachment)
        {
            cellViewClass = FilesSearchTableViewCell.class;
        }
    }
    
    return cellViewClass;
}

- (NSString *)cellReuseIdentifierForCellData:(MXKCellData*)cellData
{
    Class class = [self cellViewClassForCellData:cellData];
    
    if ([class respondsToSelector:@selector(defaultReuseIdentifier)])
    {
        return [class defaultReuseIdentifier];
    }
    
    return nil;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = kRiotPrimaryBgColor;
    
    // Update the selected background view
    if (kRiotSelectedBgColor)
    {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = kRiotSelectedBgColor;
    }
    else
    {
        if (tableView.style == UITableViewStylePlain)
        {
            cell.selectedBackgroundView = nil;
        }
        else
        {
            cell.selectedBackgroundView.backgroundColor = nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.bubblesTableView)
    {
        UITableViewCell *cell = [self.bubblesTableView cellForRowAtIndexPath:indexPath];
        [self showAttachmentInCell:cell];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
