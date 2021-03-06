/*
 Copyright 2014 OpenMarket Ltd
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

#import "RoomViewController.h"

#import "RoomDataSource.h"
#import "RoomBubbleCellData.h"

#import "RoomInputToolbarView.h"
#import "DisabledRoomInputToolbarView.h"

#import "RoomActivitiesView.h"

#import "AttachmentsViewController.h"

#import "EventDetailsView.h"
#import "PreviewView.h"

#import "RoomMemberDetailsViewController.h"

#import "SegmentedViewController.h"

#import "UsersDevicesViewController.h"

#import "ReadReceiptsViewController.h"

#import "JitsiViewController.h"

#import "RoomEmptyBubbleCell.h"

#import "RoomIncomingTextMsgBubbleCell.h"
#import "RoomIncomingTextMsgWithoutSenderInfoBubbleCell.h"
#import "RoomIncomingTextMsgWithPaginationTitleBubbleCell.h"
#import "RoomIncomingTextMsgWithoutSenderNameBubbleCell.h"
#import "RoomIncomingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.h"
#import "RoomIncomingAttachmentBubbleCell.h"
#import "RoomIncomingAttachmentWithoutSenderInfoBubbleCell.h"
#import "RoomIncomingAttachmentWithPaginationTitleBubbleCell.h"

#import "RoomIncomingEncryptedTextMsgBubbleCell.h"
#import "RoomIncomingEncryptedTextMsgWithoutSenderInfoBubbleCell.h"
#import "RoomIncomingEncryptedTextMsgWithPaginationTitleBubbleCell.h"
#import "RoomIncomingEncryptedTextMsgWithoutSenderNameBubbleCell.h"
#import "RoomIncomingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.h"
#import "RoomIncomingEncryptedAttachmentBubbleCell.h"
#import "RoomIncomingEncryptedAttachmentWithoutSenderInfoBubbleCell.h"
#import "RoomIncomingEncryptedAttachmentWithPaginationTitleBubbleCell.h"

#import "RoomOutgoingTextMsgBubbleCell.h"
#import "RoomOutgoingTextMsgWithoutSenderInfoBubbleCell.h"
#import "RoomOutgoingTextMsgWithPaginationTitleBubbleCell.h"
#import "RoomOutgoingTextMsgWithoutSenderNameBubbleCell.h"
#import "RoomOutgoingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.h"
#import "RoomOutgoingAttachmentBubbleCell.h"
#import "RoomOutgoingAttachmentWithoutSenderInfoBubbleCell.h"
#import "RoomOutgoingAttachmentWithPaginationTitleBubbleCell.h"

#import "RoomOutgoingEncryptedTextMsgBubbleCell.h"
#import "RoomOutgoingEncryptedTextMsgWithoutSenderInfoBubbleCell.h"
#import "RoomOutgoingEncryptedTextMsgWithPaginationTitleBubbleCell.h"
#import "RoomOutgoingEncryptedTextMsgWithoutSenderNameBubbleCell.h"
#import "RoomOutgoingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.h"
#import "RoomOutgoingEncryptedAttachmentBubbleCell.h"
#import "RoomOutgoingEncryptedAttachmentWithoutSenderInfoBubbleCell.h"
#import "RoomOutgoingEncryptedAttachmentWithPaginationTitleBubbleCell.h"

#import "RoomMembershipBubbleCell.h"
#import "RoomMembershipWithPaginationTitleBubbleCell.h"
#import "RoomMembershipCollapsedBubbleCell.h"
#import "RoomMembershipCollapsedWithPaginationTitleBubbleCell.h"
#import "RoomMembershipExpandedBubbleCell.h"
#import "RoomMembershipExpandedWithPaginationTitleBubbleCell.h"

#import "RoomAttachmentAntivirusScanStatusBubbleCell.h"
#import "RoomAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.h"
#import "RoomAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.h"
#import "RoomEncryptedAttachmentAntivirusScanStatusBubbleCell.h"
#import "RoomEncryptedAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.h"
#import "RoomEncryptedAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.h"

#import "RoomSelectedStickerBubbleCell.h"
#import "RoomPredecessorBubbleCell.h"

#import "MXKRoomBubbleTableViewCell+Riot.h"

#import "AvatarGenerator.h"
#import "Tools.h"
#import "WidgetManager.h"

#import "GBDeviceInfo_iOS.h"

#import "RoomEncryptedDataBubbleCell.h"
#import "EncryptionInfoView.h"

#import "MXRoom+Riot.h"

#import "IntegrationManagerViewController.h"
#import "WidgetPickerViewController.h"
#import "StickerPickerViewController.h"

#import "EventFormatter.h"
#import <MatrixKit/MXKSlashCommands.h>

#import "MXSession+Riot.h"
#import "RoomPreviewData.h"

#import "GeneratedInterface-Swift.h"

NSString *const RoomErrorDomain = @"RoomErrorDomain";

@interface RoomViewController () <UIGestureRecognizerDelegate, Stylable, RoomTitleViewDelegate, MXServerNoticesDelegate>
{
    // The preview header
    PreviewView *previewHeader;
    
    // The customized room data source for Vector
    RoomDataSource *customizedRoomDataSource;
    
    // List of members who are typing in the room.
    NSArray *currentTypingUsers;
    
    // Typing notifications listener.
    id typingNotifListener;
    
    // Missed discussions badge
    NSUInteger missedDiscussionsCount;
    NSUInteger missedHighlightCount;
    UIBarButtonItem *missedDiscussionsButton;
    UILabel *missedDiscussionsBadgeLabel;
    UIView  *missedDiscussionsBadgeLabelBgView;
    UIView  *missedDiscussionsBarButtonCustomView;
    
    // Potential encryption details view.
    EncryptionInfoView *encryptionInfoView;
    
    // The list of unknown devices that prevent outgoing messages from being sent
    MXUsersDevicesMap<MXDeviceInfo*> *unknownDevices;
    
    // Observe kAppDelegateDidTapStatusBarNotification to handle tap on clock status bar.
    id kAppDelegateDidTapStatusBarNotificationObserver;
    
    // Observe kAppDelegateNetworkStatusDidChangeNotification to handle network status change.
    id kAppDelegateNetworkStatusDidChangeNotificationObserver;

    // Observers to manage MXSession state (and sync errors)
    id kMXSessionStateDidChangeObserver;

    // Observers to manage ongoing conference call banner
    id kMXCallStateDidChangeObserver;
    id kMXCallManagerConferenceStartedObserver;
    id kMXCallManagerConferenceFinishedObserver;

    // Observers to manage widgets
    id kMXKWidgetManagerDidUpdateWidgetObserver;
    
    // Observer kMXRoomSummaryDidChangeNotification to keep updated the missed discussion count
    id mxRoomSummaryDidChangeObserver;

    // Observer for removing the re-request explanation/waiting dialog
    id mxEventDidDecryptNotificationObserver;
    
    // The table view cell in which the read marker is displayed (nil by default).
    MXKRoomBubbleTableViewCell *readMarkerTableViewCell;
    
    // Tell whether the view controller is appeared or not.
    BOOL isAppeared;
    
    // The right bar button items back up.
    NSArray<UIBarButtonItem *> *rightBarButtonItems;
    
    // Tell whether the input text field is in send reply mode. If true typed message will be sent to highlighted event.
    BOOL isInReplyMode;
    
    // Listener for `m.room.tombstone` event type
    id tombstoneEventNotificationsListener;

    // Homeserver notices
    MXServerNotices *serverNotices;
}


// The preview header
@property (weak, nonatomic) IBOutlet UIView *previewHeaderContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeaderContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeaderContainerHeightConstraint;

// The jump to last unread banner
@property (weak, nonatomic) IBOutlet UIView *jumpToLastUnreadBannerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jumpToLastUnreadBannerContainerTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *jumpToLastUnreadButton;
@property (weak, nonatomic) IBOutlet UILabel *jumpToLastUnreadLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetReadMarkerButton;

@property (nonatomic, weak) RoomTitleView *roomTitleView;
@property (nonatomic, strong) id<Style> currentStyle;

// Direct chat target user when create a discussion without associated room
@property (nonatomic, strong) User *discussionTargetUser;

// Observe kRiotDesignValuesDidChangeThemeNotification to handle user interface theme change.
@property (nonatomic, weak) id themeDidChangeNotificationObserver;

/**
 Action used to handle some buttons.
 */
- (IBAction)onButtonPressed:(id)sender;

@end

@implementation RoomViewController
@synthesize roomPreviewData;

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass(self.class)
                          bundle:[NSBundle bundleForClass:self.class]];
}

+ (nonnull instancetype)instantiate
{
    RoomViewController *roomViewController = [[[self class] alloc] initWithNibName:NSStringFromClass(self.class)
                                                                            bundle:[NSBundle bundleForClass:self.class]];
    roomViewController.currentStyle = Variant2Style.shared;
    return roomViewController;
}

+ (nonnull instancetype)instantiateWithDiscussionTargetUser:(nonnull User*)discussionTargetUser session:(nonnull MXSession*)session
{
    RoomViewController *roomViewController = [self instantiate];
    roomViewController.discussionTargetUser = discussionTargetUser;
    [roomViewController addMatrixSession:session];
    return roomViewController;
}

#pragma mark -

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Disable auto join
        self.autoJoinInvitedRoom = NO;
        
        // Disable auto scroll to bottom on keyboard presentation
        self.scrollHistoryToTheBottomOnKeyboardPresentation = NO;
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Disable auto join
        self.autoJoinInvitedRoom = NO;
        
        // Disable auto scroll to bottom on keyboard presentation
        self.scrollHistoryToTheBottomOnKeyboardPresentation = NO;
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
    
    _showMissedDiscussionsBadge = NO;
    
    
    // Listen to the event sent state changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidChangeSentState:) name:kMXEventDidChangeSentStateNotification object:nil];
}

- (void)setupRoomTitleView {
    
    if (!self.roomTitleView) {
        RoomTitleView *roomTitleView = [RoomTitleView instantiateWithStyle:Variant2Style.shared];
        roomTitleView.delegate = self;
        self.navigationItem.titleView = roomTitleView;
        self.roomTitleView = roomTitleView;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register first customized cell view classes used to render bubbles
    [self.bubblesTableView registerClass:RoomIncomingTextMsgBubbleCell.class forCellReuseIdentifier:RoomIncomingTextMsgBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingTextMsgWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomIncomingTextMsgWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingTextMsgWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomIncomingTextMsgWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingAttachmentBubbleCell.class forCellReuseIdentifier:RoomIncomingAttachmentBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingAttachmentWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomIncomingAttachmentWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingAttachmentWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomIncomingAttachmentWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingTextMsgWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomIncomingTextMsgWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomIncomingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomIncomingEncryptedTextMsgBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedTextMsgBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedTextMsgWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedTextMsgWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedTextMsgWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedTextMsgWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedAttachmentBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedAttachmentBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedAttachmentWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedAttachmentWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedAttachmentWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedAttachmentWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedTextMsgWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedTextMsgWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomIncomingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomIncomingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomOutgoingAttachmentBubbleCell.class forCellReuseIdentifier:RoomOutgoingAttachmentBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingAttachmentWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomOutgoingAttachmentWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingAttachmentWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomOutgoingAttachmentWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingTextMsgBubbleCell.class forCellReuseIdentifier:RoomOutgoingTextMsgBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingTextMsgWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomOutgoingTextMsgWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingTextMsgWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomOutgoingTextMsgWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingTextMsgWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomOutgoingTextMsgWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomOutgoingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedAttachmentBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedAttachmentBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedAttachmentWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedAttachmentWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedAttachmentWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedAttachmentWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedTextMsgBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedTextMsgBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedTextMsgWithoutSenderInfoBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedTextMsgWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedTextMsgWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedTextMsgWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedTextMsgWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedTextMsgWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomOutgoingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class forCellReuseIdentifier:RoomOutgoingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomEmptyBubbleCell.class forCellReuseIdentifier:RoomEmptyBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomMembershipBubbleCell.class forCellReuseIdentifier:RoomMembershipBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomMembershipWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomMembershipWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomMembershipCollapsedBubbleCell.class forCellReuseIdentifier:RoomMembershipCollapsedBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomMembershipCollapsedWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomMembershipCollapsedWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomMembershipExpandedBubbleCell.class forCellReuseIdentifier:RoomMembershipExpandedBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomMembershipExpandedWithPaginationTitleBubbleCell.class forCellReuseIdentifier:RoomMembershipExpandedWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerClass:RoomSelectedStickerBubbleCell.class forCellReuseIdentifier:RoomSelectedStickerBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerClass:RoomPredecessorBubbleCell.class forCellReuseIdentifier:RoomPredecessorBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerNib:RoomAttachmentAntivirusScanStatusBubbleCell.nib forCellReuseIdentifier:RoomAttachmentAntivirusScanStatusBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerNib:RoomAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.nib forCellReuseIdentifier:RoomAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerNib:RoomAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.nib forCellReuseIdentifier:RoomAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    
    [self.bubblesTableView registerNib:RoomEncryptedAttachmentAntivirusScanStatusBubbleCell.nib forCellReuseIdentifier:RoomEncryptedAttachmentAntivirusScanStatusBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerNib:RoomEncryptedAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.nib forCellReuseIdentifier:RoomEncryptedAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.defaultReuseIdentifier];
    [self.bubblesTableView registerNib:RoomEncryptedAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.nib forCellReuseIdentifier:RoomEncryptedAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.defaultReuseIdentifier];
    
    
    // Replace the default input toolbar view.
    // Note: this operation will force the layout of subviews. That is why cell view classes must be registered before.
    [self updateRoomInputToolbarViewClassIfNeeded];
    
    // set extra area
    [self setRoomActivitiesViewClass:RoomActivitiesView.class];
    
    // Custom the attachmnet viewer
    [self setAttachmentsViewerClass:AttachmentsViewController.class];
    
    // Custom the event details view
    [self setEventDetailsViewClass:EventDetailsView.class];
    
    // Update navigation bar items
    for (UIBarButtonItem *barButtonItem in self.navigationItem.rightBarButtonItems)
    {
        barButtonItem.target = self;
        barButtonItem.action = @selector(onButtonPressed:);
    }

    // Prepare missed dicussion badge (if any)
    self.showMissedDiscussionsBadge = _showMissedDiscussionsBadge;
    
    [self setupRoomTitleView];
    
    // Set up the room title view according to the data source (if any)
    [self refreshRoomTitle];
    
    // Refresh tool bar if the room data source is set.
    if (self.roomDataSource)
    {
        [self refreshRoomInputToolbar];
    }
    
    // Observe user interface theme change.
    MXWeakify(self);
    _themeDidChangeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kRiotDesignValuesDidChangeThemeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        MXStrongifyAndReturnIfNil(self);
        [self userInterfaceThemeDidChange];
        
    }];
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
    
    // @TODO Design the activvity indicator for Tchap
    self.activityIndicator.backgroundColor = kRiotOverlayColor;
    
    // Prepare jump to last unread banner
    self.jumpToLastUnreadBannerContainer.backgroundColor = style.secondaryBackgroundColor;
    self.jumpToLastUnreadLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"room_jump_to_first_unread", @"Vector", nil) attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName:style.secondaryTextColor, NSForegroundColorAttributeName:style.secondaryTextColor}];
    
    
    self.previewHeaderContainer.backgroundColor = style.backgroundColor;
    if (previewHeader)
    {
        [previewHeader customizeViewRendering];
    }
    
    missedDiscussionsBadgeLabel.textColor = style.primaryTextColor;
    missedDiscussionsBadgeLabel.font = [UIFont boldSystemFontOfSize:14];
    missedDiscussionsBadgeLabel.backgroundColor = [UIColor clearColor];
    
    // Check the table view style to select its bg color.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Screen tracking
    [[Analytics sharedInstance] trackScreen:@"ChatRoom"];
    
    // Refresh the room title view
    [self refreshRoomTitle];
    
    // Refresh tool bar if the room data source is set.
    if (self.roomDataSource)
    {
        [self refreshRoomInputToolbar];
    }
    
    [self listenTypingNotifications];
    [self listenCallNotifications];
    [self listenWidgetNotifications];
    [self listenTombstoneEventNotifications];
    [self listenMXSessionStateChangeNotifications];
    
    // Observe kAppDelegateDidTapStatusBarNotification.
    kAppDelegateDidTapStatusBarNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kAppDelegateDidTapStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        [self.bubblesTableView setContentOffset:CGPointMake(-self.bubblesTableView.mxk_adjustedContentInset.left, -self.bubblesTableView.mxk_adjustedContentInset.top) animated:YES];
        
    }];
    
    [self userInterfaceThemeDidChange];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide action
    if (currentAlert)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];
        currentAlert = nil;
    }
    
    [self removeTypingNotificationsListener];
    
    if (customizedRoomDataSource)
    {
        // Cancel potential selected event (to leave edition mode)
        if (customizedRoomDataSource.selectedEventId)
        {
            [self cancelEventSelection];
        }
    }
    
    if (kAppDelegateDidTapStatusBarNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kAppDelegateDidTapStatusBarNotificationObserver];
        kAppDelegateDidTapStatusBarNotificationObserver = nil;
    }
    
    [self removeCallNotificationsListeners];
    [self removeWidgetNotificationsListeners];
    [self removeTombstoneEventNotificationsListener];
    [self removeMXSessionStateChangeNotificationsListener];

    // Re-enable the read marker display, and disable its update.
    self.roomDataSource.showReadMarker = YES;
    self.updateRoomReadMarker = NO;
    isAppeared = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    isAppeared = YES;
    [self checkReadMarkerVisibility];
    
    if (self.roomDataSource)
    {
        // Set visible room id
        [AppDelegate theDelegate].visibleRoomId = self.roomDataSource.roomId;
    }
    
    // Observe network reachability
    kAppDelegateNetworkStatusDidChangeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kAppDelegateNetworkStatusDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        [self refreshActivitiesViewDisplay];
        
    }];
    [self refreshActivitiesViewDisplay];
    [self refreshJumpToLastUnreadBannerDisplay];
    
    // Observe missed notifications
    mxRoomSummaryDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXRoomSummaryDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {

        MXRoomSummary *roomSummary = notif.object;

        if ([roomSummary.roomId isEqualToString:self.roomDataSource.roomId])
        {
            [self refreshMissedDiscussionsCount:NO];
            [self refreshRoomTitle];
        }
    }];
    [self refreshMissedDiscussionsCount:YES];
    
//    // Warn about the beta state of e2e encryption when entering the first time in an encrypted room
//    MXKAccount *account = [[MXKAccountManager sharedManager] accountForUserId:self.roomDataSource.mxSession.myUser.userId];
//    if (account && !account.isWarnedAboutEncryption && self.roomDataSource.room.summary.isEncrypted)
//    {
//        [currentAlert dismissViewControllerAnimated:NO completion:nil];
//        
//        __weak __typeof(self) weakSelf = self;
//        currentAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"warning", @"Vector", nil)
//                                                           message:NSLocalizedStringFromTable(@"room_warning_about_encryption", @"Vector", nil)
//                                                    preferredStyle:UIAlertControllerStyleAlert];
//        
//        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//                                                           
//                                                           if (weakSelf)
//                                                           {
//                                                               typeof(self) self = weakSelf;
//                                                               self->currentAlert = nil;
//                                                               
//                                                               account.warnedAboutEncryption = YES;
//                                                           }
//                                                           
//                                                       }]];
//        
//        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCEncryptionAlert"];
//        [self presentViewController:currentAlert animated:YES completion:nil];
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Reset visible room id
    [AppDelegate theDelegate].visibleRoomId = nil;
    
    if (kAppDelegateNetworkStatusDidChangeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kAppDelegateNetworkStatusDidChangeNotificationObserver];
        kAppDelegateNetworkStatusDidChangeNotificationObserver = nil;
    }
    
    if (mxRoomSummaryDidChangeObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:mxRoomSummaryDidChangeObserver];
        mxRoomSummaryDidChangeObserver = nil;
    }

    if (mxEventDidDecryptNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:mxEventDidDecryptNotificationObserver];
        mxEventDidDecryptNotificationObserver = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets contentInset = self.bubblesTableView.contentInset;
    contentInset.bottom = self.bottomLayoutGuide.length;
    self.bubblesTableView.contentInset = contentInset;
    
    // Check here whether a subview has been added or removed
    if (encryptionInfoView)
    {
        if (!encryptionInfoView.superview)
        {
            // Reset
            encryptionInfoView = nil;
            
            // Reload the full table to take into account a potential change on a device status.
            [self.bubblesTableView reloadData];
        }
    }
    
    if (eventDetailsView)
    {
        if (!eventDetailsView.superview)
        {
            // Reset
            eventDetailsView = nil;
        }
    }
    
    // Check whether the preview header is visible
    if (previewHeader)
    {
        // Adjust the top constraint of the bubbles table
        CGRect frame = previewHeader.bottomBorderView.frame;
        self.previewHeaderContainerHeightConstraint.constant = frame.origin.y + frame.size.height;
        
        self.bubblesTableViewTopConstraint.constant = self.previewHeaderContainerHeightConstraint.constant - self.bubblesTableView.mxk_adjustedContentInset.top;
        self.jumpToLastUnreadBannerContainerTopConstraint.constant = self.previewHeaderContainerHeightConstraint.constant;
    }
    else
    {
        self.bubblesTableViewTopConstraint.constant = 0;
        self.jumpToLastUnreadBannerContainerTopConstraint.constant = self.bubblesTableView.mxk_adjustedContentInset.top;
    }
    
    [self refreshMissedDiscussionsCount:YES];
}

#pragma mark - Override MXKRoomViewController

- (void)onMatrixSessionChange
{
    [super onMatrixSessionChange];
    
    // Re-enable the read marker display, and disable its update.
    self.roomDataSource.showReadMarker = YES;
    self.updateRoomReadMarker = NO;
}

- (void)displayRoom:(MXKRoomDataSource *)dataSource
{
    // Remove potential preview Data
    if (roomPreviewData)
    {
        roomPreviewData = nil;
        [self removeMatrixSession:self.mainSession];
        [self showPreviewHeader:NO];
    }
    
    // Set potential discussion target user to nil, now use the dataSource to populate the view
    self.discussionTargetUser = nil;
    
    // Enable the read marker display, and disable its update.
    dataSource.showReadMarker = YES;
    self.updateRoomReadMarker = NO;
    
    [super displayRoom:dataSource];
    
    customizedRoomDataSource = nil;
    
    if (self.roomDataSource)
    {
        // Issue: when the room has been already rendered once, a partial reload of the table is observed during [super displayRoom:].
        // This triggers a scroll to bottom and reset the flag shouldScrollToBottomOnTableRefresh whereas the view controller does not appeared yet.
        // Patch: Force the flag to scroll to bottom the bubble history if the table is not visible yet.
        if (self.bubblesTableView.isHidden)
        {
            shouldScrollToBottomOnTableRefresh = YES;
        }
        
        [self listenToServerNotices];

        self.eventsAcknowledgementEnabled = YES;
        
        // Set room title view
        [self refreshRoomTitle];
        
        // Store ref on customized room data source
        if ([dataSource isKindOfClass:RoomDataSource.class])
        {
            customizedRoomDataSource = (RoomDataSource*)dataSource;
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self refreshRoomInputToolbar];
}

- (void)onRoomDataSourceReady
{
    // Sanity check: Contrary to Riot, the room view controller is not used to display a pending invite.
    // The preview mode is only supported in case of peeking (see roomPreviewData use)
    if (self.roomDataSource.room.summary.membership == MXMembershipInvite)
    {
        NSLog(@"[RoomVC] onRoomDataSourceReady: unexpected invite room (%@)", self.roomDataSource.roomId);
        [self withdrawViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [super onRoomDataSourceReady];
    }
}

- (void)updateViewControllerAppearanceOnRoomDataSourceState
{
    [super updateViewControllerAppearanceOnRoomDataSourceState];
    
    if (self.isRoomPreview)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // Remove input tool bar if any
        if (self.inputToolbarView)
        {
            [super setRoomInputToolbarViewClass:nil];
        }
        
        if (previewHeader)
        {
            previewHeader.roomName = self.roomPreviewData.roomName;
        }
    }
    else if (self.isNewDiscussion)
    {
        [self refreshRoomInputToolbar];
    }
    else
    {
        [self showPreviewHeader:NO];
        
        self.navigationItem.rightBarButtonItem.enabled = (self.roomDataSource != nil);
        
        if (self.roomDataSource)
        {
            // Restore tool bar view and room activities view if none
            if (!self.inputToolbarView)
            {
                [self updateRoomInputToolbarViewClassIfNeeded];
                
                [self refreshRoomInputToolbar];
            }
            
            if (!self.activitiesView)
            {
                // And the extra area
                [self setRoomActivitiesViewClass:RoomActivitiesView.class];
            }
        }
    }
}

- (void)leaveRoomOnEvent:(MXEvent*)event
{
    // Disable the tap gesture handling in the title view by removing the delegate.
    self.roomTitleView.delegate = nil;
    
    // Hide the potential read marker banner.
    self.jumpToLastUnreadBannerContainer.hidden = YES;
    
    [super leaveRoomOnEvent:event];
}

// Set the input toolbar according to the current display
- (void)updateRoomInputToolbarViewClassIfNeeded
{
    Class roomInputToolbarViewClass = RoomInputToolbarView.class;
    
    // Check the user has enough power to post message
    if (self.roomDataSource.roomState)
    {
        MXRoomPowerLevels *powerLevels = self.roomDataSource.roomState.powerLevels;
        NSInteger userPowerLevel = [powerLevels powerLevelOfUserWithUserID:self.mainSession.myUser.userId];
        
        BOOL canSend = (userPowerLevel >= [powerLevels minimumPowerLevelForSendingEventAsMessage:kMXEventTypeStringRoomMessage]);
        BOOL isRoomObsolete = self.roomDataSource.roomState.isObsolete;
        BOOL isResourceLimitExceeded = [self.roomDataSource.mxSession.syncError.errcode isEqualToString:kMXErrCodeStringResourceLimitExceeded];
        
        if (isRoomObsolete || isResourceLimitExceeded)
        {
            roomInputToolbarViewClass = nil;
        }
        else if (!canSend)
        {
            roomInputToolbarViewClass = DisabledRoomInputToolbarView.class;
        }
    }
    
    // Do not show toolbar in case of preview
    if (self.isRoomPreview)
    {
        roomInputToolbarViewClass = nil;
    }
    
    // Change inputToolbarView class only if given class is different from current one
    if (!self.inputToolbarView || ![self.inputToolbarView isMemberOfClass:roomInputToolbarViewClass])
    {
        [super setRoomInputToolbarViewClass:roomInputToolbarViewClass];
        [self updateInputToolBarViewHeight];
    }
}

// Get the height of the current room input toolbar
- (CGFloat)inputToolbarHeight
{
    CGFloat height = 0;

    if ([self.inputToolbarView isKindOfClass:RoomInputToolbarView.class])
    {
        height = ((RoomInputToolbarView*)self.inputToolbarView).mainToolbarMinHeightConstraint.constant;
    }
    else if ([self.inputToolbarView isKindOfClass:DisabledRoomInputToolbarView.class])
    {
        height = ((DisabledRoomInputToolbarView*)self.inputToolbarView).mainToolbarMinHeightConstraint.constant;
    }

    return height;
}

- (void)setRoomActivitiesViewClass:(Class)roomActivitiesViewClass
{
    // Do not show room activities in case of preview (FIXME: show it when live events will be supported during peeking)
    if (self.isRoomPreview)
    {
        roomActivitiesViewClass = nil;
    }
    
    [super setRoomActivitiesViewClass:roomActivitiesViewClass];
}

- (BOOL)isIRCStyleCommand:(NSString*)string
{
    // Do not support IRC-style command in direct chat (discussion)
    if (self.roomDataSource.room.isDirect)
    {
        return NO;
    }
    
    // Override the default behavior for `/join` command in order to open automatically the joined room
    if ([string hasPrefix:kMXKSlashCmdJoinRoom])
    {
        // Join a room
        NSString *roomAlias;
        
        // Sanity check
        if (string.length > kMXKSlashCmdJoinRoom.length)
        {
            roomAlias = [string substringFromIndex:kMXKSlashCmdJoinRoom.length + 1];
            
            // Remove white space from both ends
            roomAlias = [roomAlias stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        // Check
        if (roomAlias.length)
        {
            [self.mainSession joinRoom:roomAlias success:^(MXRoom *room) {
                
                // Show the room
                if (self.delegate)
                {
                    [self.delegate roomViewController:self showRoom:room.roomId];
                }
                
            } failure:^(NSError *error) {
                
                NSLog(@"[RoomVC] Join roomAlias (%@) failed", roomAlias);
                //Alert user
                [[AppDelegate theDelegate] showErrorAsAlert:error];
                
            }];
        }
        else
        {
            // Display cmd usage in text input as placeholder
            self.inputToolbarView.placeholder = @"Usage: /join <room_alias>";
        }
        return YES;
    }
    else if ([string hasPrefix:kMXKSlashCmdChangeDisplayName])
    {
        // The user is not allowed to change his display name
        return NO;
    }
        
    return [super isIRCStyleCommand:string];
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight
{
    [super setKeyboardHeight:keyboardHeight];
    
    // Make the activity indicator follow the keyboard
    // At runtime, this creates a smooth animation
    CGPoint activityIndicatorCenter = self.activityIndicator.center;
    activityIndicatorCenter.y = self.view.center.y - keyboardHeight / 2;
    self.activityIndicator.center = activityIndicatorCenter;
}

- (void)dismissTemporarySubViews
{
    [super dismissTemporarySubViews];
    
    if (encryptionInfoView)
    {
        [encryptionInfoView removeFromSuperview];
        encryptionInfoView = nil;
    }
}

- (void)setBubbleTableViewDisplayInTransition:(BOOL)bubbleTableViewDisplayInTransition
{
    if (self.isBubbleTableViewDisplayInTransition != bubbleTableViewDisplayInTransition)
    {
        [super setBubbleTableViewDisplayInTransition:bubbleTableViewDisplayInTransition];
        
        // Refresh additional displays when the table is ready.
        if (!bubbleTableViewDisplayInTransition && !self.bubblesTableView.isHidden)
        {
            [self refreshActivitiesViewDisplay];
            
            [self checkReadMarkerVisibility];
            [self refreshJumpToLastUnreadBannerDisplay];
        }
    }
}

- (void)sendTextMessage:(NSString*)msgTxt
{
    // Re-invite the left member before sending the message in case of a discussion (direct chat)
    MXWeakify(self);
    [self createOrRestoreDiscussionIfNeeded:^(BOOL success) {
        MXStrongifyAndReturnIfNil(self);
        if (success)
        {
            if (self->isInReplyMode && self->customizedRoomDataSource.selectedEventId)
            {
                [self.roomDataSource sendReplyToEventWithId:self->customizedRoomDataSource.selectedEventId
                                            withTextMessage:msgTxt
                                                    success:nil
                                                    failure:^(NSError *error) {
                                                        // Just log the error. The message will be displayed in red in the room history
                                                        NSLog(@"[RoomViewController] sendTextMessage failed.");
                                                    }];
            }
            else
            {
                // Let the datasource send it and manage the local echo
                [self.roomDataSource sendTextMessage:msgTxt
                                             success:nil
                                             failure:^(NSError *error) {
                                                 // Just log the error. The message will be displayed in red in the room history
                                                 NSLog(@"[RoomViewController] sendTextMessage failed.");
                                             }];
            }
        }
        
        [self cancelEventSelection];
    }];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView sendImage:(UIImage*)image
{
    // Re-invite the left member before sending the message in case of a discussion (direct chat)
    MXWeakify(self);
    [self createOrRestoreDiscussionIfNeeded:^(BOOL success) {
        MXStrongifyAndReturnIfNil(self);
        if (success)
        {
            // Let the datasource send it and manage the local echo
            [self.roomDataSource sendImage:image
                                   success:nil
                                   failure:^(NSError *error) {
                                       // Nothing to do. The image is marked as unsent in the room history by the datasource
                                       NSLog(@"[RoomViewController] sendImage failed.");
                                   }];
        }
    }];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView sendImage:(NSData*)imageData withMimeType:(NSString*)mimetype
{
    // Re-invite the left member before sending the message in case of a discussion (direct chat)
    MXWeakify(self);
    [self createOrRestoreDiscussionIfNeeded:^(BOOL success) {
        MXStrongifyAndReturnIfNil(self);
        if (success)
        {
            // Let the datasource send it and manage the local echo
            [self.roomDataSource sendImage:imageData
                                  mimeType:mimetype
                                   success:nil
                                   failure:^(NSError *error) {
                                       // Nothing to do. The image is marked as unsent in the room history by the datasource
                                       NSLog(@"[RoomViewController] sendImage with mimetype failed.");
                                   }];
        }
    }];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView sendVideo:(NSURL*)videoLocalURL withThumbnail:(UIImage*)videoThumbnail
{
    // Re-invite the left member before sending the message in case of a discussion (direct chat)
    MXWeakify(self);
    [self createOrRestoreDiscussionIfNeeded:^(BOOL success) {
        MXStrongifyAndReturnIfNil(self);
        if (success)
        {
            // Let the datasource send it and manage the local echo
            [self.roomDataSource sendVideo:videoLocalURL
                             withThumbnail:videoThumbnail
                                   success:nil
                                   failure:^(NSError *error) {
                                       // Nothing to do. The video is marked as unsent in the room history by the datasource
                                       NSLog(@"[RoomViewController] sendVideo failed.");
                                   }];
        }
    }];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView sendFile:(NSURL *)fileLocalURL withMimeType:(NSString*)mimetype
{
    // Re-invite the left member before sending the message in case of a discussion (direct chat)
    MXWeakify(self);
    [self createOrRestoreDiscussionIfNeeded:^(BOOL success) {
        MXStrongifyAndReturnIfNil(self);
        if (success)
        {
            // Let the datasource send it and manage the local echo
            [self.roomDataSource sendFile:fileLocalURL
                                 mimeType:mimetype
                                  success:nil
                                  failure:^(NSError *error) {
                                      // Nothing to do. The file is marked as unsent in the room history by the datasource
                                      NSLog(@"[RoomViewController] sendFile failed.");
                                  }];
        }
    }];
}

- (void)dealloc
{
    rightBarButtonItems = nil;
    for (UIBarButtonItem *barButtonItem in self.navigationItem.rightBarButtonItems)
    {
        barButtonItem.enabled = NO;
    }
    
    if (currentAlert)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];
        currentAlert = nil;
    }
    
    if (customizedRoomDataSource)
    {
        customizedRoomDataSource.selectedEventId = nil;
        customizedRoomDataSource = nil;
    }
    
    [self removeTypingNotificationsListener];
    
    if (_themeDidChangeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:_themeDidChangeNotificationObserver];
    }
    if (kAppDelegateDidTapStatusBarNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kAppDelegateDidTapStatusBarNotificationObserver];
        kAppDelegateDidTapStatusBarNotificationObserver = nil;
    }
    if (kAppDelegateNetworkStatusDidChangeNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kAppDelegateNetworkStatusDidChangeNotificationObserver];
        kAppDelegateNetworkStatusDidChangeNotificationObserver = nil;
    }
    if (mxRoomSummaryDidChangeObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:mxRoomSummaryDidChangeObserver];
        mxRoomSummaryDidChangeObserver = nil;
    }
    if (mxEventDidDecryptNotificationObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:mxEventDidDecryptNotificationObserver];
        mxEventDidDecryptNotificationObserver = nil;
    }
    
    [self removeCallNotificationsListeners];
    [self removeWidgetNotificationsListeners];
    [self removeTombstoneEventNotificationsListener];
    [self removeMXSessionStateChangeNotificationsListener];
    [self removeServerNoticesListener];

    if (previewHeader)
    {
        // Here [destroy] is called before [viewWillDisappear:]
        NSLog(@"[RoomVC] destroyed whereas it is still visible");
        
        [previewHeader removeFromSuperview];
        previewHeader = nil;
        
        // Hide preview header container to ignore [self showPreviewHeader:NO] call (if any).
        self.previewHeaderContainer.hidden = YES;
    }
    
    roomPreviewData = nil;
    
    missedDiscussionsBarButtonCustomView = nil;
    missedDiscussionsBadgeLabelBgView = nil;
    missedDiscussionsBadgeLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMXEventDidChangeSentStateNotification object:nil];
}

#pragma mark - Tchap

/**
 Check whether the current room is a direct chat left by the other member.
 */
- (void)isDirectChatLeftByTheOther:(void (^)(BOOL isEmptyDirect))onComplete
{
    // In the case of a direct chat, we check if the other member has left the room.
    if (self.roomDataSource)
    {
        NSString *directUserId = self.roomDataSource.room.directUserId;
        if (directUserId)
        {
            [self.roomDataSource.room members:^(MXRoomMembers *roomMembers) {
                MXRoomMember *directUserMember = [roomMembers memberWithUserId:directUserId];
                if (directUserMember)
                {
                    MXMembership directUserMembership = directUserMember.membership;
                    if (directUserMembership != MXMembershipJoin && directUserMembership != MXMembershipInvite)
                    {
                        onComplete(YES);
                    }
                    else
                    {
                        onComplete(NO);
                    }
                }
                else
                {
                    NSLog(@"[RoomViewController] isEmptyDirectChat: the direct user has disappeared");
                    onComplete(YES);
                }
            } failure:^(NSError *error) {
                NSLog(@"[RoomViewController] isEmptyDirectChat: cannot get all room members");
                onComplete(NO);
            }];
            return;
        }
    }
    
    // This is not a direct chat
    onComplete(NO);
}

/**
 Check whether the current room is a direct chat left by the other member.
 In this case, this method will invite again the left member.
 */
- (void)restoreDiscussionIfNeed:(void (^)(BOOL success))onComplete
{
    [self isDirectChatLeftByTheOther:^(BOOL isEmptyDirect) {
        if (isEmptyDirect)
        {
            NSString *directUserId = self.roomDataSource.room.directUserId;
            
            // Check whether the left member has deactivated his account
            UserService *userService = [[UserService alloc] initWithSession:self.mainSession];
            MXWeakify(self);
            NSLog(@"[RoomViewController] restoreDiscussionIfNeed: check left member %@", directUserId);
            [userService isAccountDeactivatedFor:directUserId success:^(BOOL isDeactivated) {
                if (isDeactivated)
                {
                    NSLog(@"[RoomViewController] restoreDiscussionIfNeed: the left member has deactivated his account");
                    NSError *error = [NSError errorWithDomain:RoomErrorDomain
                                                         code:0
                                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"tchap_cannot_invite_deactivated_account_user", @"Tchap", nil)}];
                    [[AppDelegate theDelegate] showErrorAsAlert:error];
                    onComplete(NO);
                }
                else
                {
                    // Invite again the direct user
                    MXStrongifyAndReturnIfNil(self);
                    NSLog(@"[RoomViewController] restoreDiscussionIfNeed: invite again %@", directUserId);
                    [self.roomDataSource.room inviteUser:directUserId success:^{
                        // Delay the completion in order to display the invite before the local echo of the new message.
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            onComplete(YES);
                        });
                    } failure:^(NSError *error) {
                        NSLog(@"[RoomViewController] restoreDiscussionIfNeed: invite failed");
                        // Alert user
                        [[AppDelegate theDelegate] showErrorAsAlert:error];
                        onComplete(NO);
                    }];
                }
            } failure:^(NSError *error) {
                NSLog(@"[RoomViewController] restoreDiscussionIfNeed: check member status failed");
                // Alert user
                [[AppDelegate theDelegate] showErrorAsAlert:error];
                onComplete(NO);
            }];
        }
        else
        {
            // Nothing to do
            onComplete(YES);
        }
    }];
}

/**
 Create a direct chat with given user.
 */
- (void)createDiscussionWithUser:(User*)user completion:(void (^)(BOOL success))onComplete
{
    MXWeakify(self);
    
    [self startActivityIndicator];
    
    [self.mainSession createRoom:nil
                      visibility:kMXRoomDirectoryVisibilityPrivate
                       roomAlias:nil
                           topic:nil
                          invite:@[user.userId]
                      invite3PID:nil
                        isDirect:YES
                          preset:kMXRoomPresetTrustedPrivateChat
                         success:^(MXRoom *room) {
                             
                             MXStrongifyAndReturnIfNil(self);
                             
                             MXKRoomDataSourceManager *roomDataSourceManager = [MXKRoomDataSourceManager sharedManagerForMatrixSession:self.mainSession];
                             
                             [roomDataSourceManager roomDataSourceForRoom:room.roomId create:YES onComplete:^(MXKRoomDataSource *roomDataSource) {
                                 
                                 [self stopActivityIndicator];
                                 
                                 if (roomDataSource.room.summary.isDirect == NO)
                                 {
                                     // TODO: Display an error, and retry to set room as direct otherwise quit the room
                                     
                                     NSLog(@"[RoomViewController] Fail to create room as direct chat");
                                 }
//                                 else
//                                 {
                                     // Set discussion target user to nil and now use RoomDataSource for updating view
                                     [self displayRoom:roomDataSource];
//                                 }

                                 onComplete(YES);
                             }];
                             
                         } failure:^(NSError *error) {
                             // TODO: Present error without using AppDelegate
                             [[AppDelegate theDelegate] showErrorAsAlert:error];
                             onComplete(NO);
                         }];
}

/**
 Check whether the current room is a direct chat left by the other member.
 In this case, this method will invite again the left member.
 */
- (void)createOrRestoreDiscussionIfNeeded:(void (^)(BOOL success))onComplete
{
    if (self.discussionTargetUser)
    {
        [self createDiscussionWithUser:self.discussionTargetUser completion:onComplete];
    }
    else
    {
        [self restoreDiscussionIfNeed:onComplete];
    }
}

#pragma mark -

- (void)setShowMissedDiscussionsBadge:(BOOL)showMissedDiscussionsBadge
{
    _showMissedDiscussionsBadge = showMissedDiscussionsBadge;
    
    if (_showMissedDiscussionsBadge && !missedDiscussionsBarButtonCustomView)
    {
        // Prepare missed dicussion badge
        missedDiscussionsBarButtonCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 21)];
        missedDiscussionsBarButtonCustomView.backgroundColor = [UIColor clearColor];
        missedDiscussionsBarButtonCustomView.clipsToBounds = NO;
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:missedDiscussionsBarButtonCustomView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:21];
        
        missedDiscussionsBadgeLabelBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
        [missedDiscussionsBadgeLabelBgView.layer setCornerRadius:10];
        
        [missedDiscussionsBarButtonCustomView addSubview:missedDiscussionsBadgeLabelBgView];
        missedDiscussionsBarButtonCustomView.accessibilityIdentifier = @"RoomVCMissedDiscussionsBarButton";
        
        missedDiscussionsBadgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 2, 17, 17)];
        missedDiscussionsBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [missedDiscussionsBadgeLabelBgView addSubview:missedDiscussionsBadgeLabel];
        
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:missedDiscussionsBadgeLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:missedDiscussionsBadgeLabelBgView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0
                                                                              constant:0];
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:missedDiscussionsBadgeLabel
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:missedDiscussionsBadgeLabelBgView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0
                                                                              constant:0];
        
        [NSLayoutConstraint activateConstraints:@[heightConstraint, centerXConstraint, centerYConstraint]];
    }
    else
    {
        missedDiscussionsBarButtonCustomView = nil;
        missedDiscussionsBadgeLabelBgView = nil;
        missedDiscussionsBadgeLabel = nil;
    }
}

- (void)setForceHideInputToolBar:(BOOL)forceHideInputToolBar
{
    _forceHideInputToolBar = forceHideInputToolBar;
    
    [self refreshRoomInputToolbar];
}

#pragma mark - Internals

- (void)forceLayoutRefresh
{
    // Sanity check: check whether the table view data source is set.
    if (self.bubblesTableView.dataSource)
    {
        [self.view layoutIfNeeded];
    }
}

- (BOOL)isRoomPreview
{
    // Check whether some preview data are defined.
    if (roomPreviewData)
    {
        return YES;
    }
    return NO;
}

// Indicates if a new discussion with a target user (without associated room) is occuring.
- (BOOL)isNewDiscussion
{
    return self.discussionTargetUser != nil;
}

- (void)refreshRoomTitle
{
    MXSession *session = self.mainSession;
    if (!session)
    {
        return;
    }
    
    RoomTitleViewModelBuilder *roomTitleViewModelBuilder = [[RoomTitleViewModelBuilder alloc] initWithSession:session];
    RoomTitleViewModel *roomTitleViewModel;
    
    BOOL showRoomPreviewHeader = NO;
    
    if (self.isRoomPreview)
    {
        showRoomPreviewHeader = YES;
        
        if (self.roomPreviewData)
        {
            roomTitleViewModel = [roomTitleViewModelBuilder buildFromRoomPreviewData:self.roomPreviewData];
        }
    }
    else if (self.isNewDiscussion)
    {
        roomTitleViewModel = [roomTitleViewModelBuilder buildFromUser:self.discussionTargetUser];
    }
    else
    {
        MXRoomSummary *roomSummary = self.roomDataSource.room.summary;
        
        if (roomSummary)
        {
            roomTitleViewModel = [roomTitleViewModelBuilder buildFromRoomSummary:roomSummary];
        }
    }
    
    [self showPreviewHeader:showRoomPreviewHeader];
    
    if (roomTitleViewModel)
    {
        [self.roomTitleView fillWithRoomTitleViewModel:roomTitleViewModel];
    }
}

- (void)updateInputToolBarVisibility
{
    BOOL hideInputToolBar = NO;
    
    if (self.forceHideInputToolBar)
    {
        hideInputToolBar = YES;
    }    
    else if (self.roomDataSource)
    {
        hideInputToolBar = (self.roomDataSource.state != MXKDataSourceStateReady);
    }
    
    self.inputToolbarView.hidden = hideInputToolBar;
}

- (void)refreshRoomInputToolbar
{
    // Show or hide input tool bar
    [self updateInputToolBarVisibility];
    
    // Check whether the input toolbar is ready before updating it.
    if (self.inputToolbarView && [self.inputToolbarView isKindOfClass:RoomInputToolbarView.class])
    {
        RoomInputToolbarView *roomInputToolbarView = (RoomInputToolbarView*)self.inputToolbarView;
        
        // Check whether the call option is supported
        roomInputToolbarView.supportCallOption = self.roomDataSource.mxSession.callManager && self.roomDataSource.room.summary.membersCount.joined >= 2;
        
        // Show the hangup button if there is an active call or an active jitsi
        // conference call in the current room
        MXCall *callInRoom = [self.roomDataSource.mxSession.callManager callInRoom:self.roomDataSource.roomId];
        if ((callInRoom && callInRoom.state != MXCallStateEnded)
            || [[AppDelegate theDelegate].jitsiViewController.widget.roomId isEqualToString:self.roomDataSource.roomId])
        {
            roomInputToolbarView.activeCall = YES;
        }
        else
        {
            roomInputToolbarView.activeCall = NO;
            
            // Hide the call button if there is an active call in another room
            roomInputToolbarView.supportCallOption &= ([[AppDelegate theDelegate] callStatusBarWindow] == nil);
        }
        
        // Check whether the encryption is enabled in the room
        if (self.roomDataSource.room.summary.isEncrypted)
        {
            // Encrypt the user's messages as soon as the user supports the encryption?
            roomInputToolbarView.isEncryptionEnabled = (self.mainSession.crypto != nil);
        }
    }
    else if (self.inputToolbarView && [self.inputToolbarView isKindOfClass:DisabledRoomInputToolbarView.class])
    {
        DisabledRoomInputToolbarView *roomInputToolbarView = (DisabledRoomInputToolbarView*)self.inputToolbarView;

        // For the moment, there is only one reason to use `DisabledRoomInputToolbarView`
        [roomInputToolbarView setDisabledReason:NSLocalizedStringFromTable(@"room_do_not_have_permission_to_post", @"Vector", nil)];
    }
}

- (void)enableReplyMode:(BOOL)enable
{
    isInReplyMode = enable;
    
    if (self.inputToolbarView && [self.inputToolbarView isKindOfClass:[RoomInputToolbarView class]])
    {
        RoomInputToolbarView *roomInputToolbarView = (RoomInputToolbarView*)self.inputToolbarView;
        roomInputToolbarView.replyToEnabled = enable;
    }
}

- (void)onSwipeGesture:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    UIView *view = swipeGestureRecognizer.view;
    
    if (view == self.activitiesView)
    {
        // Dismiss the keyboard when user swipes down on activities view.
        [self.inputToolbarView dismissKeyboard];
    }
}

- (void)updateInputToolBarViewHeight
{
    // Update the inputToolBar height.
    CGFloat height = [self inputToolbarHeight];
    // Disable animation during the update
    [UIView setAnimationsEnabled:NO];
    [self roomInputToolbarView:self.inputToolbarView heightDidChanged:height completion:nil];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Hide/Show preview header

- (void)showPreviewHeader:(BOOL)isVisible
{
    if (self.previewHeaderContainer && self.previewHeaderContainer.isHidden == isVisible)
    {
        if (isVisible)
        {
            previewHeader = [PreviewView instantiate];
            [previewHeader.leftButton addTarget:self action:@selector(onJoinPressed:) forControlEvents:UIControlEventTouchUpInside];
            [previewHeader.rightButton addTarget:self action:@selector(onCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
            previewHeader.translatesAutoresizingMaskIntoConstraints = NO;
            [self.previewHeaderContainer addSubview:previewHeader];
            // Force preview header in full width
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:previewHeader
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.previewHeaderContainer
                                                                              attribute:NSLayoutAttributeLeading
                                                                             multiplier:1.0
                                                                               constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:previewHeader
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.previewHeaderContainer
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1.0
                                                                                constant:0];
            // Vertical constraints are required for iOS > 8
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:previewHeader
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.previewHeaderContainer
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:previewHeader
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.previewHeaderContainer
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0];
            
            [NSLayoutConstraint activateConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
            
            previewHeader.roomName = self.roomPreviewData.roomName;
            
            CGRect frame = previewHeader.bottomBorderView.frame;
            self.previewHeaderContainerHeightConstraint.constant = frame.origin.y + frame.size.height;
            
            self.previewHeaderContainer.hidden = NO;
        }
        else
        {
            [previewHeader removeFromSuperview];
            previewHeader = nil;
            
            self.previewHeaderContainer.hidden = YES;
        }
    }
}

- (void)onJoinPressed:(id)sender
{
    [self.delegate roomViewControllerPreviewDidTapJoin:self];
}

- (void)onCancelPressed:(id)sender
{
    // Cancel de preview
    [self.delegate roomViewControllerPreviewDidTapCancel:self];
}

#pragma mark - Preview

- (void)displayRoomPreview:(nonnull RoomPreviewData *)previewData
{
    // Release existing room data source or preview
    [self displayRoom:nil];
    
    self.eventsAcknowledgementEnabled = NO;
    
    [self addMatrixSession:previewData.mxSession];
    
    roomPreviewData = previewData;
    
    [self refreshRoomTitle];
    
    if (roomPreviewData.roomDataSource)
    {
        [super displayRoom:roomPreviewData.roomDataSource];
    }
}

#pragma mark - New discussion

- (void)displayNewDiscussionWithTargetUser:(nonnull User*)discussionTargetUser session:(nonnull MXSession*)session
{
    // Release existing room data source or preview
    [self displayRoom:nil];
    
    self.eventsAcknowledgementEnabled = NO;
    
    [self addMatrixSession:session];
    
    self.discussionTargetUser = discussionTargetUser;
    
    [self refreshRoomTitle];
    [self refreshRoomInputToolbar];
}

#pragma mark - MXKDataSourceDelegate

- (Class<MXKCellRendering>)cellViewClassForCellData:(MXKCellData*)cellData
{
    Class cellViewClass = nil;
    BOOL isEncryptedRoom = self.roomDataSource.room.summary.isEncrypted;
    
    // Sanity check
    if ([cellData conformsToProtocol:@protocol(MXKRoomBubbleCellDataStoring)])
    {
        id<MXKRoomBubbleCellDataStoring> bubbleData = (id<MXKRoomBubbleCellDataStoring>)cellData;
        
        // Select the suitable table view cell class
        if (bubbleData.showAntivirusScanStatus)
        {
            if (bubbleData.isPaginationFirstBubble)
            {
                cellViewClass = isEncryptedRoom ? RoomEncryptedAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.class : RoomAttachmentAntivirusScanStatusWithPaginationTitleBubbleCell.class;
            }
            else if (bubbleData.shouldHideSenderInformation)
            {
                cellViewClass = isEncryptedRoom ? RoomEncryptedAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.class : RoomAttachmentAntivirusScanStatusWithoutSenderInfoBubbleCell.class;
            }
            else
            {
                cellViewClass = isEncryptedRoom ? RoomEncryptedAttachmentAntivirusScanStatusBubbleCell.class : RoomAttachmentAntivirusScanStatusBubbleCell.class;
            }
        }
        else if (bubbleData.hasNoDisplay)
        {
            cellViewClass = RoomEmptyBubbleCell.class;
        }
        else if (bubbleData.tag == RoomBubbleCellDataTagRoomCreateWithPredecessor)
        {
            cellViewClass = RoomPredecessorBubbleCell.class;
        }
        else if (bubbleData.tag == RoomBubbleCellDataTagMembership)
        {
            if (bubbleData.collapsed)
            {
                if (bubbleData.nextCollapsableCellData)
                {
                    cellViewClass = bubbleData.isPaginationFirstBubble ? RoomMembershipCollapsedWithPaginationTitleBubbleCell.class : RoomMembershipCollapsedBubbleCell.class;
                }
                else
                {
                    // Use a normal membership cell for a single membership event
                    cellViewClass = bubbleData.isPaginationFirstBubble ? RoomMembershipWithPaginationTitleBubbleCell.class : RoomMembershipBubbleCell.class;
                }
            }
            else if (bubbleData.collapsedAttributedTextMessage)
            {
                // The cell (and its series) is not collapsed but this cell is the first
                // of the series. So, use the cell with the "collapse" button.
                cellViewClass = bubbleData.isPaginationFirstBubble ? RoomMembershipExpandedWithPaginationTitleBubbleCell.class : RoomMembershipExpandedBubbleCell.class;
            }
            else
            {
                cellViewClass = bubbleData.isPaginationFirstBubble ? RoomMembershipWithPaginationTitleBubbleCell.class : RoomMembershipBubbleCell.class;
            }
        }
        else if (bubbleData.tag == RoomBubbleCellDataTagNotice)
        {
            cellViewClass = bubbleData.isPaginationFirstBubble ? RoomMembershipWithPaginationTitleBubbleCell.class : RoomMembershipBubbleCell.class;
        }
        else if (bubbleData.isIncoming)
        {
            if (bubbleData.isAttachmentWithThumbnail)
            {
                // Check whether the provided celldata corresponds to a selected sticker
                if (customizedRoomDataSource.selectedEventId && (bubbleData.attachment.type == MXKAttachmentTypeSticker) && [bubbleData.attachment.eventId isEqualToString:customizedRoomDataSource.selectedEventId])
                {
                    cellViewClass = RoomSelectedStickerBubbleCell.class;
                }
                else if (bubbleData.isPaginationFirstBubble)
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedAttachmentWithPaginationTitleBubbleCell.class : RoomIncomingAttachmentWithPaginationTitleBubbleCell.class;
                }
                else if (bubbleData.shouldHideSenderInformation)
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedAttachmentWithoutSenderInfoBubbleCell.class : RoomIncomingAttachmentWithoutSenderInfoBubbleCell.class;
                }
                else
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedAttachmentBubbleCell.class : RoomIncomingAttachmentBubbleCell.class;
                }
            }
            else
            {
                if (bubbleData.isPaginationFirstBubble)
                {
                    if (bubbleData.shouldHideSenderName)
                    {
                        cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class : RoomIncomingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class;
                    }
                    else
                    {
                        cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedTextMsgWithPaginationTitleBubbleCell.class : RoomIncomingTextMsgWithPaginationTitleBubbleCell.class;
                    }
                }
                else if (bubbleData.shouldHideSenderInformation)
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedTextMsgWithoutSenderInfoBubbleCell.class : RoomIncomingTextMsgWithoutSenderInfoBubbleCell.class;
                }
                else if (bubbleData.shouldHideSenderName)
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedTextMsgWithoutSenderNameBubbleCell.class : RoomIncomingTextMsgWithoutSenderNameBubbleCell.class;
                }
                else
                {
                    cellViewClass = isEncryptedRoom ? RoomIncomingEncryptedTextMsgBubbleCell.class : RoomIncomingTextMsgBubbleCell.class;
                }
            }
        }
        else
        {
            // Handle here outgoing bubbles
            if (bubbleData.isAttachmentWithThumbnail)
            {
                // Check whether the provided celldata corresponds to a selected sticker
                if (customizedRoomDataSource.selectedEventId && (bubbleData.attachment.type == MXKAttachmentTypeSticker) && [bubbleData.attachment.eventId isEqualToString:customizedRoomDataSource.selectedEventId])
                {
                    cellViewClass = RoomSelectedStickerBubbleCell.class;
                }
                else if (bubbleData.isPaginationFirstBubble)
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedAttachmentWithPaginationTitleBubbleCell.class :RoomOutgoingAttachmentWithPaginationTitleBubbleCell.class;
                }
                else if (bubbleData.shouldHideSenderInformation)
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedAttachmentWithoutSenderInfoBubbleCell.class : RoomOutgoingAttachmentWithoutSenderInfoBubbleCell.class;
                }
                else
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedAttachmentBubbleCell.class : RoomOutgoingAttachmentBubbleCell.class;
                }
            }
            else
            {
                if (bubbleData.isPaginationFirstBubble)
                {
                    if (bubbleData.shouldHideSenderName)
                    {
                        cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class : RoomOutgoingTextMsgWithPaginationTitleWithoutSenderNameBubbleCell.class;
                    }
                    else
                    {
                        cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedTextMsgWithPaginationTitleBubbleCell.class : RoomOutgoingTextMsgWithPaginationTitleBubbleCell.class;
                    }
                }
                else if (bubbleData.shouldHideSenderInformation)
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedTextMsgWithoutSenderInfoBubbleCell.class :RoomOutgoingTextMsgWithoutSenderInfoBubbleCell.class;
                }
                else if (bubbleData.shouldHideSenderName)
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedTextMsgWithoutSenderNameBubbleCell.class : RoomOutgoingTextMsgWithoutSenderNameBubbleCell.class;
                }
                else
                {
                    cellViewClass = isEncryptedRoom ? RoomOutgoingEncryptedTextMsgBubbleCell.class : RoomOutgoingTextMsgBubbleCell.class;
                }
            }
        }
    }
    
    return cellViewClass;
}

#pragma mark - MXKDataSource delegate

- (void)dataSource:(MXKDataSource *)dataSource didRecognizeAction:(NSString *)actionIdentifier inCell:(id<MXKCellRendering>)cell userInfo:(NSDictionary *)userInfo
{
    // Handle here user actions on bubbles for Vector app
    if (customizedRoomDataSource)
    {
        if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnAvatarView])
        {
            MXRoomMember *selectedRoomMember = [self.roomDataSource.roomState.members memberWithUserId:userInfo[kMXKRoomBubbleCellUserIdKey]];
            if (selectedRoomMember && self.delegate)
            {
                [self.delegate roomViewController:self showMemberDetails:selectedRoomMember];
            }
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellLongPressOnAvatarView])
        {
            // Add the member display name in text input
            MXRoomMember *roomMember = [self.roomDataSource.roomState.members memberWithUserId:userInfo[kMXKRoomBubbleCellUserIdKey]];
            if (roomMember)
            {
                [self mention:roomMember];
            }
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnMessageTextView] || [actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnContentView])
        {
            // Retrieve the tapped event
            MXEvent *tappedEvent = userInfo[kMXKRoomBubbleCellEventKey];
            
            // Check whether a selection already exist or not
            if (customizedRoomDataSource.selectedEventId)
            {
                [self cancelEventSelection];
            }
            else if (tappedEvent)
            {
                // Highlight this event in displayed message
                [self selectEventWithId:tappedEvent.eventId];
            }
            
            // Force table refresh
            [self dataSource:self.roomDataSource didCellChange:nil];
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnOverlayContainer])
        {
            // Cancel the current event selection
            [self cancelEventSelection];
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellRiotEditButtonPressed])
        {
            [self dismissKeyboard];
            
            MXEvent *selectedEvent = userInfo[kMXKRoomBubbleCellEventKey];
            
            if (selectedEvent)
            {
                [self showEditButtonAlertMenuForEvent:selectedEvent inCell:cell level:0];
            }
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnAttachmentView])
        {
            if (((MXKRoomBubbleTableViewCell*)cell).bubbleData.attachment.eventSentState == MXEventSentStateFailed)
            {
                // Shortcut: when clicking on an unsent media, show the action sheet to resend it
                MXEvent *selectedEvent = [self.roomDataSource eventWithEventId:((MXKRoomBubbleTableViewCell*)cell).bubbleData.attachment.eventId];
                [self dataSource:dataSource didRecognizeAction:kMXKRoomBubbleCellRiotEditButtonPressed inCell:cell userInfo:@{kMXKRoomBubbleCellEventKey:selectedEvent}];
            }
            else if (((MXKRoomBubbleTableViewCell*)cell).bubbleData.attachment.type == MXKAttachmentTypeSticker)
            {
                // We don't open the attachments viewer when the user taps on a sticker.
                // We consider this tap like a selection.
                
                // Check whether a selection already exist or not
                if (customizedRoomDataSource.selectedEventId)
                {
                    [self cancelEventSelection];
                }
                else
                {
                    // Highlight this event in displayed message
                    [self selectEventWithId:((MXKRoomBubbleTableViewCell*)cell).bubbleData.attachment.eventId];
                }
                
                // Force table refresh
                [self dataSource:self.roomDataSource didCellChange:nil];
            }
            else
            {
                // Keep default implementation
                [super dataSource:dataSource didRecognizeAction:actionIdentifier inCell:cell userInfo:userInfo];
            }
        }
        else if ([actionIdentifier isEqualToString:kRoomEncryptedDataBubbleCellTapOnEncryptionIcon])
        {
            // Retrieve the tapped event
            MXEvent *tappedEvent = userInfo[kMXKRoomBubbleCellEventKey];
            
            if (tappedEvent)
            {
                [self showEncryptionInformation:tappedEvent];
            }
        }
        else if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellTapOnReceiptsContainer])
        {
            MXKReceiptSendersContainer *container = userInfo[kMXKRoomBubbleCellReceiptsContainerKey];
            [ReadReceiptsViewController openInViewController:self fromContainer:container withSession:self.mainSession];
        }
        else if ([actionIdentifier isEqualToString:kRoomMembershipExpandedBubbleCellTapOnCollapseButton])
        {
            // Reset the selection before collapsing
            customizedRoomDataSource.selectedEventId = nil;
            
            [self.roomDataSource collapseRoomBubble:((MXKRoomBubbleTableViewCell*)cell).bubbleData collapsed:YES];
        }
        else
        {
            // Keep default implementation for other actions
            [super dataSource:dataSource didRecognizeAction:actionIdentifier inCell:cell userInfo:userInfo];
        }
    }
    else
    {
        // Keep default implementation for other actions
        [super dataSource:dataSource didRecognizeAction:actionIdentifier inCell:cell userInfo:userInfo];
    }
}

// Display the edit menu on 2 pages/levels.
- (void)showEditButtonAlertMenuForEvent:(MXEvent*)selectedEvent inCell:(id<MXKCellRendering>)cell level:(NSUInteger)level;
{
    MXKRoomBubbleTableViewCell *roomBubbleTableViewCell = (MXKRoomBubbleTableViewCell *)cell;
    MXKAttachment *attachment = roomBubbleTableViewCell.bubbleData.attachment;
    
    if (currentAlert)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];
        currentAlert = nil;
    }
    
    __weak __typeof(self) weakSelf = self;
    currentAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (level == 0)
    {
        // Add actions for a failed event
        if (selectedEvent.sentState == MXEventSentStateFailed)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_resend", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   // Let the datasource resend. It will manage local echo, etc.
                                                                   [self.roomDataSource resendEventWithEventId:selectedEvent.eventId success:nil failure:nil];
                                                               }
                                                               
                                                           }]];
            
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_delete", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   [self.roomDataSource removeEventWithEventId:selectedEvent.eventId];
                                                               }
                                                               
                                                           }]];
        }
    }
    
    // Add actions for text message
    if (!attachment)
    {
        // Retrieved data related to the selected event
        NSArray *components = roomBubbleTableViewCell.bubbleData.bubbleComponents;
        MXKRoomBubbleComponent *selectedComponent;
        for (selectedComponent in components)
        {
            if ([selectedComponent.event.eventId isEqualToString:selectedEvent.eventId])
            {
                break;
            }
            selectedComponent = nil;
        }
        
        if (level == 0)
        {
            // Check status of the selected event
            if (selectedEvent.sentState == MXEventSentStatePreparing ||
                selectedEvent.sentState == MXEventSentStateEncrypting ||
                selectedEvent.sentState == MXEventSentStateSending)
            {
                    [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_cancel_send", @"Vector", nil)
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action)
                                             {
                                                 if (weakSelf)
                                                 {
                                                     typeof(self) self = weakSelf;

                                                     self->currentAlert = nil;

                                                     // Cancel and remove the outgoing message
                                                     [self.roomDataSource.room cancelSendingOperation:selectedEvent.eventId];
                                                     [self.roomDataSource removeEventWithEventId:selectedEvent.eventId];
 
                                                     [self cancelEventSelection];
                                                 }

                                             }]];
            }
        }

        if (level == 0)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_copy", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   [[UIPasteboard generalPasteboard] setString:selectedComponent.textMessage];
                                                               }
                                                               
                                                           }]];
        }
        
        if (level == 0)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_quote", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   // Quote the message a la Markdown into the input toolbar composer
                                                                   self.inputToolbarView.textMessage = [NSString stringWithFormat:@"%@\n>%@\n\n", self.inputToolbarView.textMessage, selectedComponent.textMessage];
                                                                   
                                                                   // And display the keyboard
                                                                   [self.inputToolbarView becomeFirstResponder];
                                                               }
                                                               
                                                           }]];
        }
        
        if (level == 1)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_share", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   NSArray *activityItems = [NSArray arrayWithObjects:selectedComponent.textMessage, nil];
                                                                   
                                                                   UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                                                                   
                                                                   if (activityViewController)
                                                                   {
                                                                       activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                                                       activityViewController.popoverPresentationController.sourceView = roomBubbleTableViewCell;
                                                                       activityViewController.popoverPresentationController.sourceRect = roomBubbleTableViewCell.bounds;
                                                                       
                                                                       [self presentViewController:activityViewController animated:YES completion:nil];
                                                                   }
                                                               }
                                                               
                                                           }]];
        }
    }
    else // Add action for attachment
    {
        if (level == 0)
        {
            if (attachment.type == MXKAttachmentTypeImage || attachment.type == MXKAttachmentTypeVideo)
            {
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_save", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       
                                                                       [self cancelEventSelection];
                                                                       
                                                                       [self startActivityIndicator];
                                                                       
                                                                       [attachment save:^{
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                       } failure:^(NSError *error) {
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                           //Alert user
                                                                           [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                           
                                                                       }];
                                                                       
                                                                       // Start animation in case of download during attachment preparing
                                                                       [roomBubbleTableViewCell startProgressUI];
                                                                   }
                                                                   
                                                               }]];
            }
            
            if (attachment.type != MXKAttachmentTypeSticker)
            {
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_copy", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       
                                                                       [self cancelEventSelection];
                                                                       
                                                                       [self startActivityIndicator];
                                                                       
                                                                       [attachment copy:^{
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                       } failure:^(NSError *error) {
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                           //Alert user
                                                                           [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                           
                                                                       }];
                                                                       
                                                                       // Start animation in case of download during attachment preparing
                                                                       [roomBubbleTableViewCell startProgressUI];
                                                                   }
                                                                   
                                                               }]];
            }
            
            // Check status of the selected event
            if (selectedEvent.sentState == MXEventSentStatePreparing ||
                selectedEvent.sentState == MXEventSentStateEncrypting ||
                selectedEvent.sentState == MXEventSentStateUploading ||
                selectedEvent.sentState == MXEventSentStateSending)
            {
                // Upload id is stored in attachment url (nasty trick)
                NSString *uploadId = roomBubbleTableViewCell.bubbleData.attachment.contentURL;
                if ([MXMediaManager existingUploaderWithId:uploadId])
                {
                    [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_cancel_send", @"Vector", nil)
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {

                                                                       // Get again the loader
                                                                       MXMediaLoader *loader = [MXMediaManager existingUploaderWithId:uploadId];
                                                                       if (loader)
                                                                       {
                                                                           [loader cancel];
                                                                       }
                                                                       // Hide the progress animation
                                                                       roomBubbleTableViewCell.progressView.hidden = YES;
                                                                       
                                                                       if (weakSelf)
                                                                       {
                                                                           typeof(self) self = weakSelf;
                                                                           
                                                                           self->currentAlert = nil;
                                                                           
                                                                           // Remove the outgoing message and its related cached file.
                                                                           [[NSFileManager defaultManager] removeItemAtPath:roomBubbleTableViewCell.bubbleData.attachment.cacheFilePath error:nil];
                                                                           [[NSFileManager defaultManager] removeItemAtPath:roomBubbleTableViewCell.bubbleData.attachment.thumbnailCachePath error:nil];

                                                                           // Cancel and remove the outgoing message
                                                                           [self.roomDataSource.room cancelSendingOperation:selectedEvent.eventId];
                                                                           [self.roomDataSource removeEventWithEventId:selectedEvent.eventId];
                                                                           
                                                                           [self cancelEventSelection];
                                                                       }
                                                                       
                                                                   }]];
                }
            }
        }
        
        if (level == 1 && (attachment.type != MXKAttachmentTypeSticker))
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_share", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   [attachment prepareShare:^(NSURL *fileURL) {
                                                                       
                                                                       __strong __typeof(weakSelf)self = weakSelf;
                                                                       self->documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
                                                                       [self->documentInteractionController setDelegate:self];
                                                                       self->currentSharedAttachment = attachment;
                                                                       
                                                                       if (![self->documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES])
                                                                       {
                                                                           self->documentInteractionController = nil;
                                                                           [attachment onShareEnded];
                                                                           self->currentSharedAttachment = nil;
                                                                       }
                                                                       
                                                                   } failure:^(NSError *error) {
                                                                       
                                                                       //Alert user
                                                                       [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                       
                                                                   }];
                                                                   
                                                                   // Start animation in case of download during attachment preparing
                                                                   [roomBubbleTableViewCell startProgressUI];
                                                               }
                                                               
                                                           }]];
        }
    }
    
    // Check status of the selected event
    if (selectedEvent.sentState == MXEventSentStateSent)
    {
        // Check whether download is in progress
        if (level == 0 && selectedEvent.isMediaAttachment)
        {
            NSString *downloadId = roomBubbleTableViewCell.bubbleData.attachment.downloadId;
            if ([MXMediaManager existingDownloaderWithIdentifier:downloadId])
            {
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_cancel_download", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       
                                                                       [self cancelEventSelection];
                                                                       
                                                                       // Get again the loader
                                                                       MXMediaLoader *loader = [MXMediaManager existingDownloaderWithIdentifier:downloadId];
                                                                       if (loader)
                                                                       {
                                                                           [loader cancel];
                                                                       }
                                                                       // Hide the progress animation
                                                                       roomBubbleTableViewCell.progressView.hidden = YES;
                                                                   }
                                                                   
                                                               }]];
            }
        }
        
        if (level == 0)
        {
            // Tchap: Do not allow to redact the state events
            if (!selectedEvent.isState)
            {
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_redact", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       
                                                                       [self cancelEventSelection];
                                                                       
                                                                       [self startActivityIndicator];
                                                                       
                                                                       [self.roomDataSource.room redactEvent:selectedEvent.eventId reason:nil success:^{
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                       } failure:^(NSError *error) {
                                                                           
                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                           [self stopActivityIndicator];
                                                                           
                                                                           NSLog(@"[RoomVC] Redact event (%@) failed", selectedEvent.eventId);
                                                                           //Alert user
                                                                           [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                           
                                                                       }];
                                                                   }
                                                                   
                                                               }]];
            }
        }
        
        // Tchap: Disable permalink for the moment
//        if (level == 1)
//        {
//            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_permalink", @"Vector", nil)
//                                                             style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * action) {
//
//                                                               if (weakSelf)
//                                                               {
//                                                                   typeof(self) self = weakSelf;
//
//                                                                   [self cancelEventSelection];
//
//                                                                   // Create a matrix.to permalink that is common to all matrix clients
//                                                                   NSString *permalink = [MXTools permalinkToEvent:selectedEvent.eventId inRoom:selectedEvent.roomId];
//
//                                                                   // Create a room matrix.to permalink
//                                                                   [[UIPasteboard generalPasteboard] setString:permalink];
//                                                               }
//
//                                                           }]];
//        }
        
        if (level == 1)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_view_source", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   // Display event details
                                                                   [self showEventDetails:selectedEvent];
                                                               }
                                                               
                                                           }]];
        }

        // Add "View Decrypted Source" for e2ee event we can decrypt
        if (level == 1 && selectedEvent.isEncrypted && selectedEvent.clearEvent)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_view_decrypted_source", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {

                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;

                                                                   [self cancelEventSelection];

                                                                   // Display clear event details
                                                                   [self showEventDetails:selectedEvent.clearEvent];
                                                               }

                                                           }]];
        }
        
        if (level == 1 && selectedEvent.eventType == MXEventTypeRoomMessage)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_report", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   
                                                                   [self cancelEventSelection];
                                                                   
                                                                   // Prompt user to enter a description of the problem content.
                                                                   self->currentAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"room_event_action_report_prompt_reason", @"Vector", nil)  message:nil preferredStyle:UIAlertControllerStyleAlert];
                                                                   
                                                                   [self->currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                                                                       textField.secureTextEntry = NO;
                                                                       textField.placeholder = nil;
                                                                       textField.keyboardType = UIKeyboardTypeDefault;
                                                                   }];
                                                                   
                                                                   [self->currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       
                                                                       if (weakSelf)
                                                                       {
                                                                           typeof(self) self = weakSelf;
                                                                           UITextField *textField = [self->currentAlert textFields].firstObject;
                                                                           self->currentAlert = nil;
                                                                           
                                                                           [self startActivityIndicator];
                                                                           
                                                                           [self.roomDataSource.room reportEvent:selectedEvent.eventId score:-100 reason:textField.text success:^{
                                                                               
                                                                               __strong __typeof(weakSelf)self = weakSelf;
                                                                               [self stopActivityIndicator];
                                                                               
                                                                               // Prompt user to ignore content from this user
                                                                               self->currentAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"room_event_action_report_prompt_ignore_user", @"Vector", nil)  message:nil preferredStyle:UIAlertControllerStyleAlert];
                                                                               
                                                                               [self->currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                                   
                                                                                   if (weakSelf)
                                                                                   {
                                                                                       typeof(self) self = weakSelf;
                                                                                       self->currentAlert = nil;
                                                                                       
                                                                                       [self startActivityIndicator];
                                                                                       
                                                                                       // Add the user to the blacklist: ignored users
                                                                                       [self.mainSession ignoreUsers:@[selectedEvent.sender] success:^{
                                                                                           
                                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                                           [self stopActivityIndicator];
                                                                                           
                                                                                       } failure:^(NSError *error) {
                                                                                           
                                                                                           __strong __typeof(weakSelf)self = weakSelf;
                                                                                           [self stopActivityIndicator];
                                                                                           
                                                                                           NSLog(@"[RoomVC] Ignore user (%@) failed", selectedEvent.sender);
                                                                                           //Alert user
                                                                                           [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                                           
                                                                                       }];
                                                                                   }
                                                                                   
                                                                               }]];
                                                                               
                                                                               [self->currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"no"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                                   
                                                                                   if (weakSelf)
                                                                                   {
                                                                                       typeof(self) self = weakSelf;
                                                                                       self->currentAlert = nil;
                                                                                   }
                                                                                   
                                                                               }]];
                                                                               
                                                                               [self presentViewController:self->currentAlert animated:YES completion:nil];
                                                                               
                                                                           } failure:^(NSError *error) {
                                                                               
                                                                               __strong __typeof(weakSelf)self = weakSelf;
                                                                               [self stopActivityIndicator];
                                                                               
                                                                               NSLog(@"[RoomVC] Report event (%@) failed", selectedEvent.eventId);
                                                                               //Alert user
                                                                               [[AppDelegate theDelegate] showErrorAsAlert:error];
                                                                               
                                                                           }];
                                                                       }
                                                                       
                                                                   }]];
                                                                   
                                                                   [self->currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                                       
                                                                       if (weakSelf)
                                                                       {
                                                                           typeof(self) self = weakSelf;
                                                                           self->currentAlert = nil;
                                                                       }
                                                                       
                                                                   }]];
                                                                   
                                                                   [self presentViewController:self->currentAlert animated:YES completion:nil];
                                                               }
                                                               
                                                           }]];
        }
        
        if (level == 1 && self.roomDataSource.room.summary.isEncrypted)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_view_encryption", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   [self cancelEventSelection];
                                                                   
                                                                   // Display encryption details
                                                                   [self showEncryptionInformation:selectedEvent];
                                                               }
                                                               
                                                           }]];
        }
        
        
        if (level == 0)
        {
            [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_event_action_more", @"Vector", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               if (weakSelf)
                                                               {
                                                                   typeof(self) self = weakSelf;
                                                                   self->currentAlert = nil;
                                                                   
                                                                   // Show the next level of options
                                                                   [self showEditButtonAlertMenuForEvent:selectedEvent inCell:cell level:1];
                                                               }
                                                               
                                                           }]];
        }
    }
    
    [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", @"Vector", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       if (weakSelf)
                                                       {
                                                           typeof(self) self = weakSelf;
                                                           [self cancelEventSelection];
                                                       }
                                                       
                                                   }]];
    
    // Do not display empty action sheet
    if (currentAlert.actions.count > 1)
    {
        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCEventMenuAlert"];
        [currentAlert popoverPresentationController].sourceView = roomBubbleTableViewCell;
        [currentAlert popoverPresentationController].sourceRect = roomBubbleTableViewCell.bounds;
        [self presentViewController:currentAlert animated:YES completion:nil];
    }
    else
    {
        currentAlert = nil;
    }
}

- (BOOL)dataSource:(MXKDataSource *)dataSource shouldDoAction:(NSString *)actionIdentifier inCell:(id<MXKCellRendering>)cell userInfo:(NSDictionary *)userInfo defaultValue:(BOOL)defaultValue
{
    BOOL shouldDoAction = defaultValue;
    
    if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellShouldInteractWithURL])
    {
        // Try to catch universal link supported by the app
        NSURL *url = userInfo[kMXKRoomBubbleCellUrl];
        
        // When a link refers to a room alias/id, a user id or an event id, the non-ASCII characters (like '#' in room alias) has been escaped
        // to be able to convert it into a legal URL string.
        NSString *absoluteURLString = [url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // If the link can be open it by the app, let it do
        // Note: Universal links are not supported by Tchap. [Tools isUniversalLink:] returns NO for the moment.
        // TODO use the UniversalLinkService
//        if ([Tools isUniversalLink:url])
//        {
//            shouldDoAction = NO;
//
//            // iOS Patch: fix vector.im urls before using it
//            NSURL *fixedURL = [Tools fixURLWithSeveralHashKeys:url];
//
//            [[AppDelegate theDelegate] handleUniversalLinkFragment:fixedURL.fragment];
//        }
        // Open a detail screen about the clicked user
        if ([MXTools isMatrixUserIdentifier:absoluteURLString])
        {
            // We display details only for the room members
            NSString *userId = absoluteURLString;
            MXRoomMember* member = [self.roomDataSource.roomState.members memberWithUserId:userId];
            if (member && self.delegate)
            {
                shouldDoAction = NO;
                [self.delegate roomViewController:self showMemberDetails:member];
            }
        }
        // Open the clicked room
        else if ([MXTools isMatrixRoomIdentifier:absoluteURLString] || [MXTools isMatrixRoomAlias:absoluteURLString])
        {
            // Note: Presently we may fail to display correctly the rooms which are not joined by the user
            // TODO: Support all roomId and alias to preview the room when the user doesn't join the room...
            NSString *roomId = absoluteURLString;
            if ([MXTools isMatrixRoomAlias:absoluteURLString])
            {
                // Translate the alias into the room id
                // We don't support for the moment the alias of the rooms which are not joined
                MXRoom *room = [self.mainSession roomWithAlias:absoluteURLString];
                if (room)
                {
                    roomId = room.roomId;
                }
            }
            
            if (roomId && self.delegate)
            {
                shouldDoAction = NO;
                [self.delegate roomViewController:self showRoom:roomId];
            }
        }
//        // Preview the clicked group
//        else if ([MXTools isMatrixGroupIdentifier:absoluteURLString])
//        {
//            shouldDoAction = NO;
//
//            // Open the group or preview it
//            NSString *fragment = [NSString stringWithFormat:@"/group/%@", [absoluteURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//            [[AppDelegate theDelegate] handleUniversalLinkFragment:fragment];
//        }
        else if ([absoluteURLString hasPrefix:kEventFormatterOnReRequestKeysLinkAction])
        {
            NSArray<NSString*> *arguments = [absoluteURLString componentsSeparatedByString:kEventFormatterOnReRequestKeysLinkActionSeparator];
            if (arguments.count > 1)
            {
                NSString *eventId = arguments[1];
                MXEvent *event = [self.roomDataSource eventWithEventId:eventId];

                if (event)
                {
                    [self reRequestKeysAndShowExplanationAlert:event];
                }
            }
        }
    }
    
    return shouldDoAction;
}

- (void)selectEventWithId:(NSString*)eventId
{
    BOOL shouldEnableReplyMode = [self.roomDataSource canReplyToEventWithId:eventId];;
    
    [self enableReplyMode:shouldEnableReplyMode];
    
    customizedRoomDataSource.selectedEventId = eventId;
}

- (void)cancelEventSelection
{
    [self enableReplyMode:NO];
    
    if (currentAlert)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];
        currentAlert = nil;
    }
    
    customizedRoomDataSource.selectedEventId = nil;
    
    // Force table refresh
    [self dataSource:self.roomDataSource didCellChange:nil];
}

#pragma mark - RoomInputToolbarViewDelegate

- (void)roomInputToolbarViewPresentStickerPicker:(MXKRoomInputToolbarView*)toolbarView
{
    // Search for the sticker picker widget in the user account
    Widget *widget = [[WidgetManager sharedManager] userWidgets:self.roomDataSource.mxSession ofTypes:@[kWidgetTypeStickerPicker]].firstObject;

    if (widget)
    {
        // Display the widget
        [widget widgetUrl:^(NSString * _Nonnull widgetUrl) {

            StickerPickerViewController *stickerPickerVC = [[StickerPickerViewController alloc] initWithUrl:widgetUrl forWidget:widget];

            stickerPickerVC.roomDataSource = self.roomDataSource;

            [self.navigationController pushViewController:stickerPickerVC animated:YES];
        } failure:^(NSError * _Nonnull error) {

            NSLog(@"[RoomVC] Cannot display widget %@", widget);
            [[AppDelegate theDelegate] showErrorAsAlert:error];
        }];
    }
    else
    {
        // The Sticker picker widget is not installed yet. Propose the user to install it
        __weak typeof(self) weakSelf = self;

        [currentAlert dismissViewControllerAnimated:NO completion:nil];

        NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@",
                                  NSLocalizedStringFromTable(@"widget_sticker_picker_no_stickerpacks_alert", @"Vector", nil),
                                  NSLocalizedStringFromTable(@"widget_sticker_picker_no_stickerpacks_alert_add_now", @"Vector", nil)
                                  ];

        currentAlert = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];

        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"no"]
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action)
        {
            if (weakSelf)
            {
                typeof(self) self = weakSelf;
                self->currentAlert = nil;
            }

        }]];

        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"yes"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
        {
            if (weakSelf)
            {
                typeof(self) self = weakSelf;
                self->currentAlert = nil;

                // Show the sticker picker settings screen
                IntegrationManagerViewController *modularVC = [[IntegrationManagerViewController alloc]
                                                               initForMXSession:self.roomDataSource.mxSession
                                                               inRoom:self.roomDataSource.roomId
                                                               screen:[IntegrationManagerViewController screenForWidget:kWidgetTypeStickerPicker]
                                                               widgetId:nil];

                [self presentViewController:modularVC animated:NO completion:nil];
            }
        }]];

        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCStickerPickerAlert"];
        [self presentViewController:currentAlert animated:YES completion:nil];
    }
}

#pragma mark - MXKRoomInputToolbarViewDelegate

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView isTyping:(BOOL)typing
{
    [super roomInputToolbarView:toolbarView isTyping:typing];

    // Cancel potential selected event (to leave edition mode)
    NSString *selectedEventId = customizedRoomDataSource.selectedEventId;
    if (typing && selectedEventId && ![self.roomDataSource canReplyToEventWithId:selectedEventId])
    {
        [self cancelEventSelection];
    }
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView placeCallWithVideo:(BOOL)video
{
    __weak __typeof(self) weakSelf = self;

    NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

    // Check app permissions first
    [MXKTools checkAccessForCall:video
     manualChangeMessageForAudio:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"microphone_access_not_granted_for_call"], appDisplayName]
     manualChangeMessageForVideo:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"camera_access_not_granted_for_call"], appDisplayName]
       showPopUpInViewController:self completionHandler:^(BOOL granted) {

           if (weakSelf)
           {
               typeof(self) self = weakSelf;

               if (granted)
               {
                   [self roomInputToolbarView:toolbarView placeCallWithVideo2:video];
               }
               else
               {
                   NSLog(@"RoomViewController: Warning: The application does not have the perssion to place the call");
               }
           }
       }];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView placeCallWithVideo2:(BOOL)video
{
     __weak __typeof(self) weakSelf = self;

    // If there is already a jitsi widget, join it
    Widget *jitsiWidget = [customizedRoomDataSource jitsiWidget];
    if (jitsiWidget)
    {
        [[AppDelegate theDelegate] displayJitsiViewControllerWithWidget:jitsiWidget andVideo:video];
    }

    // If enabled, create the conf using jitsi widget and open it directly
    else if (RiotSettings.shared.createConferenceCallsWithJitsi
             && self.roomDataSource.room.summary.membersCount.joined > 2)
    {
        [self startActivityIndicator];

        [[WidgetManager sharedManager] createJitsiWidgetInRoom:self.roomDataSource.room
                                                     withVideo:video
                                                       success:^(Widget *jitsiWidget)
         {
             if (weakSelf)
             {
                 typeof(self) self = weakSelf;
                 [self stopActivityIndicator];

                 [[AppDelegate theDelegate] displayJitsiViewControllerWithWidget:jitsiWidget andVideo:video];
             }
         }
                                                       failure:^(NSError *error)
         {
             if (weakSelf)
             {
                 typeof(self) self = weakSelf;
                 [self stopActivityIndicator];

                 [self showJitsiErrorAsAlert:error];
             }
         }];
    }
    // Classic conference call is not supported in encrypted rooms
    else if (self.roomDataSource.room.summary.isEncrypted && self.roomDataSource.room.summary.membersCount.joined > 2)
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];

        currentAlert = [UIAlertController alertControllerWithTitle:[NSBundle mxk_localizedStringForKey:@"room_no_conference_call_in_encrypted_rooms"]  message:nil preferredStyle:UIAlertControllerStyleAlert];

        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                     if (weakSelf)
                                     {
                                         typeof(self) self = weakSelf;
                                         self->currentAlert = nil;
                                     }

                                 }]];

        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCCallAlert"];
        [self presentViewController:currentAlert animated:YES completion:nil];
    }

    // In case of conference call, check that the user has enough power level
    else if (self.roomDataSource.room.summary.membersCount.joined > 2 &&
             ![MXCallManager canPlaceConferenceCallInRoom:self.roomDataSource.room roomState:self.roomDataSource.roomState])
    {
        [currentAlert dismissViewControllerAnimated:NO completion:nil];

        currentAlert = [UIAlertController alertControllerWithTitle:[NSBundle mxk_localizedStringForKey:@"room_no_power_to_create_conference_call"]  message:nil preferredStyle:UIAlertControllerStyleAlert];

        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                     if (weakSelf)
                                     {
                                         typeof(self) self = weakSelf;
                                         self->currentAlert = nil;
                                     }
                                 }]];

        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCCallAlert"];
        [self presentViewController:currentAlert animated:YES completion:nil];
    }

    // Classic 1:1 or group call can be done
    else
    {
        [self.roomDataSource.room placeCallWithVideo:video success:nil failure:nil];
    }
}

- (void)roomInputToolbarViewHangupCall:(MXKRoomInputToolbarView *)toolbarView
{
    MXCall *callInRoom = [self.roomDataSource.mxSession.callManager callInRoom:self.roomDataSource.roomId];
    if (callInRoom)
    {
        [callInRoom hangup];
    }
    else if ([[AppDelegate theDelegate].jitsiViewController.widget.roomId isEqualToString:self.roomDataSource.roomId])
    {
        [[AppDelegate theDelegate].jitsiViewController hangup];
    }

    [self refreshActivitiesViewDisplay];
    [self refreshRoomInputToolbar];
}

- (void)roomInputToolbarView:(MXKRoomInputToolbarView*)toolbarView heightDidChanged:(CGFloat)height completion:(void (^)(BOOL finished))completion
{
    if (self.roomInputToolbarContainerHeightConstraint.constant != height)
    {
        // Hide temporarily the placeholder to prevent its distorsion during height animation
        if (!savedInputToolbarPlaceholder)
        {
            savedInputToolbarPlaceholder = toolbarView.placeholder.length ? toolbarView.placeholder : @"";
        }
        toolbarView.placeholder = nil;
        
        [super roomInputToolbarView:toolbarView heightDidChanged:height completion:^(BOOL finished) {
            
            if (completion)
            {
                completion (finished);
            }
            
            // Consider here the saved placeholder only if no new placeholder has been defined during the height animation.
            if (!toolbarView.placeholder)
            {
                // Restore the placeholder if any
                toolbarView.placeholder =  savedInputToolbarPlaceholder.length ? savedInputToolbarPlaceholder : nil;
            }
            savedInputToolbarPlaceholder = nil;
        }];
    }
}

#pragma mark - Action

- (IBAction)onButtonPressed:(id)sender
{
    if (sender == self.jumpToLastUnreadButton)
    {
        // Dismiss potential keyboard.
        [self dismissKeyboard];

        // Jump to the last unread event by using a temporary room data source initialized with the last unread event id.
        MXWeakify(self);
        [RoomDataSource loadRoomDataSourceWithRoomId:self.roomDataSource.roomId initialEventId:self.roomDataSource.room.accountData.readMarkerEventId andMatrixSession:self.mainSession onComplete:^(id roomDataSource) {
            MXStrongifyAndReturnIfNil(self);

            [roomDataSource finalizeInitialization];

            // Center the bubbles table content on the bottom of the read marker event in order to display correctly the read marker view.
            self.centerBubblesTableViewContentOnTheInitialEventBottom = YES;
            [self displayRoom:roomDataSource];

            // Give the data source ownership to the room view controller.
            self.hasRoomDataSourceOwnership = YES;
        }];
    }
    else if (sender == self.resetReadMarkerButton)
    {
        // Move the read marker to the current read receipt position.
        [self.roomDataSource.room forgetReadMarker];
        
        // Hide the banner
        self.jumpToLastUnreadBannerContainer.hidden = YES;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    if ([cell isKindOfClass:MXKRoomBubbleTableViewCell.class])
    {
        MXKRoomBubbleTableViewCell *roomBubbleTableViewCell = (MXKRoomBubbleTableViewCell*)cell;
        if (roomBubbleTableViewCell.readMarkerView)
        {
            readMarkerTableViewCell = roomBubbleTableViewCell;
            
            [self checkReadMarkerVisibility];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (cell == readMarkerTableViewCell)
    {
        readMarkerTableViewCell = nil;
    }
    
    [super tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    [self checkReadMarkerVisibility];
    
    // Switch back to the live mode when the user scrolls to the bottom of the non live timeline.
    if (!self.roomDataSource.isLive && ![self isRoomPreview])
    {
        CGFloat contentBottomPosY = self.bubblesTableView.contentOffset.y + self.bubblesTableView.frame.size.height - self.bubblesTableView.mxk_adjustedContentInset.bottom;
        if (contentBottomPosY >= self.bubblesTableView.contentSize.height && ![self.roomDataSource.timeline canPaginate:MXTimelineDirectionForwards])
        {
            [self goBackToLive];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([MXKRoomViewController instancesRespondToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if (decelerate == NO)
    {
        [self refreshActivitiesViewDisplay];
        [self refreshJumpToLastUnreadBannerDisplay];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([MXKRoomViewController instancesRespondToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [super scrollViewDidEndDecelerating:scrollView];
    }
    
    [self refreshActivitiesViewDisplay];
    [self refreshJumpToLastUnreadBannerDisplay];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([MXKRoomViewController instancesRespondToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [super scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    [self refreshActivitiesViewDisplay];
    [self refreshJumpToLastUnreadBannerDisplay];
}

#pragma mark - RoomTitleViewDelegate

- (void)roomTitleViewDidTapped:(RoomTitleView *)roomTitleView
{
    if (self.delegate)
    {
        // Open room settings
        [self.delegate roomViewControllerShowRoomDetails:self];
    }
}

#pragma mark - Typing management

- (void)removeTypingNotificationsListener
{
    if (self.roomDataSource)
    {
        // Remove the previous live listener
        if (typingNotifListener)
        {
            MXWeakify(self);
            [self.roomDataSource.room liveTimeline:^(MXEventTimeline *liveTimeline) {
                MXStrongifyAndReturnIfNil(self);

                [liveTimeline removeListener:self->typingNotifListener];
                self->typingNotifListener = nil;
            }];
        }
    }
    
    currentTypingUsers = nil;
}

- (void)listenTypingNotifications
{
    if (self.roomDataSource)
    {
        // Add typing notification listener
        MXWeakify(self);
        self->typingNotifListener = [self.roomDataSource.room listenToEventsOfTypes:@[kMXEventTypeStringTypingNotification] onEvent:^(MXEvent *event, MXTimelineDirection direction, MXRoomState *roomState) {
            MXStrongifyAndReturnIfNil(self);

            // Handle only live events
            if (direction == MXTimelineDirectionForwards)
            {
                // Retrieve typing users list
                NSMutableArray *typingUsers = [NSMutableArray arrayWithArray:self.roomDataSource.room.typingUsers];
                // Remove typing info for the current user
                NSUInteger index = [typingUsers indexOfObject:self.mainSession.myUser.userId];
                if (index != NSNotFound)
                {
                    [typingUsers removeObjectAtIndex:index];
                }

                // Ignore this notification if both arrays are empty
                if (self->currentTypingUsers.count || typingUsers.count)
                {
                    self->currentTypingUsers = typingUsers;
                    [self refreshActivitiesViewDisplay];
                }
            }
        }];

        // Retrieve the current typing users list
        NSMutableArray *typingUsers = [NSMutableArray arrayWithArray:self.roomDataSource.room.typingUsers];
        // Remove typing info for the current user
        NSUInteger index = [typingUsers indexOfObject:self.mainSession.myUser.userId];
        if (index != NSNotFound)
        {
            [typingUsers removeObjectAtIndex:index];
        }
        currentTypingUsers = typingUsers;
        [self refreshActivitiesViewDisplay];
    }
}

- (void)refreshTypingNotification
{
    if ([self.activitiesView isKindOfClass:RoomActivitiesView.class])
    {
        // Prepare here typing notification
        NSString* text = nil;
        NSUInteger count = currentTypingUsers.count;
        
        // get the room member names
        NSMutableArray *names = [[NSMutableArray alloc] init];
        
        // keeps the only the first two users
        for(int i = 0; i < MIN(count, 2); i++)
        {
            NSString* name = [currentTypingUsers objectAtIndex:i];
            
            MXRoomMember* member = [self.roomDataSource.roomState.members memberWithUserId:name];
            
            if (member && member.displayname.length)
            {
                name = member.displayname;
            }
            
            // sanity check
            if (name)
            {
                [names addObject:name];
            }
        }
        
        if (0 == names.count)
        {
            // something to do ?
        }
        else if (1 == names.count)
        {
            text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"room_one_user_is_typing", @"Vector", nil), [names objectAtIndex:0]];
        }
        else if (2 == names.count)
        {
            text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"room_two_users_are_typing", @"Vector", nil), [names objectAtIndex:0], [names objectAtIndex:1]];
        }
        else
        {
            text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"room_many_users_are_typing", @"Vector", nil), [names objectAtIndex:0], [names objectAtIndex:1]];
        }
        
        [((RoomActivitiesView*) self.activitiesView) displayTypingNotification:text];
    }
}

#pragma mark - Call notifications management

- (void)removeCallNotificationsListeners
{
    if (kMXCallStateDidChangeObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMXCallStateDidChangeObserver];
        kMXCallStateDidChangeObserver = nil;
    }
    if (kMXCallManagerConferenceStartedObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMXCallManagerConferenceStartedObserver];
        kMXCallManagerConferenceStartedObserver = nil;
    }
    if (kMXCallManagerConferenceFinishedObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMXCallManagerConferenceFinishedObserver];
        kMXCallManagerConferenceFinishedObserver = nil;
    }
}

- (void)listenCallNotifications
{
    kMXCallStateDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXCallStateDidChange object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        MXCall *call = notif.object;
        if ([call.room.roomId isEqualToString:customizedRoomDataSource.roomId])
        {
            [self refreshActivitiesViewDisplay];
            [self refreshRoomInputToolbar];
        }
    }];
    kMXCallManagerConferenceStartedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXCallManagerConferenceStarted object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        NSString *roomId = notif.object;
        if ([roomId isEqualToString:customizedRoomDataSource.roomId])
        {
            [self refreshActivitiesViewDisplay];
        }
    }];
    kMXCallManagerConferenceFinishedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXCallManagerConferenceFinished object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        
        NSString *roomId = notif.object;
        if ([roomId isEqualToString:customizedRoomDataSource.roomId])
        {
            [self refreshActivitiesViewDisplay];
            [self refreshRoomInputToolbar];
        }
    }];
}


#pragma mark - Server notices management

- (void)removeServerNoticesListener
{
    if (serverNotices)
    {
        [serverNotices close];
        serverNotices = nil;
    }
}

- (void)listenToServerNotices
{
    if (!serverNotices)
    {
        serverNotices = [[MXServerNotices alloc] initWithMatrixSession:self.roomDataSource.mxSession];
        serverNotices.delegate = self;
    }
}

- (void)serverNoticesDidChangeState:(MXServerNotices *)serverNotices
{
    [self refreshActivitiesViewDisplay];
}

#pragma mark - Widget notifications management

- (void)removeWidgetNotificationsListeners
{
    if (kMXKWidgetManagerDidUpdateWidgetObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMXKWidgetManagerDidUpdateWidgetObserver];
        kMXKWidgetManagerDidUpdateWidgetObserver = nil;
    }
}

- (void)listenWidgetNotifications
{
    kMXKWidgetManagerDidUpdateWidgetObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kWidgetManagerDidUpdateWidgetNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {

        Widget *widget = notif.object;
        if (widget.mxSession == self.roomDataSource.mxSession
            && [widget.roomId isEqualToString:customizedRoomDataSource.roomId])
        {
            // Jitsi conference widget existence is shown in the bottom bar
            // Update the bar
            [self refreshActivitiesViewDisplay];
            [self refreshRoomInputToolbar];
            [self refreshRoomTitle];
        }
    }];
}

- (void)showJitsiErrorAsAlert:(NSError*)error
{
    // Customise the error for permission issues
    if ([error.domain isEqualToString:WidgetManagerErrorDomain] && error.code == WidgetManagerErrorCodeNotEnoughPower)
    {
        error = [NSError errorWithDomain:error.domain
                                    code:error.code
                                userInfo:@{
                                           NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"room_conference_call_no_power", @"Vector", nil)
                                           }];
    }

    // Alert user
    [[AppDelegate theDelegate] showErrorAsAlert:error];
}

- (NSUInteger)widgetsCount:(BOOL)includeUserWidgets
{
    NSUInteger widgetsCount = [[WidgetManager sharedManager] widgetsNotOfTypes:@[kWidgetTypeJitsi]
                                                                        inRoom:self.roomDataSource.room
                                                                 withRoomState:self.roomDataSource.roomState].count;
    if (includeUserWidgets)
    {
        widgetsCount += [[WidgetManager sharedManager] userWidgets:self.roomDataSource.room.mxSession].count;
    }

    return widgetsCount;
}

#pragma mark - Unreachable Network Handling

- (void)refreshActivitiesViewDisplay
{
    if ([self.activitiesView isKindOfClass:RoomActivitiesView.class])
    {
        RoomActivitiesView *roomActivitiesView = (RoomActivitiesView*)self.activitiesView;

        // Reset gesture recognizers
        while (roomActivitiesView.gestureRecognizers.count)
        {
            [roomActivitiesView removeGestureRecognizer:roomActivitiesView.gestureRecognizers[0]];
        }

        Widget *jitsiWidget = [customizedRoomDataSource jitsiWidget];

        if ([self.roomDataSource.mxSession.syncError.errcode isEqualToString:kMXErrCodeStringResourceLimitExceeded])
        {
            [roomActivitiesView showResourceLimitExceededError:self.roomDataSource.mxSession.syncError.userInfo onAdminContactTapped:^(NSURL *adminContact) {
                if ([[UIApplication sharedApplication] canOpenURL:adminContact])
                {
                    [[UIApplication sharedApplication] openURL:adminContact];
                }
                else
                {
                    NSLog(@"[RoomVC] refreshActivitiesViewDisplay: adminContact(%@) cannot be opened", adminContact);
                }
            }];
        }
        else if ([AppDelegate theDelegate].isOffline)
        {
            [roomActivitiesView displayNetworkErrorNotification:NSLocalizedStringFromTable(@"room_offline_notification", @"Vector", nil)];
        }
        else if (customizedRoomDataSource.roomState.isObsolete)
        {
            NSString *replacementRoomId = customizedRoomDataSource.roomState.tombStoneContent.replacementRoomId;
            if (replacementRoomId && self.delegate)
            {
                [roomActivitiesView displayRoomReplacementWithRoomLinkTappedHandler:^{
                    [self.delegate roomViewController:self showRoom:replacementRoomId];
                }];
            }
        }
        else if (customizedRoomDataSource.roomState.isOngoingConferenceCall)
        {
            // Show the "Ongoing conference call" banner only if the user is not in the conference
            MXCall *callInRoom = [self.roomDataSource.mxSession.callManager callInRoom:self.roomDataSource.roomId];
            if (callInRoom && callInRoom.state != MXCallStateEnded)
            {
                if ([self checkUnsentMessages] == NO)
                {
                    [self refreshTypingNotification];
                }
            }
            else
            {
                [roomActivitiesView displayOngoingConferenceCall:^(BOOL video) {
                    
                    NSLog(@"[RoomVC] onOngoingConferenceCallPressed");
                    
                    // Make sure there is not yet a call
                    if (![customizedRoomDataSource.mxSession.callManager callInRoom:customizedRoomDataSource.roomId])
                    {
                        [customizedRoomDataSource.room placeCallWithVideo:video success:nil failure:nil];
                    }
                } onClosePressed:nil];
            }
        }
        else if (jitsiWidget)
        {
            // The room has an active jitsi widget
            // Show it in the banner if the user is not already in
            LegacyAppDelegate *appDelegate = [AppDelegate theDelegate];
            if ([appDelegate.jitsiViewController.widget.widgetId isEqualToString:jitsiWidget.widgetId])
            {
                if ([self checkUnsentMessages] == NO)
                {
                    [self refreshTypingNotification];
                }
            }
            else
            {
                [roomActivitiesView displayOngoingConferenceCall:^(BOOL video) {

                    NSLog(@"[RoomVC] onOngoingConferenceCallPressed (jitsi)");

                    __weak __typeof(self) weakSelf = self;
                    NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

                    // Check app permissions first
                    [MXKTools checkAccessForCall:video
                     manualChangeMessageForAudio:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"microphone_access_not_granted_for_call"], appDisplayName]
                     manualChangeMessageForVideo:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"camera_access_not_granted_for_call"], appDisplayName]
                       showPopUpInViewController:self completionHandler:^(BOOL granted) {

                           if (weakSelf)
                           {
                               if (granted)
                               {
                                   // Present the Jitsi view controller
                                   [appDelegate displayJitsiViewControllerWithWidget:jitsiWidget andVideo:video];
                               }
                               else
                               {
                                   NSLog(@"[RoomVC] onOngoingConferenceCallPressed: Warning: The application does not have the perssion to join the call");
                               }
                           }
                       }];

                } onClosePressed:^{

                    [self startActivityIndicator];

                    // Close the widget
                    __weak __typeof(self) weakSelf = self;
                    [[WidgetManager sharedManager] closeWidget:jitsiWidget.widgetId inRoom:self.roomDataSource.room success:^{

                        if (weakSelf)
                        {
                            typeof(self) self = weakSelf;
                            [self stopActivityIndicator];

                            // The banner will automatically leave thanks to kWidgetManagerDidUpdateWidgetNotification
                        }

                    } failure:^(NSError *error) {
                        if (weakSelf)
                        {
                            typeof(self) self = weakSelf;

                            [self showJitsiErrorAsAlert:error];
                            [self stopActivityIndicator];
                        }
                    }];
                }];
            }
        }
        else if ([self checkUnsentMessages] == NO)
        {
            // Show "scroll to bottom" icon when the most recent message is not visible,
            // or when the timelime is not live (this icon is used to go back to live).
            // Note: we check if `currentEventIdAtTableBottom` is set to know whether the table has been rendered at least once.
            if (!self.roomDataSource.isLive || (currentEventIdAtTableBottom && [self isBubblesTableScrollViewAtTheBottom] == NO))
            {
                // Retrieve the unread messages count
                NSUInteger unreadCount = self.roomDataSource.room.summary.localUnreadEventCount;
                
                if (unreadCount == 0)
                {
                    // Refresh the typing notification here
                    // We will keep visible this notification (if any) beside the "scroll to bottom" icon.
                    [self refreshTypingNotification];
                }
                
                [roomActivitiesView displayScrollToBottomIcon:unreadCount onIconTapGesture:^{
                    
                    [self goBackToLive];
                    
                }];
            }
            else if (serverNotices.usageLimit && serverNotices.usageLimit.isServerNoticeUsageLimit)
            {
                [roomActivitiesView showResourceUsageLimitNotice:serverNotices.usageLimit onAdminContactTapped:^(NSURL *adminContact) {

                    if ([[UIApplication sharedApplication] canOpenURL:adminContact])
                    {
                        [[UIApplication sharedApplication] openURL:adminContact];
                    }
                    else
                    {
                        NSLog(@"[RoomVC] refreshActivitiesViewDisplay: adminContact(%@) cannot be opened", adminContact);
                    }
                }];
            }
            else
            {
                [self refreshTypingNotification];
            }
        }
        
        // Recognize swipe downward to dismiss keyboard if any
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
        [swipe setNumberOfTouchesRequired:1];
        [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
        [roomActivitiesView addGestureRecognizer:swipe];
    }
}

- (void)goBackToLive
{
    if (!self.roomDataSource)
    {
        return;
    }
    
    if (self.roomDataSource.isLive)
    {
        // Enable the read marker display, and disable its update (in order to not mark as read all the new messages by default).
        self.roomDataSource.showReadMarker = YES;
        self.updateRoomReadMarker = NO;
        
        [self scrollBubblesTableViewToBottomAnimated:YES];
    }
    else
    {
        // Switch back to the room live timeline managed by MXKRoomDataSourceManager
        MXKRoomDataSourceManager *roomDataSourceManager = [MXKRoomDataSourceManager sharedManagerForMatrixSession:self.mainSession];

        MXWeakify(self);
        [roomDataSourceManager roomDataSourceForRoom:self.roomDataSource.roomId create:YES onComplete:^(MXKRoomDataSource *roomDataSource) {
            MXStrongifyAndReturnIfNil(self);

            // Scroll to bottom the bubble history on the display refresh.
            self->shouldScrollToBottomOnTableRefresh = YES;

            [self displayRoom:roomDataSource];

            // The room view controller do not have here the data source ownership.
            self.hasRoomDataSourceOwnership = NO;

            [self refreshActivitiesViewDisplay];
            [self refreshJumpToLastUnreadBannerDisplay];

            if (self.saveProgressTextInput)
            {
                // Restore the potential message partially typed before jump to last unread messages.
                self.inputToolbarView.textMessage = roomDataSource.partialTextMessage;
            }
        }];
    }
}

#pragma mark - Missed discussions handling

- (NSUInteger)missedDiscussionsCount
{
    return [self.mainSession riot_missedDiscussionsCount];
}

- (NSUInteger)missedHighlightDiscussionsCount
{
    return [self.mainSession missedHighlightDiscussionsCount];
}

- (void)refreshMissedDiscussionsCount:(BOOL)force
{
    // Ignore this action when no room is displayed
    if (!self.roomDataSource || !missedDiscussionsBarButtonCustomView)
    {
        return;
    }
    
    NSUInteger highlightCount = 0;
    NSUInteger missedCount = [self missedDiscussionsCount];
    
    // Compute the missed notifications count of the current room by considering its notification mode in Riot.
    NSUInteger roomNotificationCount = self.roomDataSource.room.summary.notificationCount;
    if (self.roomDataSource.room.isMentionsOnly)
    {
        // Only the highlighted missed messages must be considered here.
        roomNotificationCount = self.roomDataSource.room.summary.highlightCount;
    }
    
    // Remove the current room from the missed discussion counter.
    if (missedCount && roomNotificationCount)
    {
        missedCount--;
    }
    
    if (missedCount)
    {
        // Compute the missed highlight count
        highlightCount = [self missedHighlightDiscussionsCount];
        if (highlightCount && self.roomDataSource.room.summary.highlightCount)
        {
            // Remove the current room from the missed highlight counter
            highlightCount--;
        }
    }
    
    if (force || missedDiscussionsCount != missedCount || missedHighlightCount != highlightCount)
    {
        missedDiscussionsCount = missedCount;
        missedHighlightCount = highlightCount;
        
        NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray: self.navigationItem.leftBarButtonItems];
        
        if (missedCount)
        {
            // Refresh missed discussions count label
            if (missedCount > 99)
            {
                missedDiscussionsBadgeLabel.text = @"99+";
            }
            else
            {
                missedDiscussionsBadgeLabel.text = [NSString stringWithFormat:@"%tu", missedCount];
            }
            
            [missedDiscussionsBadgeLabel sizeToFit];
            
            // Update the label background view frame
            CGRect frame = missedDiscussionsBadgeLabelBgView.frame;
            frame.size.width = round(missedDiscussionsBadgeLabel.frame.size.width + 18);
            
            if ([GBDeviceInfo deviceInfo].osVersion.major < 11)
            {
                // Consider the main navigation controller if the current view controller is embedded inside a split view controller.
                UINavigationController *mainNavigationController = self.navigationController;
                if (self.splitViewController.isCollapsed && self.splitViewController.viewControllers.count)
                {
                    mainNavigationController = self.splitViewController.viewControllers.firstObject;
                }
                UINavigationItem *backItem = mainNavigationController.navigationBar.backItem;
                UIBarButtonItem *backButton = backItem.backBarButtonItem;
                
                if (backButton && !backButton.title.length)
                {
                    // Shift the badge on the left to be close the back icon
                    frame.origin.x = ([GBDeviceInfo deviceInfo].displayInfo.display > GBDeviceDisplay4Inch ? -35 : -25);
                }
                else
                {
                    frame.origin.x = 0;
                }
            }
            
            // Caution: set label background view frame only in case of changes to prevent from looping on 'viewDidLayoutSubviews'.
            if (!CGRectEqualToRect(missedDiscussionsBadgeLabelBgView.frame, frame))
            {
                missedDiscussionsBadgeLabelBgView.frame = frame;
            }
            
            // Set the right background color
            if (highlightCount)
            {
                missedDiscussionsBadgeLabelBgView.backgroundColor = kRiotColorPinkRed;
            }
            else
            {
                missedDiscussionsBadgeLabelBgView.backgroundColor = kRiotColorGreen;
            }
            
            if (!missedDiscussionsButton || [leftBarButtonItems indexOfObject:missedDiscussionsButton] == NSNotFound)
            {
                missedDiscussionsButton = [[UIBarButtonItem alloc] initWithCustomView:missedDiscussionsBarButtonCustomView];
                
                // Add it in left bar items
                [leftBarButtonItems addObject:missedDiscussionsButton];
            }
        }
        else if (missedDiscussionsButton)
        {
            [leftBarButtonItems removeObject:missedDiscussionsButton];
            missedDiscussionsButton = nil;
        }
        
        self.navigationItem.leftBarButtonItems = leftBarButtonItems;
    }
}

#pragma mark - Unsent Messages Handling

-(BOOL)checkUnsentMessages
{
    BOOL hasUnsent = NO;
    BOOL hasUnsentDueToUnknownDevices = NO;
    
    if ([self.activitiesView isKindOfClass:RoomActivitiesView.class])
    {
        NSArray<MXEvent*> *outgoingMsgs = self.roomDataSource.room.outgoingMessages;
        
        for (MXEvent *event in outgoingMsgs)
        {
            if (event.sentState == MXEventSentStateFailed)
            {
                hasUnsent = YES;
                
                // Check if the error is due to unknown devices
                if ([event.sentError.domain isEqualToString:MXEncryptingErrorDomain]
                    && event.sentError.code == MXEncryptingErrorUnknownDeviceCode)
                {
                    hasUnsentDueToUnknownDevices = YES;
                    break;
                }
            }
        }
        
        if (hasUnsent)
        {
            NSString *notification = hasUnsentDueToUnknownDevices ?
            NSLocalizedStringFromTable(@"room_unsent_messages_unknown_devices_notification", @"Vector", nil) :
            NSLocalizedStringFromTable(@"room_unsent_messages_notification", @"Vector", nil);
            
            RoomActivitiesView *roomActivitiesView = (RoomActivitiesView*) self.activitiesView;
            [roomActivitiesView displayUnsentMessagesNotification:notification withResendLink:^{
                
                [self resendAllUnsentMessages];
                
            } andCancelLink:^{
                
                [self cancelAllUnsentMessages];
                
            } andIconTapGesture:^{
                
                if (currentAlert)
                {
                    [currentAlert dismissViewControllerAnimated:NO completion:nil];
                }
                
                __weak __typeof(self) weakSelf = self;
                currentAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_resend_unsent_messages", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       [self resendAllUnsentMessages];
                                                                       self->currentAlert = nil;
                                                                   }
                                                                   
                                                               }]];
                
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"room_delete_unsent_messages", @"Vector", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       [self cancelAllUnsentMessages];
                                                                       self->currentAlert = nil;
                                                                   }
                                                                   
                                                               }]];
                
                [currentAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", @"Vector", nil)
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   if (weakSelf)
                                                                   {
                                                                       typeof(self) self = weakSelf;
                                                                       self->currentAlert = nil;
                                                                   }
                                                                   
                                                               }]];
                
                [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCUnsentMessagesMenuAlert"];
                [currentAlert popoverPresentationController].sourceView = roomActivitiesView;
                [currentAlert popoverPresentationController].sourceRect = roomActivitiesView.bounds;
                [self presentViewController:currentAlert animated:YES completion:nil];
                
            }];
        }
    }
    
    return hasUnsent;
}

- (void)eventDidChangeSentState:(NSNotification *)notif
{
    // We are only interested by event that has just failed in their encryption
    // because of unknown devices in the room
    MXEvent *event = notif.object;
    if (event.sentState == MXEventSentStateFailed &&
        [event.roomId isEqualToString:self.roomDataSource.roomId]
        && [event.sentError.domain isEqualToString:MXEncryptingErrorDomain]
        && event.sentError.code == MXEncryptingErrorUnknownDeviceCode
        && !unknownDevices)   // Show the alert once in case of resending several events
    {
        MXWeakify(self);
        
        [self dismissTemporarySubViews];
        
        // List all unknown devices
        unknownDevices  = [[MXUsersDevicesMap alloc] init];
        
        NSArray<MXEvent*> *outgoingMsgs = self.roomDataSource.room.outgoingMessages;
        for (MXEvent *event in outgoingMsgs)
        {
            if (event.sentState == MXEventSentStateFailed
                && [event.sentError.domain isEqualToString:MXEncryptingErrorDomain]
                && event.sentError.code == MXEncryptingErrorUnknownDeviceCode)
            {
                MXUsersDevicesMap<MXDeviceInfo*> *eventUnknownDevices = event.sentError.userInfo[MXEncryptingErrorUnknownDeviceDevicesKey];
                
                [unknownDevices addEntriesFromMap:eventUnknownDevices];
            }
        }
        
        // Tchap: automatically accept unknown devices for the moment, we will change this later.
        // Acknowledge the existence of all devices
        [self startActivityIndicator];
        [self.mainSession.crypto setDevicesKnown:self->unknownDevices complete:^{
            
            MXStrongifyAndReturnIfNil(self);
            self->unknownDevices = nil;
            [self stopActivityIndicator];
            
            // And resend pending messages
            [self resendAllUnsentMessages];
        }];
        
//        currentAlert = [UIAlertController alertControllerWithTitle:[NSBundle mxk_localizedStringForKey:@"unknown_devices_alert_title"]
//                                                           message:[NSBundle mxk_localizedStringForKey:@"unknown_devices_alert"]
//                                                    preferredStyle:UIAlertControllerStyleAlert];
//        
//        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"unknown_devices_verify"]
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//                                                           
//                                                           MXStrongifyAndReturnIfNil(self);
//                                                           self->currentAlert = nil;
//                                                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                                                           UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UsersDevicesNavigationControllerStoryboardId"];
//                                                           
//                                                           UsersDevicesViewController *usersDevicesViewController = navigationController.childViewControllers.firstObject;
//                                                           [usersDevicesViewController displayUsersDevices:self->unknownDevices andMatrixSession:self.roomDataSource.mxSession onComplete:nil];
//                                                           
//                                                           self->unknownDevices = nil;
//                                                           [self presentViewController:navigationController animated:YES completion:nil];
//                                                           
//                                                       }]];
//        
//        [currentAlert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"unknown_devices_send_anyway"]
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action) {
//                                                           
//                                                           MXStrongifyAndReturnIfNil(self);
//                                                           self->currentAlert = nil;
//                                                           
//                                                           // Acknowledge the existence of all devices
//                                                           [self startActivityIndicator];
//                                                           [self.mainSession.crypto setDevicesKnown:self->unknownDevices complete:^{
//                                                               
//                                                               self->unknownDevices = nil;
//                                                               [self stopActivityIndicator];
//                                                               
//                                                               // And resend pending messages
//                                                               [self resendAllUnsentMessages];
//                                                           }];
//                                                           
//                                                       }]];
//        
//        [currentAlert mxk_setAccessibilityIdentifier:@"RoomVCUnknownDevicesAlert"];
//        [self presentViewController:currentAlert animated:YES completion:nil];
    }
}


- (void)resendAllUnsentMessages
{
    // List unsent event ids
    NSArray *outgoingMsgs = self.roomDataSource.room.outgoingMessages;
    NSMutableArray *failedEventIds = [NSMutableArray arrayWithCapacity:outgoingMsgs.count];
    
    for (MXEvent *event in outgoingMsgs)
    {
        if (event.sentState == MXEventSentStateFailed)
        {
            [failedEventIds addObject:event.eventId];
        }
    }
    
    // Launch iterative operation
    [self resendFailedEvent:0 inArray:failedEventIds];
}

- (void)resendFailedEvent:(NSUInteger)index inArray:(NSArray*)failedEventIds
{
    if (index < failedEventIds.count)
    {
        NSString *failedEventId = failedEventIds[index];
        NSUInteger nextIndex = index + 1;
        
        // Let the datasource resend. It will manage local echo, etc.
        [self.roomDataSource resendEventWithEventId:failedEventId success:^(NSString *eventId) {
            
            [self resendFailedEvent:nextIndex inArray:failedEventIds];
            
        } failure:^(NSError *error) {
            
            [self resendFailedEvent:nextIndex inArray:failedEventIds];
            
        }];
        
        return;
    }
    
    // Refresh activities view
    [self refreshActivitiesViewDisplay];
}

- (void)cancelAllUnsentMessages
{
    // Remove unsent event ids
    for (NSUInteger index = 0; index < self.roomDataSource.room.outgoingMessages.count;)
    {
        MXEvent *event = self.roomDataSource.room.outgoingMessages[index];
        if (event.sentState == MXEventSentStateFailed)
        {
            [self.roomDataSource removeEventWithEventId:event.eventId];
        }
        else
        {
            index ++;
        }
    }
}

# pragma mark - Encryption Information view

- (void)showEncryptionInformation:(MXEvent *)event
{
    [self dismissKeyboard];
    
    // Remove potential existing subviews
    [self dismissTemporarySubViews];
    
    encryptionInfoView = [[EncryptionInfoView alloc] initWithEvent:event andMatrixSession:self.roomDataSource.mxSession];
    
    // Add shadow on added view
    encryptionInfoView.layer.cornerRadius = 5;
    encryptionInfoView.layer.shadowOffset = CGSizeMake(0, 1);
    encryptionInfoView.layer.shadowOpacity = 0.5f;
    
    // Add the view and define edge constraints
    [self.view addSubview:encryptionInfoView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:10.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:-10.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:encryptionInfoView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0f
                                                           constant:-10.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:encryptionInfoView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0f
                                                           constant:10.0f]];
    [self.view setNeedsUpdateConstraints];
}



#pragma mark - Read marker handling

- (void)checkReadMarkerVisibility
{
    if (readMarkerTableViewCell && isAppeared && !self.isBubbleTableViewDisplayInTransition)
    {
        // Check whether the read marker is visible
        CGFloat contentTopPosY = self.bubblesTableView.contentOffset.y + self.bubblesTableView.mxk_adjustedContentInset.top;
        CGFloat readMarkerViewPosY = readMarkerTableViewCell.frame.origin.y + readMarkerTableViewCell.readMarkerView.frame.origin.y;
        if (contentTopPosY <= readMarkerViewPosY)
        {
            // Compute the max vertical position visible according to contentOffset
            CGFloat contentBottomPosY = self.bubblesTableView.contentOffset.y + self.bubblesTableView.frame.size.height - self.bubblesTableView.mxk_adjustedContentInset.bottom;
            if (readMarkerViewPosY <= contentBottomPosY)
            {
                // Launch animation
                [self animateReadMarkerView];
                
                // Disable the read marker display when it has been rendered once.
                self.roomDataSource.showReadMarker = NO;
                [self refreshJumpToLastUnreadBannerDisplay];
                
                // Update the read marker position according the events acknowledgement in this view controller.
                self.updateRoomReadMarker = YES;
                
                if (self.roomDataSource.isLive)
                {
                    // Move the read marker to the current read receipt position.
                    [self.roomDataSource.room forgetReadMarker];
                }
            }
        }
    }
}

- (void)animateReadMarkerView
{
    // Check whether the cell with the read marker is known and if the marker is not animated yet.
    if (readMarkerTableViewCell && readMarkerTableViewCell.readMarkerView.isHidden)
    {
        RoomBubbleCellData *cellData = (RoomBubbleCellData*)readMarkerTableViewCell.bubbleData;
        
        // Do not display the marker if this is the last message.
        if (cellData.containsLastMessage && readMarkerTableViewCell.readMarkerView.tag == cellData.mostRecentComponentIndex)
        {
            readMarkerTableViewCell.readMarkerView.hidden = YES;
            readMarkerTableViewCell = nil;
        }
        else
        {
            readMarkerTableViewCell.readMarkerView.hidden = NO;
            
            // Animate the layout to hide the read marker
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     
                                     readMarkerTableViewCell.readMarkerViewLeadingConstraint.constant = readMarkerTableViewCell.readMarkerViewTrailingConstraint.constant = readMarkerTableViewCell.bubbleOverlayContainer.frame.size.width / 2;
                                     readMarkerTableViewCell.readMarkerView.alpha = 0;
                                     
                                     // Force to render the view
                                     [readMarkerTableViewCell.bubbleOverlayContainer layoutIfNeeded];
                                     
                                 }
                                 completion:^(BOOL finished){
                                     
                                     readMarkerTableViewCell.readMarkerView.hidden = YES;
                                     readMarkerTableViewCell.readMarkerView.alpha = 1;
                                     
                                     readMarkerTableViewCell = nil;
                                 }];
                
            });
        }
    }
}

- (void)refreshJumpToLastUnreadBannerDisplay
{
    // This banner is only displayed when the room timeline is in live (and no peeking).
    // Check whether the read marker exists and has not been rendered yet.
    if (self.roomDataSource.isLive && !self.roomDataSource.isPeeking && self.roomDataSource.showReadMarker && self.roomDataSource.room.accountData.readMarkerEventId)
    {
        UITableViewCell *cell = [self.bubblesTableView visibleCells].firstObject;
        if ([cell isKindOfClass:MXKRoomBubbleTableViewCell.class])
        {
            MXKRoomBubbleTableViewCell *roomBubbleTableViewCell = (MXKRoomBubbleTableViewCell*)cell;
            // Check whether the read marker is inside the first displayed cell.
            if (roomBubbleTableViewCell.readMarkerView)
            {
                // The read marker display is still enabled (see roomDataSource.showReadMarker flag),
                // this means the read marker was not been visible yet.
                // We show the banner if the marker is located in the top hidden part of the cell.
                CGFloat contentTopPosY = self.bubblesTableView.contentOffset.y + self.bubblesTableView.mxk_adjustedContentInset.top;
                CGFloat readMarkerViewPosY = roomBubbleTableViewCell.frame.origin.y + roomBubbleTableViewCell.readMarkerView.frame.origin.y;
                self.jumpToLastUnreadBannerContainer.hidden = (contentTopPosY < readMarkerViewPosY);
            }
            else
            {
                // Check whether the read marker event is anterior to the first event displayed in the first rendered cell.
                MXKRoomBubbleComponent *component = roomBubbleTableViewCell.bubbleData.bubbleComponents.firstObject;
                MXEvent *firstDisplayedEvent = component.event;
                MXEvent *currentReadMarkerEvent = [self.roomDataSource.mxSession.store eventWithEventId:self.roomDataSource.room.accountData.readMarkerEventId inRoom:self.roomDataSource.roomId];
                
                if (!currentReadMarkerEvent || (currentReadMarkerEvent.originServerTs < firstDisplayedEvent.originServerTs))
                {
                    self.jumpToLastUnreadBannerContainer.hidden = NO;
                }
                else
                {
                    self.jumpToLastUnreadBannerContainer.hidden = YES;
                }
            }
        }
    }
    else
    {
        self.jumpToLastUnreadBannerContainer.hidden = YES;
        
        // Initialize the read marker if it does not exist yet, only in case of live timeline.
        if (!self.roomDataSource.room.accountData.readMarkerEventId && self.roomDataSource.isLive && !self.roomDataSource.isPeeking)
        {
            // Move the read marker to the current read receipt position by default.
            [self.roomDataSource.room forgetReadMarker];
        }
    }
}

#pragma mark - Re-request encryption keys

- (void)reRequestKeysAndShowExplanationAlert:(MXEvent*)event
{
    MXWeakify(self);
    __block UIAlertController *alert;

    // Make the re-request
    [self.mainSession.crypto reRequestRoomKeyForEvent:event];

    // Observe kMXEventDidDecryptNotification to remove automatically the dialog
    // if the user has shared the keys from another device
    mxEventDidDecryptNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXEventDidDecryptNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        MXStrongifyAndReturnIfNil(self);

        MXEvent *decryptedEvent = notif.object;

        if ([decryptedEvent.eventId isEqualToString:event.eventId])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self->mxEventDidDecryptNotificationObserver];
            self->mxEventDidDecryptNotificationObserver = nil;

            if (self->currentAlert == alert)
            {
                [self->currentAlert dismissViewControllerAnimated:YES completion:nil];
                self->currentAlert = nil;
            }
        }
    }];

    // Show the explanation dialog
    alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"rerequest_keys_alert_title", @"Vector", nil)
                                                       message:NSLocalizedStringFromTable(@"rerequest_keys_alert_message", @"Vector", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
    currentAlert = alert;


    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle mxk_localizedStringForKey:@"ok"]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 MXStrongifyAndReturnIfNil(self);

                                 [[NSNotificationCenter defaultCenter] removeObserver:self->mxEventDidDecryptNotificationObserver];
                                 self->mxEventDidDecryptNotificationObserver = nil;

                                 self->currentAlert = nil;
                             }]];

    [self presentViewController:currentAlert animated:YES completion:nil];
}

#pragma mark Tombstone event

- (void)listenTombstoneEventNotifications
{
    // Room is already obsolete do not listen to tombstone event
    if (self.roomDataSource.roomState.isObsolete)
    {
        return;
    }
    
    MXWeakify(self);
    
    tombstoneEventNotificationsListener = [self.roomDataSource.room listenToEventsOfTypes:@[kMXEventTypeStringRoomTombStone] onEvent:^(MXEvent *event, MXTimelineDirection direction, MXRoomState *roomState) {
        
        MXStrongifyAndReturnIfNil(self);
        
        // Update activitiesView with room replacement information
        [self refreshActivitiesViewDisplay];
        // Hide inputToolbarView
        [self updateRoomInputToolbarViewClassIfNeeded];
    }];
}

- (void)removeTombstoneEventNotificationsListener
{
    if (self.roomDataSource)
    {
        // Remove the previous live listener
        if (tombstoneEventNotificationsListener)
        {
            [self.roomDataSource.room removeListener:tombstoneEventNotificationsListener];
            tombstoneEventNotificationsListener = nil;
        }
    }
}

#pragma mark MXSession state change

- (void)listenMXSessionStateChangeNotifications
{
    kMXSessionStateDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMXSessionStateDidChangeNotification object:self.roomDataSource.mxSession queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {

        if (self.roomDataSource.mxSession.state == MXSessionStateSyncError
            || self.roomDataSource.mxSession.state == MXSessionStateRunning)
        {
            [self refreshActivitiesViewDisplay];

            // update inputToolbarView
            [self updateRoomInputToolbarViewClassIfNeeded];
        }
    }];
}

- (void)removeMXSessionStateChangeNotificationsListener
{
    if (kMXSessionStateDidChangeObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMXSessionStateDidChangeObserver];
        kMXSessionStateDidChangeObserver = nil;
    }
}

@end

