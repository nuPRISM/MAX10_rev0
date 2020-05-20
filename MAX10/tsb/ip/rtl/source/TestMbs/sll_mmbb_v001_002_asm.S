
/*
100097f0 <memcpy>:
100097f0:	2005883a 	mov	r2,r4
100097f4:	2007883a 	mov	r3,r4
100097f8:	218d883a 	add	r6,r4,r6
100097fc:	19800526 	beq	r3,r6,10009814 <memcpy+0x24>
10009800:	29000003 	ldbu	r4,0(r5)
10009804:	18c00044 	addi	r3,r3,1
10009808:	29400044 	addi	r5,r5,1
1000980c:	193fffc5 	stb	r4,-1(r3)
10009810:	003ffa06 	br	100097fc <__alt_data_end+0xfb8097fc>
10009814:	f800283a 	ret
*/

/* Memcpy( r4: dst, r5: src, r6: len )
*/
        .global sll_mmbb_v001_001_asm__memcpy
sll_mmbb_v001_001_asm__memcpy:
        .section exceptions
        #define dst r4
        #define src r5
		#define len r6

		mov     r2, r4			/* Store the dst pointer into the first 32-bits of return value for this function */

loop:
        ldbu	r4,0(r5)
        ldbu	r4,0(r5)
        ldbu	r4,0(r5)

		addi	r5,r5,1
		br 		loop
end:
		ret
