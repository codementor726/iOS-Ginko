//
//  Countries.m
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "Countries.h"

@implementation Countries
+ (NSArray *)countries {
    static NSArray *countries = nil;
    if (!countries) {
        NSMutableArray *tempCountries = [NSMutableArray new];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AF" phoneExtension:@"93" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AL" phoneExtension:@"355" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DZ" phoneExtension:@"213" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AS" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AD" phoneExtension:@"376" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AO" phoneExtension:@"244" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AI" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AQ" phoneExtension:@"672" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AG" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AR" phoneExtension:@"54" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AM" phoneExtension:@"374" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AW" phoneExtension:@"297" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AU" phoneExtension:@"61" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AT" phoneExtension:@"43" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AZ" phoneExtension:@"994" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BS" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BH" phoneExtension:@"973" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BD" phoneExtension:@"880" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BB" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BY" phoneExtension:@"375" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BE" phoneExtension:@"32" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BZ" phoneExtension:@"501" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BJ" phoneExtension:@"229" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BM" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BT" phoneExtension:@"975" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BO" phoneExtension:@"591" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BA" phoneExtension:@"387" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BW" phoneExtension:@"267" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BR" phoneExtension:@"55" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IO" phoneExtension:@"246" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VG" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BN" phoneExtension:@"673" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BG" phoneExtension:@"359" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BF" phoneExtension:@"226" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BI" phoneExtension:@"257" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KH" phoneExtension:@"855" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CM" phoneExtension:@"237" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CA" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CV" phoneExtension:@"238" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KY" phoneExtension:@"1" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CF" phoneExtension:@"236" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TD" phoneExtension:@"235" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CL" phoneExtension:@"56" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CN" phoneExtension:@"86" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CX" phoneExtension:@"61" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CC" phoneExtension:@"61" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CO" phoneExtension:@"57" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KM" phoneExtension:@"269" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CK" phoneExtension:@"682" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CR" phoneExtension:@"506" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"HR" phoneExtension:@"385" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CU" phoneExtension:@"53" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CW" phoneExtension:@"599" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CY" phoneExtension:@"357" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CZ" phoneExtension:@"420" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CD" phoneExtension:@"243" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DK" phoneExtension:@"45" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DJ" phoneExtension:@"253" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DM" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DO" phoneExtension:@"1" isMain:NO]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TL" phoneExtension:@"670" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"EC" phoneExtension:@"593" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"EG" phoneExtension:@"20" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SV" phoneExtension:@"503" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GQ" phoneExtension:@"240" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ER" phoneExtension:@"291" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"EE" phoneExtension:@"372" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ET" phoneExtension:@"251" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FK" phoneExtension:@"500" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FO" phoneExtension:@"298" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FJ" phoneExtension:@"679" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FI" phoneExtension:@"358" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FR" phoneExtension:@"33" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PF" phoneExtension:@"689" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GA" phoneExtension:@"241" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GM" phoneExtension:@"220" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GE" phoneExtension:@"995" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"DE" phoneExtension:@"49" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GH" phoneExtension:@"233" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GI" phoneExtension:@"350" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GR" phoneExtension:@"30" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GL" phoneExtension:@"299" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GD" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GU" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GT" phoneExtension:@"502" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GG" phoneExtension:@"44" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GN" phoneExtension:@"224" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GW" phoneExtension:@"245" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GY" phoneExtension:@"592" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"HT" phoneExtension:@"509" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"HN" phoneExtension:@"504" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"HK" phoneExtension:@"652" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"HU" phoneExtension:@"36" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IS" phoneExtension:@"354" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IN" phoneExtension:@"91" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ID" phoneExtension:@"62" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IR" phoneExtension:@"98" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IQ" phoneExtension:@"964" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IE" phoneExtension:@"353" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IM" phoneExtension:@"44" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IL" phoneExtension:@"972" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"IT" phoneExtension:@"39" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CI" phoneExtension:@"225" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"JM" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"JP" phoneExtension:@"81" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"JE" phoneExtension:@"44" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"JO" phoneExtension:@"962" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KZ" phoneExtension:@"7" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KE" phoneExtension:@"254" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KI" phoneExtension:@"686" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"XK" phoneExtension:@"383" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KW" phoneExtension:@"965" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KG" phoneExtension:@"996" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LA" phoneExtension:@"856" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LV" phoneExtension:@"371" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LB" phoneExtension:@"961" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LS" phoneExtension:@"266" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LR" phoneExtension:@"231" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LY" phoneExtension:@"218" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LI" phoneExtension:@"423" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LT" phoneExtension:@"370" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LU" phoneExtension:@"352" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MO" phoneExtension:@"853" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MK" phoneExtension:@"389" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MG" phoneExtension:@"261" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MW" phoneExtension:@"265" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MY" phoneExtension:@"60" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MV" phoneExtension:@"960" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ML" phoneExtension:@"223" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MT" phoneExtension:@"356" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MH" phoneExtension:@"692" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MR" phoneExtension:@"222" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MU" phoneExtension:@"230" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"YT" phoneExtension:@"262" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MX" phoneExtension:@"52" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"FM" phoneExtension:@"691" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MD" phoneExtension:@"373" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MC" phoneExtension:@"377" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MN" phoneExtension:@"976" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ME" phoneExtension:@"382" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MS" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MA" phoneExtension:@"212" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MZ" phoneExtension:@"258" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MM" phoneExtension:@"95" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NA" phoneExtension:@"264" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NR" phoneExtension:@"674" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NP" phoneExtension:@"977" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NL" phoneExtension:@"31" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AN" phoneExtension:@"599" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NC" phoneExtension:@"687" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NZ" phoneExtension:@"64" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NI" phoneExtension:@"505" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NE" phoneExtension:@"227" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NG" phoneExtension:@"234" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NU" phoneExtension:@"683" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KP" phoneExtension:@"850" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MP" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"NO" phoneExtension:@"47" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"OM" phoneExtension:@"968" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PK" phoneExtension:@"92" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PW" phoneExtension:@"680" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PS" phoneExtension:@"970" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PA" phoneExtension:@"507" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PG" phoneExtension:@"675" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PY" phoneExtension:@"595" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PE" phoneExtension:@"51" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PH" phoneExtension:@"63" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PN" phoneExtension:@"64" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PL" phoneExtension:@"48" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PT" phoneExtension:@"351" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PR" phoneExtension:@"1" isMain:NO]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"QA" phoneExtension:@"974" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CG" phoneExtension:@"242" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"RE" phoneExtension:@"262" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"RO" phoneExtension:@"40" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"RU" phoneExtension:@"7" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"RW" phoneExtension:@"250" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"BL" phoneExtension:@"590" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SH" phoneExtension:@"290" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KN" phoneExtension:@"1" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LC" phoneExtension:@"1" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"MF" phoneExtension:@"590" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"PM" phoneExtension:@"508" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VC" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"WS" phoneExtension:@"685" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SM" phoneExtension:@"378" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ST" phoneExtension:@"239" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SA" phoneExtension:@"966" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SN" phoneExtension:@"221" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"RS" phoneExtension:@"381" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SC" phoneExtension:@"248" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SL" phoneExtension:@"232" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SG" phoneExtension:@"65" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SX" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SK" phoneExtension:@"421" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SI" phoneExtension:@"386" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SB" phoneExtension:@"677" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SO" phoneExtension:@"252" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ZA" phoneExtension:@"27" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"KR" phoneExtension:@"82" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SS" phoneExtension:@"211" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ES" phoneExtension:@"34" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"LK" phoneExtension:@"94" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SD" phoneExtension:@"249" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SR" phoneExtension:@"597" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SJ" phoneExtension:@"47" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SZ" phoneExtension:@"268" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SE" phoneExtension:@"46" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"CH" phoneExtension:@"41" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"SY" phoneExtension:@"963" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TW" phoneExtension:@"886" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TJ" phoneExtension:@"992" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TZ" phoneExtension:@"255" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TH" phoneExtension:@"66" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TG" phoneExtension:@"228" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TK" phoneExtension:@"690" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TO" phoneExtension:@"676" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TT" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TN" phoneExtension:@"216" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TR" phoneExtension:@"90" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TM" phoneExtension:@"993" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TC" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"TV" phoneExtension:@"688" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VI" phoneExtension:@"1" isMain:NO]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"UG" phoneExtension:@"256" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"UA" phoneExtension:@"380" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"AE" phoneExtension:@"971" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"GB" phoneExtension:@"44" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"US" phoneExtension:@"1" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"UY" phoneExtension:@"598" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"UZ" phoneExtension:@"998" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VU" phoneExtension:@"678" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VA" phoneExtension:@"379" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VE" phoneExtension:@"58" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"VN" phoneExtension:@"84" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"WF" phoneExtension:@"681" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"EH" phoneExtension:@"212" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"YE" phoneExtension:@"93" isMain:YES]];
        
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ZM" phoneExtension:@"260" isMain:YES]];
        [tempCountries addObject:[[Country alloc] initWithCountryCode:@"ZW" phoneExtension:@"263" isMain:YES]];
        
        countries = [tempCountries copy];
    }
    return countries;
}

+ (Country *)countryFromPhoneExtension:(NSString *)phoneExtension {
    phoneExtension = [phoneExtension stringByReplacingOccurrencesOfString:@"+" withString:@""];
    for (Country *country in [Countries countries]) {
        if (country.isMain && [phoneExtension isEqualToString:country.phoneExtension]) {
            return country;
        }
    }
    return [Country emptyCountry];
}

+ (Country *)countryFromCountryCode:(NSString *)countryCode {
    for (Country *country in [Countries countries]) {
        if ([countryCode isEqualToString:country.countryCode])
            return country;
    }
    return [Country emptyCountry];
}

+ (NSArray *)countriesFromCountryCodes:(NSArray *)countryCodes {
    return [[Countries countries] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryCode IN %@", countryCodes]];
}


@end
