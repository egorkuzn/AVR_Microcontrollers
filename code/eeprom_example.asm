.include "m168def.inc"

.def  iterator = r16
.def  searchedByte = r17
.def  firstFoundIndex = r18
.def  takenElement = r19
.def  statusKeeper = r20

.equ  ARRAY_SIZE = 10
.equ  SEARCHED_VAL = 0
.equ  NOT_FOUND = -1

.DSEG

array: .BYTE ARRAY_SIZE

.CSEG

.org $000 rjmp start


arrInit:
	in     statusKeeper, SREG
	call   setPointerInArrHead
arrInitCycle:
	cpi    iterator, ARRAY_SIZE
	breq   finish
	inc    iterator
	call   setNextElement
	rjmp   arrInitCycle
finish:
	out    SREG, statusKeeper
	ret

preSearch:
	in     statusKeeper, SREG
	call   setPointerInArrHead
	ldi    searchedByte, SEARCHED_VAL
	ldi    firstFoundIndex, NOT_FOUND
	out    SREG, statusKeeper
	ret

search:
	in     statusKeeper, SREG
	call   preSearch
searchCycle:
	cpi    iterator, ARRAY_SIZE
	; Cycle is finished -> element wasn't found
	breq   searchCycleend
	call   takeNextElement
	; Check if it's element that we search
	cp     takenElement, searchedByte
	breq   found
	inc    iterator
	jmp    searchCycle
found:
	mov    firstFoundIndex, iterator
	out    SREG, statusKeeper
	ret
searchCycleend:
	ldi    iterator, NOT_FOUND
	out    SREG, statusKeeper
	ret

setNextElement:
	in     statusKeeper, SREG
setNextElement_:
	sbic   EECR,EEPE
	rjmp   setNextElement_	
	out    EEARL, r30
	out    EEARH, r31
	; Array initialisation by counts from 1 to ARRAY_SIZE 
	out    EEDR, iterator
	sbi    EECR,EEMPE
	sbi    EECR,EEPE
	call   increment
	out    SREG, statusKeeper
	ret

takeNextElement:
	in     statusKeeper, SREG
takeNextElement_:
	sbic   EECR,EEPE
	rjmp   takeNextElement_
	out    EEARL, r30
	out    EEARH, r31
	sbi    EECR,EERE
	in     takenElement, EEDR
	call   increment
	out    SREG, statusKeeper
	ret

increment:
	in     statusKeeper, SREG
increment_:
	sbic   EECR,EEPE
	rjmp   increment_
	inc    r30
	out    EEARL, r30
	out    SREG, statusKeeper
	ret

setPointerInArrHead:
	in     statusKeeper, SREG
	ldi    r30, low(array)
	ldi    r31, high(array)
setPointerInArrHead_:	
	sbic   EECR,EEPE
	rjmp   setPointerInArrHead_
	out    EEARL, r30
	out    EEARH, r31	
	ldi    iterator, 0
	out    SREG, statusKeeper
	ret

start:	
	call   arrInit  
	call   search
  
