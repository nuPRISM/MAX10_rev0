LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

PACKAGE hamm_package_112bit IS
	SUBTYPE parity_ham_112bit IS std_logic_vector(7 DOWNTO 0);
	SUBTYPE data_ham_112bit IS std_logic_vector(111 DOWNTO 0);
	SUBTYPE coded_ham_112bit IS std_logic_vector(119 DOWNTO 0);

	FUNCTION hamming_encoder_112bit(data_in:data_ham_112bit) RETURN parity_ham_112bit;
	PROCEDURE hamming_decoder_112bit(data_parity_in:coded_ham_112bit;
		SIGNAL error_out : OUT std_logic_vector(1 DOWNTO 0);
		SIGNAL decoded : OUT data_ham_112bit);
END hamm_package_112bit;

PACKAGE BODY hamm_package_112bit IS

---------------------
-- HAMMING ENCODER --
---------------------
FUNCTION hamming_encoder_112bit(data_in:data_ham_112bit) RETURN parity_ham_112bit  IS
	VARIABLE parity: parity_ham_112bit;
BEGIN

	parity(7)	:=	data_in(57) XOR data_in(58) XOR data_in(59) XOR data_in(60) XOR data_in(61) XOR 
					data_in(62) XOR data_in(63) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR 
					data_in(67) XOR data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR 
					data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR data_in(81) XOR 
					data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR data_in(86) XOR 
					data_in(87) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(6)	:=	data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR data_in(30) XOR 
					data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR data_in(35) XOR 
					data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR data_in(40) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR 
					data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(33) XOR data_in(34) XOR data_in(35) XOR data_in(36) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR data_in(67) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR 
					data_in(99) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103);
   
					
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(29) XOR data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(45) XOR data_in(46) XOR 
					data_in(47) XOR data_in(48) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25) XOR 
					data_in(27) XOR data_in(28) XOR data_in(31) XOR data_in(32) XOR data_in(35) XOR 
					data_in(36) XOR data_in(39) XOR data_in(40) XOR data_in(43) XOR data_in(44) XOR 
					data_in(47) XOR data_in(48) XOR data_in(51) XOR data_in(52) XOR data_in(55) XOR 
					data_in(56) XOR data_in(58) XOR data_in(59) XOR data_in(62) XOR data_in(63) XOR 
					data_in(66) XOR data_in(67) XOR data_in(70) XOR data_in(71) XOR data_in(74) XOR 
					data_in(75) XOR data_in(78) XOR data_in(79) XOR data_in(82) XOR data_in(83) XOR 
					data_in(86) XOR data_in(87) XOR data_in(90) XOR data_in(91) XOR data_in(94) XOR 
					data_in(95) XOR data_in(98) XOR data_in(99) XOR data_in(102) XOR data_in(103) XOR 
					data_in(106) XOR data_in(107) XOR data_in(110) XOR data_in(111);
   
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25) XOR 
					data_in(26) XOR data_in(28) XOR data_in(30) XOR data_in(32) XOR data_in(34) XOR 
					data_in(36) XOR data_in(38) XOR data_in(40) XOR data_in(42) XOR data_in(44) XOR 
					data_in(46) XOR data_in(48) XOR data_in(50) XOR data_in(52) XOR data_in(54) XOR 
					data_in(56) XOR data_in(57) XOR data_in(59) XOR data_in(61) XOR data_in(63) XOR 
					data_in(65) XOR data_in(67) XOR data_in(69) XOR data_in(71) XOR data_in(73) XOR 
					data_in(75) XOR data_in(77) XOR data_in(79) XOR data_in(81) XOR data_in(83) XOR 
					data_in(85) XOR data_in(87) XOR data_in(89) XOR data_in(91) XOR data_in(93) XOR 
					data_in(95) XOR data_in(97) XOR data_in(99) XOR data_in(101) XOR data_in(103) XOR 
					data_in(105) XOR data_in(107) XOR data_in(109) XOR data_in(111);
   
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR 
					data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR 
					data_in(35) XOR data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR 
					data_in(40) XOR data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR 
					data_in(45) XOR data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR 
					data_in(50) XOR data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR 
					data_in(55) XOR data_in(56) XOR data_in(57) XOR data_in(58) XOR data_in(59) XOR 
					data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR data_in(64) XOR 
					data_in(65) XOR data_in(66) XOR data_in(67) XOR data_in(68) XOR data_in(69) XOR 
					data_in(70) XOR data_in(71) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR 
					data_in(75) XOR data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR 
					data_in(80) XOR data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR 
					data_in(85) XOR data_in(86) XOR data_in(87) XOR data_in(88) XOR data_in(89) XOR 
					data_in(90) XOR data_in(91) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR data_in(99) XOR 
					data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR data_in(104) XOR 
					data_in(105) XOR data_in(106) XOR data_in(107) XOR data_in(108) XOR data_in(109) XOR 
					data_in(110) XOR data_in(111) XOR parity(1) XOR parity(2) XOR parity(3) XOR 
					parity(4) XOR parity(5) XOR parity(6) XOR parity(7) ;


	RETURN parity;
END;

---------------------
-- HAMMING DECODER --
---------------------
PROCEDURE hamming_decoder_112bit(data_parity_in:coded_ham_112bit;
		SIGNAL error_out : OUT std_logic_vector(1 DOWNTO 0);
		SIGNAL decoded   : OUT data_ham_112bit) IS
	VARIABLE coded       : coded_ham_112bit;
	VARIABLE syndrome    : integer RANGE 0 TO 119;
	VARIABLE parity      : parity_ham_112bit;
	VARIABLE parity_in   : parity_ham_112bit;
	VARIABLE syn         : parity_ham_112bit;
	VARIABLE data_in     : data_ham_112bit;
	VARIABLE P0, P1      : std_logic;
BEGIN

	data_in   := data_parity_in(119 DOWNTO 8);
	parity_in := data_parity_in(7 DOWNTO 0);

	parity(7)	:=	data_in(57) XOR data_in(58) XOR data_in(59) XOR data_in(60) XOR data_in(61) XOR 
					data_in(62) XOR data_in(63) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR 
					data_in(67) XOR data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR 
					data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR data_in(81) XOR 
					data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR data_in(86) XOR 
					data_in(87) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(6)	:=	data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR data_in(30) XOR 
					data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR data_in(35) XOR 
					data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR data_in(40) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR 
					data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
					
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(33) XOR data_in(34) XOR data_in(35) XOR data_in(36) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR data_in(67) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR 
					data_in(99) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103);
   
					
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(29) XOR data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(45) XOR data_in(46) XOR 
					data_in(47) XOR data_in(48) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111);
   
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25) XOR 
					data_in(27) XOR data_in(28) XOR data_in(31) XOR data_in(32) XOR data_in(35) XOR 
					data_in(36) XOR data_in(39) XOR data_in(40) XOR data_in(43) XOR data_in(44) XOR 
					data_in(47) XOR data_in(48) XOR data_in(51) XOR data_in(52) XOR data_in(55) XOR 
					data_in(56) XOR data_in(58) XOR data_in(59) XOR data_in(62) XOR data_in(63) XOR 
					data_in(66) XOR data_in(67) XOR data_in(70) XOR data_in(71) XOR data_in(74) XOR 
					data_in(75) XOR data_in(78) XOR data_in(79) XOR data_in(82) XOR data_in(83) XOR 
					data_in(86) XOR data_in(87) XOR data_in(90) XOR data_in(91) XOR data_in(94) XOR 
					data_in(95) XOR data_in(98) XOR data_in(99) XOR data_in(102) XOR data_in(103) XOR 
					data_in(106) XOR data_in(107) XOR data_in(110) XOR data_in(111);
   
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25) XOR 
					data_in(26) XOR data_in(28) XOR data_in(30) XOR data_in(32) XOR data_in(34) XOR 
					data_in(36) XOR data_in(38) XOR data_in(40) XOR data_in(42) XOR data_in(44) XOR 
					data_in(46) XOR data_in(48) XOR data_in(50) XOR data_in(52) XOR data_in(54) XOR 
					data_in(56) XOR data_in(57) XOR data_in(59) XOR data_in(61) XOR data_in(63) XOR 
					data_in(65) XOR data_in(67) XOR data_in(69) XOR data_in(71) XOR data_in(73) XOR 
					data_in(75) XOR data_in(77) XOR data_in(79) XOR data_in(81) XOR data_in(83) XOR 
					data_in(85) XOR data_in(87) XOR data_in(89) XOR data_in(91) XOR data_in(93) XOR 
					data_in(95) XOR data_in(97) XOR data_in(99) XOR data_in(101) XOR data_in(103) XOR 
					data_in(105) XOR data_in(107) XOR data_in(109) XOR data_in(111);
   
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR 
					data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR 
					data_in(35) XOR data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR 
					data_in(40) XOR data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR 
					data_in(45) XOR data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR 
					data_in(50) XOR data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR 
					data_in(55) XOR data_in(56) XOR data_in(57) XOR data_in(58) XOR data_in(59) XOR 
					data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR data_in(64) XOR 
					data_in(65) XOR data_in(66) XOR data_in(67) XOR data_in(68) XOR data_in(69) XOR 
					data_in(70) XOR data_in(71) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR 
					data_in(75) XOR data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR 
					data_in(80) XOR data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR 
					data_in(85) XOR data_in(86) XOR data_in(87) XOR data_in(88) XOR data_in(89) XOR 
					data_in(90) XOR data_in(91) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR data_in(99) XOR 
					data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR data_in(104) XOR 
					data_in(105) XOR data_in(106) XOR data_in(107) XOR data_in(108) XOR data_in(109) XOR 
					data_in(110) XOR data_in(111) XOR parity(1) XOR parity(2) XOR parity(3) XOR 
					parity(4) XOR parity(5) XOR parity(6) XOR parity(7) ;

	coded(0)	:=	data_parity_in(0);
	coded(1)	:=	data_parity_in(1);
	coded(2)	:=	data_parity_in(2);
	coded(4)	:=	data_parity_in(3);
	coded(8)	:=	data_parity_in(4);
	coded(16)	:=	data_parity_in(5);
	coded(32)	:=	data_parity_in(6);
	coded(64)	:=	data_parity_in(7);
	coded(3)	:=	data_parity_in(8);
	coded(5)	:=	data_parity_in(9);
	coded(6)	:=	data_parity_in(10);
	coded(7)	:=	data_parity_in(11);
	coded(9)	:=	data_parity_in(12);
	coded(10)	:=	data_parity_in(13);
	coded(11)	:=	data_parity_in(14);
	coded(12)	:=	data_parity_in(15);
	coded(13)	:=	data_parity_in(16);
	coded(14)	:=	data_parity_in(17);
	coded(15)	:=	data_parity_in(18);
	coded(17)	:=	data_parity_in(19);
	coded(18)	:=	data_parity_in(20);
	coded(19)	:=	data_parity_in(21);
	coded(20)	:=	data_parity_in(22);
	coded(21)	:=	data_parity_in(23);
	coded(22)	:=	data_parity_in(24);
	coded(23)	:=	data_parity_in(25);
	coded(24)	:=	data_parity_in(26);
	coded(25)	:=	data_parity_in(27);
	coded(26)	:=	data_parity_in(28);
	coded(27)	:=	data_parity_in(29);
	coded(28)	:=	data_parity_in(30);
	coded(29)	:=	data_parity_in(31);
	coded(30)	:=	data_parity_in(32);
	coded(31)	:=	data_parity_in(33);
	coded(33)	:=	data_parity_in(34);
	coded(34)	:=	data_parity_in(35);
	coded(35)	:=	data_parity_in(36);
	coded(36)	:=	data_parity_in(37);
	coded(37)	:=	data_parity_in(38);
	coded(38)	:=	data_parity_in(39);
	coded(39)	:=	data_parity_in(40);
	coded(40)	:=	data_parity_in(41);
	coded(41)	:=	data_parity_in(42);
	coded(42)	:=	data_parity_in(43);
	coded(43)	:=	data_parity_in(44);
	coded(44)	:=	data_parity_in(45);
	coded(45)	:=	data_parity_in(46);
	coded(46)	:=	data_parity_in(47);
	coded(47)	:=	data_parity_in(48);
	coded(48)	:=	data_parity_in(49);
	coded(49)	:=	data_parity_in(50);
	coded(50)	:=	data_parity_in(51);
	coded(51)	:=	data_parity_in(52);
	coded(52)	:=	data_parity_in(53);
	coded(53)	:=	data_parity_in(54);
	coded(54)	:=	data_parity_in(55);
	coded(55)	:=	data_parity_in(56);
	coded(56)	:=	data_parity_in(57);
	coded(57)	:=	data_parity_in(58);
	coded(58)	:=	data_parity_in(59);
	coded(59)	:=	data_parity_in(60);
	coded(60)	:=	data_parity_in(61);
	coded(61)	:=	data_parity_in(62);
	coded(62)	:=	data_parity_in(63);
	coded(63)	:=	data_parity_in(64);
	coded(65)	:=	data_parity_in(65);
	coded(66)	:=	data_parity_in(66);
	coded(67)	:=	data_parity_in(67);
	coded(68)	:=	data_parity_in(68);
	coded(69)	:=	data_parity_in(69);
	coded(70)	:=	data_parity_in(70);
	coded(71)	:=	data_parity_in(71);
	coded(72)	:=	data_parity_in(72);
	coded(73)	:=	data_parity_in(73);
	coded(74)	:=	data_parity_in(74);
	coded(75)	:=	data_parity_in(75);
	coded(76)	:=	data_parity_in(76);
	coded(77)	:=	data_parity_in(77);
	coded(78)	:=	data_parity_in(78);
	coded(79)	:=	data_parity_in(79);
	coded(80)	:=	data_parity_in(80);
	coded(81)	:=	data_parity_in(81);
	coded(82)	:=	data_parity_in(82);
	coded(83)	:=	data_parity_in(83);
	coded(84)	:=	data_parity_in(84);
	coded(85)	:=	data_parity_in(85);
	coded(86)	:=	data_parity_in(86);
	coded(87)	:=	data_parity_in(87);
	coded(88)	:=	data_parity_in(88);
	coded(89)	:=	data_parity_in(89);
	coded(90)	:=	data_parity_in(90);
	coded(91)	:=	data_parity_in(91);
	coded(92)	:=	data_parity_in(92);
	coded(93)	:=	data_parity_in(93);
	coded(94)	:=	data_parity_in(94);
	coded(95)	:=	data_parity_in(95);
	coded(96)	:=	data_parity_in(96);
	coded(97)	:=	data_parity_in(97);
	coded(98)	:=	data_parity_in(98);
	coded(99)	:=	data_parity_in(99);
	coded(100)	:=	data_parity_in(100);
	coded(101)	:=	data_parity_in(101);
	coded(102)	:=	data_parity_in(102);
	coded(103)	:=	data_parity_in(103);
	coded(104)	:=	data_parity_in(104);
	coded(105)	:=	data_parity_in(105);
	coded(106)	:=	data_parity_in(106);
	coded(107)	:=	data_parity_in(107);
	coded(108)	:=	data_parity_in(108);
	coded(109)	:=	data_parity_in(109);
	coded(110)	:=	data_parity_in(110);
	coded(111)	:=	data_parity_in(111);
	coded(112)	:=	data_parity_in(112);
	coded(113)	:=	data_parity_in(113);
	coded(114)	:=	data_parity_in(114);
	coded(115)	:=	data_parity_in(115);
	coded(116)	:=	data_parity_in(116);
	coded(117)	:=	data_parity_in(117);
	coded(118)	:=	data_parity_in(118);
	coded(119)	:=	data_parity_in(119);

	-- syndorme generation
	syn(7 DOWNTO 1) := parity(7 DOWNTO 1) XOR parity_in(7 DOWNTO 1);
	P0 := '0';
	P1 := '0';
	FOR i IN 0 TO 7 LOOP
		P0 := P0 XOR parity(i);
		P1 := P1 XOR parity_in(i);
	END LOOP;
	syn(0) := P0 XOR P1;

	CASE syn(7 DOWNTO 1) IS
		WHEN "0000011" => syndrome := 3;
		WHEN "0000101" => syndrome := 5;
		WHEN "0000110" => syndrome := 6;
		WHEN "0000111" => syndrome := 7;
		WHEN "0001001" => syndrome := 9;
		WHEN "0001010" => syndrome := 10;
		WHEN "0001011" => syndrome := 11;
		WHEN "0001100" => syndrome := 12;
		WHEN "0001101" => syndrome := 13;
		WHEN "0001110" => syndrome := 14;
		WHEN "0001111" => syndrome := 15;
		WHEN "0010001" => syndrome := 17;
		WHEN "0010010" => syndrome := 18;
		WHEN "0010011" => syndrome := 19;
		WHEN "0010100" => syndrome := 20;
		WHEN "0010101" => syndrome := 21;
		WHEN "0010110" => syndrome := 22;
		WHEN "0010111" => syndrome := 23;
		WHEN "0011000" => syndrome := 24;
		WHEN "0011001" => syndrome := 25;
		WHEN "0011010" => syndrome := 26;
		WHEN "0011011" => syndrome := 27;
		WHEN "0011100" => syndrome := 28;
		WHEN "0011101" => syndrome := 29;
		WHEN "0011110" => syndrome := 30;
		WHEN "0011111" => syndrome := 31;
		WHEN "0100001" => syndrome := 33;
		WHEN "0100010" => syndrome := 34;
		WHEN "0100011" => syndrome := 35;
		WHEN "0100100" => syndrome := 36;
		WHEN "0100101" => syndrome := 37;
		WHEN "0100110" => syndrome := 38;
		WHEN "0100111" => syndrome := 39;
		WHEN "0101000" => syndrome := 40;
		WHEN "0101001" => syndrome := 41;
		WHEN "0101010" => syndrome := 42;
		WHEN "0101011" => syndrome := 43;
		WHEN "0101100" => syndrome := 44;
		WHEN "0101101" => syndrome := 45;
		WHEN "0101110" => syndrome := 46;
		WHEN "0101111" => syndrome := 47;
		WHEN "0110000" => syndrome := 48;
		WHEN "0110001" => syndrome := 49;
		WHEN "0110010" => syndrome := 50;
		WHEN "0110011" => syndrome := 51;
		WHEN "0110100" => syndrome := 52;
		WHEN "0110101" => syndrome := 53;
		WHEN "0110110" => syndrome := 54;
		WHEN "0110111" => syndrome := 55;
		WHEN "0111000" => syndrome := 56;
		WHEN "0111001" => syndrome := 57;
		WHEN "0111010" => syndrome := 58;
		WHEN "0111011" => syndrome := 59;
		WHEN "0111100" => syndrome := 60;
		WHEN "0111101" => syndrome := 61;
		WHEN "0111110" => syndrome := 62;
		WHEN "0111111" => syndrome := 63;
		WHEN "1000001" => syndrome := 65;
		WHEN "1000010" => syndrome := 66;
		WHEN "1000011" => syndrome := 67;
		WHEN "1000100" => syndrome := 68;
		WHEN "1000101" => syndrome := 69;
		WHEN "1000110" => syndrome := 70;
		WHEN "1000111" => syndrome := 71;
		WHEN "1001000" => syndrome := 72;
		WHEN "1001001" => syndrome := 73;
		WHEN "1001010" => syndrome := 74;
		WHEN "1001011" => syndrome := 75;
		WHEN "1001100" => syndrome := 76;
		WHEN "1001101" => syndrome := 77;
		WHEN "1001110" => syndrome := 78;
		WHEN "1001111" => syndrome := 79;
		WHEN "1010000" => syndrome := 80;
		WHEN "1010001" => syndrome := 81;
		WHEN "1010010" => syndrome := 82;
		WHEN "1010011" => syndrome := 83;
		WHEN "1010100" => syndrome := 84;
		WHEN "1010101" => syndrome := 85;
		WHEN "1010110" => syndrome := 86;
		WHEN "1010111" => syndrome := 87;
		WHEN "1011000" => syndrome := 88;
		WHEN "1011001" => syndrome := 89;
		WHEN "1011010" => syndrome := 90;
		WHEN "1011011" => syndrome := 91;
		WHEN "1011100" => syndrome := 92;
		WHEN "1011101" => syndrome := 93;
		WHEN "1011110" => syndrome := 94;
		WHEN "1011111" => syndrome := 95;
		WHEN "1100000" => syndrome := 96;
		WHEN "1100001" => syndrome := 97;
		WHEN "1100010" => syndrome := 98;
		WHEN "1100011" => syndrome := 99;
		WHEN "1100100" => syndrome := 100;
		WHEN "1100101" => syndrome := 101;
		WHEN "1100110" => syndrome := 102;
		WHEN "1100111" => syndrome := 103;
		WHEN "1101000" => syndrome := 104;
		WHEN "1101001" => syndrome := 105;
		WHEN "1101010" => syndrome := 106;
		WHEN "1101011" => syndrome := 107;
		WHEN "1101100" => syndrome := 108;
		WHEN "1101101" => syndrome := 109;
		WHEN "1101110" => syndrome := 110;
		WHEN "1101111" => syndrome := 111;
		WHEN "1110000" => syndrome := 112;
		WHEN "1110001" => syndrome := 113;
		WHEN "1110010" => syndrome := 114;
		WHEN "1110011" => syndrome := 115;
		WHEN "1110100" => syndrome := 116;
		WHEN "1110101" => syndrome := 117;
		WHEN "1110110" => syndrome := 118;
		WHEN "1110111" => syndrome := 119;
		WHEN OTHERS =>  syndrome := 0;
	END CASE;

	IF syn(0) = '1'  THEN
		coded(syndrome) := NOT(coded(syndrome));
		error_out <= "01";    -- There is an error
	ELSIF syndrome/= 0 THEN     -- There are more than one error
		coded := (OTHERS => '0');-- FATAL ERROR
		error_out <= "11";
	ELSE
		error_out <= "00"; -- No errors detected
	END IF;
	decoded(0)	<=	coded(3);
	decoded(1)	<=	coded(5);
	decoded(2)	<=	coded(6);
	decoded(3)	<=	coded(7);
	decoded(4)	<=	coded(9);
	decoded(5)	<=	coded(10);
	decoded(6)	<=	coded(11);
	decoded(7)	<=	coded(12);
	decoded(8)	<=	coded(13);
	decoded(9)	<=	coded(14);
	decoded(10)	<=	coded(15);
	decoded(11)	<=	coded(17);
	decoded(12)	<=	coded(18);
	decoded(13)	<=	coded(19);
	decoded(14)	<=	coded(20);
	decoded(15)	<=	coded(21);
	decoded(16)	<=	coded(22);
	decoded(17)	<=	coded(23);
	decoded(18)	<=	coded(24);
	decoded(19)	<=	coded(25);
	decoded(20)	<=	coded(26);
	decoded(21)	<=	coded(27);
	decoded(22)	<=	coded(28);
	decoded(23)	<=	coded(29);
	decoded(24)	<=	coded(30);
	decoded(25)	<=	coded(31);
	decoded(26)	<=	coded(33);
	decoded(27)	<=	coded(34);
	decoded(28)	<=	coded(35);
	decoded(29)	<=	coded(36);
	decoded(30)	<=	coded(37);
	decoded(31)	<=	coded(38);
	decoded(32)	<=	coded(39);
	decoded(33)	<=	coded(40);
	decoded(34)	<=	coded(41);
	decoded(35)	<=	coded(42);
	decoded(36)	<=	coded(43);
	decoded(37)	<=	coded(44);
	decoded(38)	<=	coded(45);
	decoded(39)	<=	coded(46);
	decoded(40)	<=	coded(47);
	decoded(41)	<=	coded(48);
	decoded(42)	<=	coded(49);
	decoded(43)	<=	coded(50);
	decoded(44)	<=	coded(51);
	decoded(45)	<=	coded(52);
	decoded(46)	<=	coded(53);
	decoded(47)	<=	coded(54);
	decoded(48)	<=	coded(55);
	decoded(49)	<=	coded(56);
	decoded(50)	<=	coded(57);
	decoded(51)	<=	coded(58);
	decoded(52)	<=	coded(59);
	decoded(53)	<=	coded(60);
	decoded(54)	<=	coded(61);
	decoded(55)	<=	coded(62);
	decoded(56)	<=	coded(63);
	decoded(57)	<=	coded(65);
	decoded(58)	<=	coded(66);
	decoded(59)	<=	coded(67);
	decoded(60)	<=	coded(68);
	decoded(61)	<=	coded(69);
	decoded(62)	<=	coded(70);
	decoded(63)	<=	coded(71);
	decoded(64)	<=	coded(72);
	decoded(65)	<=	coded(73);
	decoded(66)	<=	coded(74);
	decoded(67)	<=	coded(75);
	decoded(68)	<=	coded(76);
	decoded(69)	<=	coded(77);
	decoded(70)	<=	coded(78);
	decoded(71)	<=	coded(79);
	decoded(72)	<=	coded(80);
	decoded(73)	<=	coded(81);
	decoded(74)	<=	coded(82);
	decoded(75)	<=	coded(83);
	decoded(76)	<=	coded(84);
	decoded(77)	<=	coded(85);
	decoded(78)	<=	coded(86);
	decoded(79)	<=	coded(87);
	decoded(80)	<=	coded(88);
	decoded(81)	<=	coded(89);
	decoded(82)	<=	coded(90);
	decoded(83)	<=	coded(91);
	decoded(84)	<=	coded(92);
	decoded(85)	<=	coded(93);
	decoded(86)	<=	coded(94);
	decoded(87)	<=	coded(95);
	decoded(88)	<=	coded(96);
	decoded(89)	<=	coded(97);
	decoded(90)	<=	coded(98);
	decoded(91)	<=	coded(99);
	decoded(92)	<=	coded(100);
	decoded(93)	<=	coded(101);
	decoded(94)	<=	coded(102);
	decoded(95)	<=	coded(103);
	decoded(96)	<=	coded(104);
	decoded(97)	<=	coded(105);
	decoded(98)	<=	coded(106);
	decoded(99)	<=	coded(107);
	decoded(100)	<=	coded(108);
	decoded(101)	<=	coded(109);
	decoded(102)	<=	coded(110);
	decoded(103)	<=	coded(111);
	decoded(104)	<=	coded(112);
	decoded(105)	<=	coded(113);
	decoded(106)	<=	coded(114);
	decoded(107)	<=	coded(115);
	decoded(108)	<=	coded(116);
	decoded(109)	<=	coded(117);
	decoded(110)	<=	coded(118);
	decoded(111)	<=	coded(119);

END;
END PACKAGE BODY;
