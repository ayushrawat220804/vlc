/*****************************************************************************
 * VLCLibraryUIUnits.m: MacOS X interface module
 *****************************************************************************
 * Copyright (C) 2022 VLC authors and VideoLAN
 *
 * Authors: Claudio Cambra <developer@claudiocambra.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "VLCLibraryUIUnits.h"

#import "extensions/NSWindow+VLCAdditions.h"

#import "library/VLCLibraryCollectionViewFlowLayout.h"
#import "library/VLCLibraryCollectionViewItem.h"
#import "library/VLCLibraryWindow.h"

#import "main/VLCMain.h"

#import "views/VLCBottomBarView.h"

#import "windows/controlsbar/VLCControlsBarCommon.h"

NSString * const VLCLibraryCollectionViewItemAdjustmentKey = @"VLCLibraryCollectionViewItemAdjustmentKey";

@implementation VLCLibraryUIUnits

+ (const CGFloat)largeSpacing
{
    return 20;
}

+ (const CGFloat)mediumSpacing
{
    return 10;
}

+ (const CGFloat)smallSpacing
{
    return 5;
}

+ (const CGFloat)cornerRadius
{
    return 5.;
}

+ (const CGFloat)borderThickness
{
    return 1.;
}

+ (const CGFloat)scrollBarSmallSideSize
{
    return 16;
}

+ (const CGFloat)largeTableViewRowHeight
{
    return 100;
}

+ (const CGFloat)mediumTableViewRowHeight
{
    return 50;
}

+ (const CGFloat)smallTableViewRowHeight
{
    return 25;
}

+ (const CGFloat)mediumDetailSupplementaryViewCollectionViewWidth
{
    return 600;
}

+ (const CGFloat)mediumDetailSupplementaryViewCollectionViewHeight
{
    return 300;
}

+ (const CGFloat)largeDetailSupplementaryViewCollectionViewWidth
{
    return 800;
}

+ (const CGFloat)largeDetailSupplementaryViewCollectionViewHeight
{
    return 500;
}

+ (const CGFloat)dynamicCollectionViewItemMinimumWidth
{
    return 150;
}

+ (const CGFloat)dynamicCollectionViewItemMaximumWidth
{
    return 200;
}

+ (const CGFloat)collectionViewItemSpacing
{
    return [self largeSpacing];
}

+ (const NSEdgeInsets)collectionViewSectionInsets
{
    const CGFloat inset = [self largeSpacing];
    return NSEdgeInsetsMake(inset, inset, inset, inset);
}

+ (const NSSize)adjustedCollectionViewItemSizeForCollectionView:(NSCollectionView *)collectionView
                                                     withLayout:(VLCLibraryCollectionViewFlowLayout *)collectionViewLayout
                                           withItemsAspectRatio:(VLCLibraryCollectionViewItemAspectRatio)itemsAspectRatio
{
    uint numItemsInRow = 5;
    static const uint kMinItemsInCollectionViewRow = 1;

    NSSize itemSize = [self itemSizeForCollectionView:collectionView
                                           withLayout:collectionViewLayout
                                 withItemsAspectRatio:itemsAspectRatio
                               withNumberOfItemsInRow:numItemsInRow];

    while (itemSize.width > VLCLibraryUIUnits.dynamicCollectionViewItemMaximumWidth) {
        ++numItemsInRow;
        itemSize = [self itemSizeForCollectionView:collectionView
                                        withLayout:collectionViewLayout
                              withItemsAspectRatio:itemsAspectRatio
                            withNumberOfItemsInRow:numItemsInRow];
    }
    while (itemSize.width < VLCLibraryUIUnits.dynamicCollectionViewItemMinimumWidth && numItemsInRow > kMinItemsInCollectionViewRow) {
        --numItemsInRow;
        itemSize = [self itemSizeForCollectionView:collectionView
                                        withLayout:collectionViewLayout
                              withItemsAspectRatio:itemsAspectRatio
                            withNumberOfItemsInRow:numItemsInRow];
    }

    const NSInteger adjustment =
        [NSUserDefaults.standardUserDefaults integerForKey:VLCLibraryCollectionViewItemAdjustmentKey];
    if (adjustment != 0 && numItemsInRow + adjustment > kMinItemsInCollectionViewRow) {
        numItemsInRow += adjustment;
        itemSize = [self itemSizeForCollectionView:collectionView
                                        withLayout:collectionViewLayout
                              withItemsAspectRatio:itemsAspectRatio
                            withNumberOfItemsInRow:numItemsInRow];
    }

    return itemSize;
}

+ (const NSSize)itemSizeForCollectionView:(NSCollectionView *)collectionView
                               withLayout:(VLCLibraryCollectionViewFlowLayout *)collectionViewLayout
                     withItemsAspectRatio:(VLCLibraryCollectionViewItemAspectRatio)itemsAspectRatio
                   withNumberOfItemsInRow:(uint)numItemsInRow
{
    NSParameterAssert(numItemsInRow > 0);
    NSParameterAssert(collectionView);
    NSParameterAssert(collectionViewLayout);

    const NSEdgeInsets sectionInsets = collectionViewLayout.sectionInset;
    const CGFloat interItemSpacing = collectionViewLayout.minimumInteritemSpacing;

    const CGFloat rowOfItemsWidth = collectionView.bounds.size.width -
                                    (sectionInsets.left +
                                     sectionInsets.right +
                                     (interItemSpacing * (numItemsInRow - 1)) +
                                     1);

    const CGFloat itemWidth = MAX(rowOfItemsWidth / numItemsInRow, 1);
    const CGFloat itemHeight = itemsAspectRatio == VLCLibraryCollectionViewItemAspectRatioDefaultItem ?
        itemWidth + VLCLibraryCollectionViewItem.bottomTextViewsHeight :
        (itemWidth * [VLCLibraryCollectionViewItem videoHeightAspectRatioMultiplier]) + VLCLibraryCollectionViewItem.bottomTextViewsHeight;

    return NSMakeSize(itemWidth, itemHeight);
}

+ (const CGFloat)carouselViewVideoItemViewWidth
{
    return self.carouselViewItemViewHeight / 9 * 16;
}

+ (const CGFloat)carouselViewItemViewHeight
{
    return 180;
}

+ (const NSEdgeInsets)libraryViewScrollViewContentInsets
{
    VLCLibraryWindow * const libraryWindow = VLCMain.sharedInstance.libraryWindow;
    const CGFloat toolbarHeight = libraryWindow.titlebarHeight;

    return NSEdgeInsetsMake(VLCLibraryUIUnits.mediumSpacing + toolbarHeight,
                            VLCLibraryUIUnits.mediumSpacing,
                            VLCLibraryUIUnits.mediumSpacing,
                            VLCLibraryUIUnits.mediumSpacing);
}

+ (const NSEdgeInsets)libraryViewScrollViewScrollerInsets
{
    VLCLibraryWindow * const libraryWindow = VLCMain.sharedInstance.libraryWindow;
    const CGFloat toolbarHeight = libraryWindow.titlebarHeight;

    const NSEdgeInsets contentInsets = [self libraryViewScrollViewContentInsets];
    return NSEdgeInsetsMake(-contentInsets.top + toolbarHeight,
                            -contentInsets.left,
                            -contentInsets.bottom,
                            -contentInsets.right);
}

+ (const CGFloat)controlsFadeAnimationDuration
{
    return 0.4f;
}

+ (const CGFloat)librarySplitViewSelectionViewDefaultWidth
{
    return 180.;
}

+ (const CGFloat)librarySplitViewMainViewMinimumWidth
{
    return 400.;
}

+ (const CGFloat)libraryWindowControlsBarHeight
{
    return 48.;
}

+ (const CGFloat)libraryWindowNavSidebarMinWidth
{
    return 180.;
}

+ (const CGFloat)libraryWindowNavSidebarMaxWidth
{
    return 300.;
}

+ (const CGFloat)libraryWindowPlayQueueSidebarMaxWidth
{
    return 400.;
}

+ (const CGFloat)largePlaybackControlButtonSize
{
    return 64.;
}

+ (const CGFloat)mediumPlaybackControlButtonSize
{
    return 48.;
}

+ (const CGFloat)smallPlaybackControlButtonSize
{
    return 32.;
}

+ (const CGFloat)sliderTickThickness
{
    return 1.;
}

@end
