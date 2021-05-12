--
-- Doc. Id. 1563921.1
--

set lines 112
set pages 10000

col TSname heading 'TSpace|Name|||'
col TSname format a25
col TSstatus heading 'TSpace|Status|||'
col TSstatus format a9
col TSSizeMb heading 'TSpace|Size|Mb||'
col TSSizeMb format 99999
col TSUsedMb heading 'TSpace|Used|Space|Mb|'
col TSUsedMb format 99999
col TSFreeMb heading 'TSpace|Free|Space|Mb|'
col TSFreeMb format 99999
col TSUsedPrct heading 'TSpace|Used|Space|%|'
col TSUsedPrct format 99999
col TSFreePrct heading 'TSpace|Free|Space|%|'
col TSFreePrct format 99999
col TSSegUsedMb heading 'TSpace|Segmt|Space|Mb|'
col TSSegUsedMb format 99999
col TSExtUsedMb heading 'TSpace|Extent|Space|Mb|'
col TSExtUsedMb format 99999
col AutoExtFile heading 'Auto|Extend|File|?|'
col AutoExtFile format a6
col TSMaxSizeMb heading 'TSpace|MaxSize|Mb||'
col TSMaxSizeMb format a6
col TSMaxUsedPrct heading 'TSpace|Maxed|Used|Space|%'
col TSMaxUsedPrct format a6
col TSMaxFreePrct heading 'TSpace|Maxed|Free|Space|%'
col TSMaxFreePrct format a6

WITH
  ts_total_space AS (SELECT
                       TableSpace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks,
                       SUM(maxbytes) as maxbytes
                     FROM dba_data_files
                     GROUP BY TableSpace_name),
  ts_free_space AS (SELECT
                      ddf.TableSpace_name,
                      NVL(SUM(dfs.bytes),0) as bytes,
                      NVL(SUM(dfs.blocks),0) as blocks
                    FROM
                      dba_data_files ddf,
                      dba_free_space dfs
                    WHERE ddf.file_id = dfs.file_id(+)
                    GROUP BY ddf.TableSpace_name),
  ts_total_segments AS (SELECT
                          TableSpace_name,
                          SUM(bytes) as bytes,
                          SUM(blocks) as blocks
                        FROM dba_segments
                        GROUP BY TableSpace_name),
ts_total_extents AS (SELECT
                       TableSpace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks
                     FROM dba_extents
                     GROUP BY TableSpace_name)
SELECT
  dt.TableSpace_name as "TSname",
  dt.status as "TSstatus",
  ROUND(ttsp.bytes/1024/1024,0) as "TSSizeMb",
  ROUND((ttsp.bytes-tfs.bytes)/1024/1024,0) as "TSUsedMb",
  ROUND(tfs.bytes/1024/1024,0) as "TSFreeMb",
  ROUND((ttsp.bytes-tfs.bytes)/ttsp.bytes*100,0) as "TSUsedPrct",
  ROUND(tfs.bytes/ttsp.bytes*100,0) as "TSFreePrct",
  ROUND(ttse.bytes/1024/1024,0) as "TSSegUsedMb",
  ROUND(tte.bytes/1024/1024,0) as "TSExtUsedMb",
  CASE
    WHEN ttsp.maxbytes = 0 THEN 'No' ELSE 'Yes'
  END as "AutoExtFile",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ttsp.maxbytes/1024/1024,0))
  END as "TSMaxSizeMb",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.bytes-tfs.bytes)/ttsp.maxbytes*100,0))
  END as "TSMaxUsedPrct",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.maxbytes-(ttsp.bytes-tfs.bytes))/ttsp.maxbytes*100,0))
  END as "TSMaxFreePrct"
FROM
  dba_TableSpaces dt,
  ts_total_space ttsp,
  ts_free_space tfs,
  ts_total_segments ttse,
  ts_total_extents tte
WHERE dt.TableSpace_name = ttsp.TableSpace_name(+)
AND dt.TableSpace_name = tfs.TableSpace_name(+)
AND dt.TableSpace_name = ttse.TableSpace_name(+)
AND dt.TableSpace_name = tte.TableSpace_name(+)
--AND dt.TableSpace_name = 'SYSAUX'
;
