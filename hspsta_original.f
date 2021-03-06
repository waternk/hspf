C
C
C
      SUBROUTINE   HSPSTA
     I                   (NOPNS,LAST,COUNT,OPN,OMCODE,OPTNO)
C
C     + + + PURPOSE + + +
C     routine to show run status for HSPF
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER     NOPNS,LAST,COUNT,OPN,OMCODE,OPTNO
C
C     + + + ARGUMENT DEFINITIONS + + +
C     NOPNS  - total number of options
C     LAST   - last time interval
C     COUNT  - number of current time interval
C     OPN    - number of current operation number
C     OMCODE - code number of current operation
C     OPTNO  - number for this operation
C
C     + + + LOCAL VARIABLES + + +
      INTEGER     I1,I6,I80,J,SKIP,JUST,LEN,POS,SCOL,ROW,COL1,
     1            FORE,BACK,ALEN,APOS
      REAL        COLWID
      CHARACTER*1 OPNAM(6,9),WBUFF(33),OBUFF(80),BK(1),CH1,CH2,CH3
C
      SAVE        COLWID,SKIP,ALEN,APOS,ROW
C
C     + + + FUNCTIONS + + +
      INTEGER     LENSTR
C
C     + + + INTRINSICS + + +
      INTRINSIC   FLOAT,MOD
C
C     + + + EXTERNALS + + +
      EXTERNAL    ZIPC,CHRCHR,SCCUMV,SCPRST,LENSTR,SCCLAL,COLSET,
     #            INTCHR,XGTCHR
C
C     + + + DATA INITIALIZATIONS + + +
      DATA I1,I6,I80,JUST,SCOL/1,6,80,0,13/
      DATA WBUFF/'O','P','x','x','x',' ','O','F','x','x','x',' ',' ',
     1           ' ','T','I','M','E',' ','P','A','D','x','x','x','x',
     2           ' ','O','F','x','x','x','x'/
      DATA OPNAM,BK(1)/'P','E','R','L','N','D','I','M','P','L','N','D',
     1                 'R','C','H','R','E','S','C','O','P','Y',' ',' ',
     2                 'P','L','T','G','E','N','D','I','S','P','L','Y',
     3                 'D','U','R','A','N','L','G','E','N','E','R',' ',
     4                 'M','U','T','S','I','N',' '/
C
C     + + + END SPECIFICATIONS + + +
C
      CALL XGTCHR
     O            (CH1,CH2,CH3)
C
      FORE= 7
      BACK= 0
      CALL COLSET (FORE,BACK)
C
      IF (COUNT.EQ.1 .AND. OPN.EQ.1) THEN
C       determine how many lines to display
        SKIP= (NOPNS- 1)/22+ 1
C        SKIP= 1
C        IF (NOPNS.GT.66) THEN
C          SKIP= 4
C        ELSE IF (NOPNS.GT.44) THEN
C          SKIP= 3
C        ELSE IF (NOPNS.GT.22) THEN
C          SKIP= 2
C        END IF
C       determine column width
        COLWID= 68./FLOAT(LAST)
        ALEN = COLWID
        APOS = 0
        ROW  = 0
        IF (ALEN.EQ.0) ALEN= 1
C       clear screen
        CALL SCCLAL
      END IF
C
C     update where we are
      LEN= 3
      CALL INTCHR (OPN,LEN,JUST,J,WBUFF(3))
      CALL INTCHR (NOPNS,LEN,JUST,J,WBUFF(9))
      LEN= 4
      CALL INTCHR (COUNT,LEN,JUST,J,WBUFF(23))
      CALL INTCHR (LAST,LEN,JUST,J,WBUFF(30))
      CALL SCCUMV (I1,I1)
      LEN= 33
      CALL SCPRST (LEN,WBUFF)
      CALL COLSET (FORE,BACK)
C
      IF (MOD(OPN-1,SKIP).EQ.0.OR.OPN.EQ.1) THEN
C       make previous active section inactive
        IF (COUNT.GT.1 .OR. OPN.GT.1) THEN
          CALL ZIPC (ALEN,CH1,OBUFF)
C         WRITE (*,*) 'MOVE CURSOR TO LROW, POS ',LROW,POS
          CALL SCCUMV (ROW,APOS)
          CALL SCPRST (ALEN,OBUFF)
          CALL COLSET (FORE,BACK)
        END IF
C       display this line
        ROW = 3+ (OPN-1)/SKIP
        CALL ZIPC (I80,BK(1),OBUFF)
C       put operation name in buffer
        CALL CHRCHR (I6,OPNAM(1,OMCODE),OBUFF)
C       put operation number in buffer
        LEN = 4
        CALL INTCHR (OPTNO,LEN,JUST,
     O               J,OBUFF(7))
C       put completed portion in buffer
        COL1= (COUNT-1)* COLWID+ SCOL
        LEN = COL1- SCOL
        IF (LEN.GT.66) LEN= 66
        IF (LEN.GT.0) CALL ZIPC (LEN,CH1,OBUFF(SCOL))
C       write beginning of line and completed portion
        CALL SCCUMV (ROW,I1)
        LEN = LENSTR(I80,OBUFF)
        IF (LEN.LT.13) LEN= 12
        CALL SCPRST (LEN,OBUFF)
        APOS= LEN+ 1
C       write active portion
        CALL ZIPC (ALEN,CH2,OBUFF(APOS))
        CALL SCPRST (ALEN,OBUFF(APOS))
        POS = APOS+ ALEN
        LEN = I80- POS
        IF (LEN.GT.0) THEN
          CALL ZIPC (LEN,CH3,OBUFF(POS))
C         write remaining portion
          CALL SCPRST (LEN,OBUFF(POS))
        END IF
        CALL COLSET (FORE,BACK)
      END IF
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMESC
     I                   (MESSFL,SCLU,SGRP,STRING)
C
C     + + + PURPOSE + + +
C     put message with character string to output unit
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER       MESSFL,SCLU,SGRP
      CHARACTER*64  STRING
C
C     + + + ARGUMENT DEFINITIONS + + +
C     MESSFL - message file unit number
C     SCLU   - screen cluster number
C     SGRP   - screen message group
C     STRING - character string to add to message
C
C     + + + LOCAL VARIABLES + + +
      INTEGER      I1,CLEN(1),I,J,OFUN
      CHARACTER*1  STRIN1(64)
C
C     + + + EXTERNALS + + +
      EXTERNAL    CVARAR,PMXTFC,SCCUMV
C
C     + + + END SPECIFICATIONS + + +
C
      I1     = 1
      CLEN(1)= 64
C     set cursor in right place
      I = 6
      J = 12
      CALL SCCUMV (I,J)
C
C     convert character string to array
      CALL CVARAR (CLEN(1),STRING,CLEN(1),STRIN1)
C     send message to screen
      OFUN = -1
      CALL PMXTFC (MESSFL,OFUN,SCLU,SGRP,I1,CLEN,STRIN1)
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMESI
     I                   (MESSFL,SCLU,SGRP,I)
C
C     + + + PURPOSE + + +
C     put message with integer to output unit
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER       MESSFL,SCLU,SGRP,I
C
C     + + + ARGUMENT DEFINITIONS + + +
C     MESSFL - message file unit number
C     SCLU   - screen cluster number
C     SGRP   - screen message group
C     I      - integer value to add to message
C
C     + + + LOCAL VARIABLES + + +
      INTEGER     I1,IVAL(1),K,J,OFUN
C
C     + + + EXTERNALS + + +
      EXTERNAL    PMXTFI,SCCUMV
C
C     + + + END SPECIFICATIONS + + +
C
      I1     = 1
      IVAL(1)= I
C     set cursor in right place
      K = 6
      J = 12
      CALL SCCUMV (K,J)
C
C     send message to screen
      OFUN = -1
      CALL PMXTFI (MESSFL,OFUN,SCLU,SGRP,I1,IVAL)
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMEST
     I                   (MESSFL,SCLU,SGRP)
C
C     + + + PURPOSE + + +
C     put message (text only) to output unit
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER       MESSFL,SCLU,SGRP
C
C     + + + ARGUMENT DEFINITIONS + + +
C     MESSFL - message file unit number
C     SCLU   - screen cluster number
C     SGRP   - screen message group
C
C     + + + LOCAL VARIABLES + + +
      INTEGER     I,J,OFUN
C
C     + + + EXTERNALS + + +
      EXTERNAL    PMXTFT,SCCUMV
C
C     + + + END SPECIFICATIONS + + +
C
C     set cursor in right place
      I = 6
      J = 12
      CALL SCCUMV (I,J)
C     send message to screen
      OFUN = -1
      CALL PMXTFT (MESSFL,OFUN,SCLU,SGRP)
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMES2
     I                   (KTYP,OCCUR)
C
C     + + + PURPOSE + + +
C     put current operation or block to screen during interp
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER       KTYP,OCCUR
C
C     + + + ARGUMENT DEFINITIONS + + +
C     KTYP    - type of keyword
C     OCCUR   - number of occurances
C
C     + + + LOCAL VARIABLES + + +
      INTEGER      I,J
      CHARACTER*12 KNAME
C
C     + + + EXTERNALS + + +
      EXTERNAL    GETKNM,ZWRSCR
C
C     + + + END SPECIFICATIONS + + +
C
C     get this keyword
      CALL GETKNM (KTYP,OCCUR,
     O             KNAME)
C     write to screen
      I= 7
      J= 15
      CALL ZWRSCR (KNAME,I,J)
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMES3
     I                   (TABNAM)
C
C     + + + PURPOSE + + +
C     put current operation table name to screen during interp
C
C     + + + DUMMY ARGUMENTS + + +
      CHARACTER*12  TABNAM
C
C     + + + ARGUMENT DEFINITIONS + + +
C     TABNAM  - table name
C
C     + + + LOCAL VARIABLES + + +
      INTEGER      I,J
C
C     + + + EXTERNALS + + +
      EXTERNAL    ZWRSCR
C
C     + + + END SPECIFICATIONS + + +
C
C     write to screen
      I= 7
      J= 34
      CALL ZWRSCR (TABNAM,I,J)
C
      RETURN
      END
C
C
C
      SUBROUTINE   HDMESN
     I                   (OPTNO)
C
C     + + + PURPOSE + + +
C     put current operation number to screen during interp
C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER       OPTNO
C
C     + + + ARGUMENT DEFINITIONS + + +
C     OPTNO  - operation number
C
C     + + + LOCAL VARIABLES + + +
      INTEGER      I,J,K,I1,I5
      CHARACTER*1  CHRST1(5)
      CHARACTER*5  COPTNO
C
C     + + + EXTERNALS + + +
      EXTERNAL    ZWRSCR,INTCHR,CARVAR
C
C     + + + END SPECIFICATIONS + + +
C
      I1 = 1
      I5 = 5
      IF (OPTNO.EQ.0) THEN
        COPTNO = '     '
      ELSE
        CALL INTCHR (OPTNO,I5,I1,K,CHRST1)
        CALL CARVAR (I5,CHRST1,I5,COPTNO)
      END IF
C
C     write to screen
      I= 7
      J= 28
      CALL ZWRSCR (COPTNO,I,J)
C
      RETURN
      END
