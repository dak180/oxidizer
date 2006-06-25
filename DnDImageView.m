#import "DnDImageView.h"

@implementation DnDImageView

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal) return NSDragOperationCopy;
	return NSDragOperationCopy|NSDragOperationGeneric|NSDragOperationLink;
}

// The simple dragImage:at:offset:event:pasteboard:source:slideback: method
// is all we do to initiate and run the actual drag sequence
// But we only do this if we have an image and we successfully write our data
// to the pasteboard in copyDataTo: method

- (void)mouseDown:(NSEvent *)e
{
NSPoint location;
NSSize size;
NSPasteboard *pboard = [NSPasteboard pasteboardWithName:(NSString *) NSDragPboard];

	NSDictionary *binding = [self infoForBinding:NSValueBinding];
	
	NSArrayController *breedGenomeController = [binding objectForKey:NSObservedObjectKey];
	NSManagedObject *mo = [[breedGenomeController selectedObjects] objectAtIndex:0];
	NSImage *image = [mo valueForKey:@"image"];
	
    NSArray *types = [NSArray arrayWithObjects:@"Genomes", @"GenomeMoc", nil];

	NSManagedObjectContext *moc = [breedGenomeController managedObjectContext] ;
	NSData *mocData = [NSData dataWithBytes:&moc length:sizeof(NSManagedObjectContext *)];

    NSArray *genomes = [NSArray arrayWithObject:[NSData dataWithBytes:&mo length:sizeof(NSManagedObject *)]];


	[pboard declareTypes:types owner:self];
	[pboard setPropertyList:genomes forType:@"Genomes"];
	[pboard setPropertyList:[NSArray arrayWithObject:mocData] forType: @"GenomeMoc"];



	if (image) {
		size = [image size];
		location.x = ([self bounds].size.width - size.width)/2;
		location.y = ([self bounds].size.height - size.height)/2;

		[self dragImage:image at:location offset:NSZeroSize event:(NSEvent *)e pasteboard:pboard source:self slideBack:YES];
	}
}

@end
