#ifndef DATA_H_
#define DATA_H

#include <Arduino.h>

static const unsigned char isp_data[] PROGMEM  = "\
:2000000006001800000008001B0001000000060018001000090010005B001000C008001B09\
:20002000000000303A08000F005B000338060018000100090010005B00108049060018001F\
:200040001100090010003000100092090001003000000100090004003000000000C800095B\
:20006000003000BF0000FBE8CA40CA00CB00CA00C200000000000000C93070801E0D9A28AD\
:20008000000E480C5CECAA00E2600FA47F0EF60C3E0B907FB302B8B266EB20B8EAA8CD8009\
:2000A000B8B80CA6F50C618000D280D3C0B80258D280F2580B8612340000000017299742B9\
:2000C000C08012EE2C03E893330F3C4000800080801E119A2800127B10B9AA00E260143E73\
:2000E0007F135D0F35D70EF67FB302B8B266EB20B8EAA8CD80B880105F1004EB20D280D361\
:20010000C0B8FBE838D280F258C5E400000000000017299742C08012EE03E893330F3C4072\
:2001200000800080B90900010030001001000900040030001001000A000A003000EF0040FA\
:2001400040090001003000BD01000A000A003000EF004040090004003000BD0000090001B0\
:20016000003000BD012B0A000A003000EF004040090001003000BD01D40A000A003000EFB4\
:20018000004040090004003000BD00D4090001003000BD01000A000A003000EF004040095D\
:2001A0000004003000BD0000090001003000BD012B0A000A003000EF00404009000100303E\
:2001C00000BD01D40A000A003000EF004040090004003000BD00D4090001003000BE002BE9\
:2001E0000A000A003000EF004040090004003000BD0000090001003000BD002B0A000A001C\
:200200003000EF004040090001003000BD00D40A000A003000EF004040090004003000BDC7\
:2002200000D40A0005003000BF0000040A000A003000EF0040400A0005003000BF006000D7\
:200240000A000A003000EF004040090001003000BD00000A000A003000EF00404009000434\
:20026000003000BD0000090001003000BD002B0A000A003000EF004040090001003000BDC5\
:2002800000D40A000A003000EF004040090004003000BD00D408001E003000BF00090004E7\
:2002A000003000BD000009000C00300000E80306000D000A000600180002000600180012B4\
:2002C00000090010005B001000C008001B000000303A08000F005B00033809000100300066\
:2002E0000001000900040030000000000900010030001001000900040030001001000A001D\
:200300000A003000EF004040090001003000BD01000A000A003000EF00404009000400304C\
:2003200000BD0000090001003000BD012B0A000A003000EF004040090001003000BD01D45E\
:200340000A000A003000EF004040090004003000BD00D4090001003000BD01000A000A0010\
:200360003000EF004040090004003000BD0000090001003000BD012B0A000A003000EF008E\
:200380004040090001003000BD01D40A000A003000EF004040090004003000BD00D40A0086\
:2003A00005003000BF0000040A000A003000EF0040400A0005003000BF0060000A000A0020\
:2003C0003000EF00404008001F003000BF00090004003000BD000009001000300010801B7A\
:2003E0000600180013000600180011000900100032001000390900010032000001000900C3\
:2004000004003200000000080209003200BF00801E000030008066329A2D40CA00CAE0EA57\
:2004200033377FCD34332BCD287F9AB3BF66A0B266B47820EBB8A8EA008080CDB800CBB84D\
:20044000C0CA00CA80C3B8A42CAE2B20F38067D2C0D3B820FB00005700000000000000001B\
:2004600000008000808000FB0F010100000FC60F0000EE12E803BA0120EB008000800F301C\
:200480000000C23C0F0700400080801E9A391D00807B3CB936E0EA3E427F5D3FD733F6303F\
:2004A0007F9AB3BF66B266B47820EBB8A8EA67008080CDB892356B3458FA80D2C0D3B85819\
:2004C000FAB60300000000008000808000019B01A6010000C23C0F00400080801E004000FA\
:2004E000803343CD3CE0EA9A497F66469A39A866367F9AB3BF66B266B47820EBB8A8EA0084\
:200500008080CDB8853B3D3A20FB80D2C0D353B820F3526E000000000080008080000101BF\
:2005200097010000C23C0F00400080801E66C6460080EB49E142E0EAF5507F704D5C3FD7B2\
:200540003B7F9AB3BF66B266B47820EBB8A8A4EA008080CDB878411040E8FB80D2C0D3B824\
:2005600020EBD1CC00000000008000808000750101DA010000C23C0F004000800000000034\
:20058000000000000000000000000000000007000000000000000000000000000000000054\
:2005A00000000000000000000000000000000000000000000000000000000000000000003B\
:2005C00000000000000000000000000000000000000000000000000000000000000000001B\
:2005E0000000000000000000000000000000000000000000000000000000000000000000FB\
:2006000000000000000000000000000000000009000100320010010009000400320010013D\
:20062000000A000A003200EF004040090001003200BD01000A000A003200EF00404009004D\
:2006400004003200BD0000090001003200BD012B0A000A003200EF00404009000100320091\
:20066000BD01D40A000A003200EF004040090004003200BD00D4090001003200BD01000A5F\
:20068000000A003200EF004040090004003200BD0000090001003200BD012B0A000A003248\
:2006A00000EF004040090001003200BD01D40A000A003200EF004040090004003200BD004C\
:2006C000D4090001003200BE002B0A000A003200EF004040090004003200BD000009000166\
:2006E000003200BD002B0A000A003200EF004040090001003200BD00D40A000A003200EF29\
:20070000004040090004003200BD00D40A0005003200BF0003740A000A003200EF0040405D\
:200720000A0005003200BF0000010A000A003200EF004040090001003200BD00000A000AF6\
:20074000003200EF004040090004003200BD0000090001003200BD002B0A000A003200EFA3\
:20076000004040090001003200BD00D40A000A003200EF004040090004003200BD00D4089F\
:20078000001E003200BF00090004003200BD000009000C00320000E80306000D000A0006F9\
:2007A0000018001200090010005B001000C008001B000000303A08000F005B000338090088\
:2007C00001003200000100090004003200000000090001003200100100090004003200100A\
:2007E00001000A000A003200EF004040090001003200BD01000A000A003200EF004040098B\
:200800000004003200BD0000090001003200BD012B0A000A003200EF0040400900010032CF\
:2008200000BD01D40A000A003200EF004040090004003200BD00D4090001003200BD0100A7\
:200840000A000A003200EF004040090004003200BD0000090001003200BD012B0A000A00AE\
:200860003200EF004040090001003200BD01D40A000A003200EF004040090004003200BD58\
:2008800000D40A0005003200BF0003740A000A003200EF0040400A0005003200BF00000157\
:2008A0000A000A003200EF00404008001F003200BF00090004003200BD0000090010003224\
:2008C000001080B00600180013000600180011000900100033001000EF09000100330000F0\
:2008E0000100090004003300000000080209003300BF00801E00CD1C00803E1E5C1B40CACE\
:2009000000CA1F217FAE1FEC197B187F20EBB8A8EA00128080CDB800CBB8C0CA00CA80C364\
:20092000B8C91A351ABC0280D2C0D3B80080000000004E00000000000000008000FB000128\
:200940000100000F0F0F0F0000EE12E803CE0120EB0007800080FF300000C207801E0020D8\
:2009600000809A21661ECD247F3323CD1C331B7FC31D451F1D580280D2C0D3B820EB0000D9\
:200980000000000080000101BF010000C2801E332300EB80F62470217B287FB826AE1FEB91\
:2009A0001D7FBC200820E8FB80D2C0D3B820F3000000C800000080000101AC010000C280CB\
:2009C0001E6626008052287A24282C7F3D2A8F22A4200B7FB623F12220FB80D2C0D3B858A0\
:2009E000FA00000000000080000101AB010000C2801EB8005000800054004C005C7F005814\
:200A0000004800447F664ACD4858FA80D2C0D3B820FB0400000000000080000101950100E0\
:200A200000C2801E66560080B85A14525C637F0A5FC2A34D70497F5A509F4E20F380D2C055\
:200A4000D3B8E8FB00000000000080000101BA010000BEC2801E00600080CD64335B666E5A\
:200A60007F9A6966569A517F48595C5720EB80D2C0D396B8580233A100000000800001018C\
:200A8000B4010000C2801E9A690080E26E526471797F0D29740B5FC3597F3662196000800F\
:200AA00080D2C0D3B8BC02B3DB0000000080000101A55F010000C200000000000000000004\
:200AC000000000000000000000000000000000000000C00000000000000000000000000056\
:200AE00000000000000000000000000000000000000000090001003300100100090004009B\
:200B000033001001000A000A003300EF004040090001003300BD01000A000A003300EF00AA\
:200B20004040090004003300BD0000090001003300BD012B0A000A003300EF004040090053\
:200B400001003300BD01D40A000A003300EF004040090004003300BD00D40900010033000B\
:200B6000BD01000A000A003300EF004040090004003300BD0000090001003300BD012B0AD4\
:200B8000000A003300EF004040090001003300BD01D40A000A003300EF0040400900040017\
:200BA0003300BD00D4090001003300BE002B0A000A003300EF004040090004003300BD0098\
:200BC00000090001003300BD002B0A000A003300EF004040090001003300BD00D40A000A58\
:200BE000003300EF004040090004003300BD00D40A0005003300BF0001770A000A003300C2\
:200C0000EF0040400A0005003300BF0000010A000A003300EF004040090001003300BD00B3\
:200C2000000A000A003300EF004040090004003300BD0000090001003300BD002B0A000AC8\
:200C4000003300EF004040090001003300BD00D40A000A003300EF0040400900040033002E\
:200C6000BD00D408001E003300BF00090004003300BD000009000C00330000E80306000D88\
:200C8000000A00060018001200090010005B001000C008001B000000303A08000F005B00D7\
:200CA000033809000100330000010009000400330000000009000100330010010009000420\
:200CC0000033001001000A000A003300EF004040090001003300BD01000A000A003300EFE9\
:200CE000004040090004003300BD0000090001003300BD012B0A000A003300EF0040400992\
:200D00000001003300BD01D40A000A003300EF004040090004003300BD00D4090001003349\
:200D200000BD01000A000A003300EF004040090004003300BD0000090001003300BD012B1C\
:200D40000A000A003300EF004040090001003300BD01D40A000A003300EF0040400900044B\
:200D6000003300BD00D40A0005003300BF0001770A000A003300EF0040400A00050033003E\
:200D8000BF0000010A000A003300EF00404008001F003300BF00090004003300BD000009BE\
:200DA0000010003300108066060018001300090010005B001000C00600180004000900104A\
:200DC0000030001000920A0020003000D101800008000F003000EC7F09000C00300000702E\
:200DE000170900100032001000390C0021003200D1018000000008000F003200EC2B09002E\
:200E00000C0032000070170900100033001000EF0C0021003300D1018000000008000F00F9\
:130E20003300EC0109000C003300007017060018000300AF\
:00000001FF\
";

#endif
