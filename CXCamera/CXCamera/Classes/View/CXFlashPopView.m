//
//  CXFlashPopView.m
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXFlashPopView.h"
#import "UIView+CXExtension.h"


static const CGFloat kCXFlashPopViewWidth = 44.0f;  // pop视图的宽度

static const CGFloat kCXFlashPopOffset = 4.0f;

static const CGFloat kCXFlashAnimationDuration = 0.2f;


static NSString *kCXPopTableViewCellIdentifier = @"kCXPopTableViewCellIdentifier";





#pragma mark - CXPopItem



@interface CXPopItem ()

@end

@implementation CXPopItem

+ (instancetype)popItemWithFalshMode:(CXCaptureFlashMode)flashMode imageName:(NSString *)imageName
{
    CXPopItem *item = [[self alloc] init];
    item.flashMode = flashMode;
    item.imageName = imageName;
    return item;
}

@end





#pragma mark - CXPopTableViewCell



@interface CXPopTableViewCell : UITableViewCell

@property (nonatomic,weak) UIImageView *iconView;

@property (nonatomic,strong) CXPopItem *item;

@end

@implementation CXPopTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.userInteractionEnabled = YES;
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (void)setItem:(CXPopItem *)item
{
    _item = item;
    [self.iconView setImage:[UIImage imageNamed:item.imageName]];
    [self.iconView sizeToFit];
}

@end





#pragma mark - CXFlashPopView




@interface CXFlashPopView ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,weak) UIImageView *imageView;

@property (nonatomic,strong) NSArray<CXPopItem *> *items;

@property (nonatomic,weak) UITableView *tableView;


@end

@implementation CXFlashPopView

- (instancetype)initWithItems:(NSArray<CXPopItem *> *)items
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.items = items;
        
        [self setupContent];
        
        [self setupBackground];
        
        [self setupTableView];
    }
    return self;
}

- (void)showFromView:(UIView *)from toView:(UIView *)to
{
    self.showing = YES;
    if (!self.items || self.items.count == 0) return;
    
    [from addSubview:self];
    self.frame = from.bounds;
    
    NSInteger count = self.items.count;
    CGRect toRect = [self convertRect:to.frame toView:self];
    
    
    CGFloat contentW = kCXFlashPopViewWidth;
    CGFloat contentH = count * kCXFlashPopViewWidth + kCXFlashPopOffset;
    CGFloat contentX = toRect.origin.x;
    CGFloat contentY = CGRectGetMaxY(toRect);
    

    self.contentView.frame = CGRectMake(contentX, contentY, contentW, 0);

    self.imageView.frame = CGRectMake(0, 0, contentW, 0);
    
    self.tableView.frame = CGRectMake(0, 0, contentW, 0);
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:kCXFlashAnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentView.height = contentH;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
  

    
}

- (void)dismiss
{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:kCXFlashAnimationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentView.height = 0.f;
    } completion:^(BOOL finished) {
        self.showing = NO;
        self.userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

- (void)setupContent
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (void)setupBackground
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage *image = [UIImage imageNamed:@"camera_flash_setting_bg"];
    CGFloat top = image.size.height * 0.5;
    CGFloat bottom = image.size.height * 0.5;
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0, bottom, 0);
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    imageView.image = image;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;

}

- (void)setupTableView
{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = kCXFlashPopViewWidth;
    tableView.contentInset = UIEdgeInsetsMake(kCXFlashPopOffset, 0, 0, 0);
    [tableView registerClass:[CXPopTableViewCell class] forCellReuseIdentifier:kCXPopTableViewCellIdentifier];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tableView];
    self.tableView = tableView;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CXPopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCXPopTableViewCellIdentifier];
    cell.item = self.items[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(flashPopView:itemDidSelected:)]) {
        [self.delegate flashPopView:self itemDidSelected:self.items[indexPath.row]];
    }
}



@end










