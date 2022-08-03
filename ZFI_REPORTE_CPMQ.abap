*&---------------------------------------------------------------------*
*& Report  ZFI_REPORTE_CPMQ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_reporte_cpmq.
TABLES: caufv, afvc, crco, glpca.


*TYPES:
*  BEGIN OF st_caufv,
*    aufnr TYPE char12,
*  END OF st_caufv.
*
*TYPES:
*  BEGIN OF st_caufv_aux,
*    aufpl LIKE afvc-aufpl,
*  END OF st_caufv_aux.

DATA: it_caufv     TYPE TABLE OF caufv,
      it_caufv_aux TYPE TABLE OF caufv,
      it_afvc      TYPE TABLE OF afvc,
      it_afru      TYPE TABLE OF afru,
      it_crco      TYPE TABLE OF crco,
      it_glpca     TYPE TABLE OF glpca,
      it_glpca_aux TYPE TABLE OF glpca.

DATA: wa_caufv TYPE caufv,
      wa_afvc  TYPE afvc,
      wa_afru  TYPE afru,
      wa_crco  TYPE crco,
      wa_glpca TYPE glpca.


DATA: gv_aufnr TYPE char12.

FIELD-SYMBOLS: <fs_caufv> TYPE caufv,
               <fs_afvc>  TYPE afvc,
               <fs_crco>  TYPE crco,
               <fs_glpca> TYPE glpca,
               <fs_glpca_aux> TYPE glpca.


SELECTION-SCREEN BEGIN OF BLOCK selectdata WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_aufnr FOR caufv-aufnr.
*                s_erdat FOR caufv-erdat."L/C JGP 29032022 T_9575 D07K904680

SELECTION-SCREEN END OF BLOCK selectdata.


START-OF-SELECTION.
***BOM JGP 29032022 T_9575 D01K9A03I9
***  SELECT *
***    FROM caufv
***    INTO TABLE it_caufv
***    WHERE aufnr IN s_aufnr." and
****          erdat in s_erdat."L/N JGP 17032022 T_10146 D07K904680

    SELECT * FROM glpca
       INTO TABLE it_glpca WHERE ryear GE '2021'   AND
                                 aufnr NE space    AND
                                 aufnr IN s_aufnr  AND
                                 kostl EQ space    AND
                                ( ( rprctr BETWEEN '0051000000' AND '0056999999' ) OR
                                  ( rprctr BETWEEN '0005210000' AND '0005219999' ) ) .
***EOM JGP 29032022 T_9575 D01K9A03I9


*LOOP AT it_caufv INTO wa_caufv.
*  wa_caufv_aux-aufpl = wa_caufv-aufnr.
*
*  APPEND wa_caufv_aux TO it_caufv_aux.
*ENDLOOP.

****  IF it_caufv IS NOT INITIAL."L/C JGP 29032022 T_9575 D01K9A03I9
  IF it_glpca IS NOT INITIAL.    "L/N JGP 29032022 T_9575 D01K9A03I9
    SELECT *
      FROM afru
      INTO TABLE it_afru
      FOR ALL ENTRIES IN it_glpca
      WHERE aufnr EQ it_glpca-aufnr
        AND arbid IN ('10000007','10000008','10000009','10000010','10000011',      "T_9575 BDBC 23.03.2022
                      '10000012','10000014','10000017','10000018','10000019',
                      '10000020','10000021','10000025','10000066','10000070',
                      '10000131','10000148','10000149','10000022','10000023',
                      '10000013').

*    ('10000003', '10000004', '10000006', '10000007', '10000009').  "T_9575 BDBC 23.03.2022

*    SELECT *
*      FROM afvc
*      INTO TABLE it_afvc
*      FOR ALL ENTRIES IN it_caufv
*      WHERE aufpl EQ it_caufv-aufpl
*        AND arbid IN ('10000003', '10000004', '10000006', '10000007', '10000009').
*        AND aplzl EQ '2'.

    IF it_afru IS NOT INITIAL.
      SELECT *
        FROM crco
        INTO TABLE it_crco
        FOR ALL ENTRIES IN it_afru
        WHERE objid EQ it_afru-arbid.
    ENDIF.
    "BOM JGP 29032022 (se comentó lieas de código) T_9575 D01K9A03I9
****    IF it_crco IS NOT INITIAL.
****      SELECT *
****        FROM glpca
****        INTO TABLE it_glpca
****        FOR ALL ENTRIES IN it_caufv
****        WHERE aufnr EQ it_caufv-aufnr.
****    ENDIF.
    "EOM JGP 29032022 T_9575 D01K9A03I9
  ENDIF.


*** BOM JGP 29032022 T_9575 D01K9A03I9{
*** SE COMENTÓ CÓDIGO ORIGINAL SEGÚN ESPECIUFICACIÓN DOC
****  LOOP AT it_caufv INTO wa_caufv.
****    CLEAR: wa_glpca.
****    LOOP AT it_glpca INTO wa_glpca WHERE aufnr EQ wa_caufv-aufnr.
*****      CLEAR: wa_afvc.
*****      READ TABLE it_afvc INTO wa_afvc WITH KEY aufpl = wa_caufv-aufpl.
*****      IF sy-subrc EQ 0.
****
****      CLEAR: wa_afru.
****      READ TABLE it_afru INTO wa_afru WITH KEY aufnr = wa_caufv-aufnr.
****      IF sy-subrc EQ 0.
*****        IF wa_glpca-kostl IS INITIAL."L/C JGP 17032022 T_10146 D07K904680
****          CLEAR: wa_crco.
****          READ TABLE it_crco INTO wa_crco WITH KEY objid = wa_afru-arbid.
****          IF sy-subrc EQ 0.
****
****            wa_glpca-kostl = wa_crco-kostl.
****
****            APPEND wa_glpca TO it_glpca_aux.
****          ENDIF.
*****        ENDIF."L/C JGP 17032022 T_10146 D07K904680
****      ENDIF.
****    ENDLOOP.
****  ENDLOOP.
*** }EOM JGP 29032022 T_9575 D01K9A03I9

***BOM JGP 29032022 T_9575 D01K9A03I9{
  LOOP AT it_glpca INTO wa_glpca.
    CLEAR: wa_afru.
    READ TABLE it_afru INTO wa_afru WITH KEY aufnr = wa_glpca-aufnr.
    IF sy-subrc EQ 0.
      CLEAR: wa_crco.
      READ TABLE it_crco INTO wa_crco WITH KEY objid = wa_afru-arbid.
      IF sy-subrc EQ 0.
        wa_glpca-kostl = wa_crco-kostl.
        APPEND wa_glpca TO it_glpca_aux.
      ENDIF.
    ENDIF.
  ENDLOOP.
*** }EOM JGP 29032022 T_9575 D01K9A03I9

  IF it_glpca_aux[] IS NOT INITIAL.
    MODIFY glpca FROM TABLE it_glpca_aux.
    MESSAGE i162(00) WITH 'Datos Actualizados...' .
  ELSE.
    MESSAGE i162(00) WITH 'No se actualizaron los datos...'.
  ENDIF.
