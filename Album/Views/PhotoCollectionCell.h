//
//  PhotoCollectionCell.h
//  Album
//
//  Created by Airei Fukuzawa on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "Parse/PFImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *photoImageView;

@end

NS_ASSUME_NONNULL_END
