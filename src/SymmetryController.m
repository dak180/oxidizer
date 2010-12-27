#import "SymmetryController.h"

@implementation SymmetryController

- (void) setSymmetry:(NSString *)value {

	NSScanner *scanner;
	int tmpValue;

	if([value compare:@"No Symmetry"] == NSOrderedSame) {

		_flameSymmetry = 1;
		return;
	}

	if([value compare:@"Dihedral Symmetry"] ==  NSOrderedSame) {

		_flameSymmetry = -1;
		return;
	}


	if([value compare:@"Random"] ==  NSOrderedSame) {

		_flameSymmetry = 0;
		return;
	}

	if([value compare:@"1"] == NSOrderedSame) {

		[self willChangeValueForKey:@"symmetry"];

		_flameSymmetry = 1;

		[self didChangeValueForKey:@"symmetry"];


		NSLog(@"set symmetry to %@\n", [self symmetry]);

		return;
	}

	if([value compare:@"-1"] ==  NSOrderedSame) {

		[self willChangeValueForKey:@"symmetry"];

		_flameSymmetry = -1;
//		NSLog(@"set symmetry to %@\n", [self symmetry]);

		[self didChangeValueForKey:@"symmetry"];


		return;
	}

	if([value compare:@"0"] ==  NSOrderedSame) {


		_flameSymmetry = 0;

		[self didChangeValueForKey:@"symmetry"];

		NSLog(@"set symmetry to %@\n", [self symmetry]);

		return;
	}

	scanner = [NSScanner scannerWithString:value];
	if([scanner scanInt:&tmpValue]) {

		_flameSymmetry = tmpValue;
		NSLog(@"set symmetry to %@\n", [self symmetry]);

	}


}
- (NSString *) symmetry {

		NSLog(@"called symmetry when value = %ld\n", _flameSymmetry);


	switch(_flameSymmetry) {
		case 1:
			return @"No Symmetry";
		case -1:
			return @"Dihedral Symmetry";
		case 0:
			return @"Random";
		default:
			return [NSString stringWithFormat:@"%ld", _flameSymmetry];
	}

	return nil;

}

- (int) getIntSymmetry {

	return _flameSymmetry;

}

- (void) setIntSymmetry:(int)value {

	switch(value) {
		case 1:
			[self setSymmetry:@"No Symmetry"];
			break;
		case -1:
			[self setSymmetry:@"Dihedral Symmetry"];
			break;
		case 0:
			[self setSymmetry:@"Random"];
			break;
		default:
			[self setSymmetry:[NSString stringWithFormat:@"%ld", _flameSymmetry]];
			break;
	}
}

@end
